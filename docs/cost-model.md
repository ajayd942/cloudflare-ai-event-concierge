# Cost and Quota Model

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Policy

Normal operation targets no more than USD 5 per month, excluding the already
owned domain. Workers and eligible Cloudflare dependencies remain on Workers
Free. The project never upgrades to Workers Paid automatically or to preserve
availability. Bounded Anthropic usage is the only expected ordinary variable
charge.

Pricing, quotas, model availability, and alert features are time-sensitive.
This model records a planning snapshot, formulas, and release checks; it is not a
promise that provider terms remain unchanged.

## Planning snapshot

Official provider pages were revalidated on 2026-07-23:

| Service | Relevant current planning fact | Source |
|---|---|---|
| Workers | Free currently includes 100,000 dynamic requests/day and 10 ms CPU/invocation; static assets are treated separately | [Workers pricing](https://developers.cloudflare.com/workers/platform/pricing/) |
| KV | Free currently lists 100,000 reads/day, 1,000 different-key writes/day, one write/second to the same key, and 1 GB/account/namespace | [KV limits](https://developers.cloudflare.com/kv/platform/limits/) |
| Vectorize | Free currently includes 30 million queried dimensions/month and 5 million stored dimensions | [Vectorize pricing](https://developers.cloudflare.com/vectorize/platform/pricing/) |
| Workers AI | Current free allocation is 10,000 neurons/day; BGE small is listed at 1,841 neurons/million input tokens | [Workers AI pricing](https://developers.cloudflare.com/workers-ai/platform/pricing/) |
| Durable Objects | SQLite-backed objects are currently available on Free with daily request/compute/row limits and 5 GB total SQLite storage | [Durable Objects pricing](https://developers.cloudflare.com/durable-objects/platform/pricing/) |
| Claude Haiku 4.5 | Current standard first-party price is USD 1/million input tokens and USD 5/million output tokens | [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing) |

Implementation and launch must reread the sources, record the date and changed
terms, and stop for human review if the approved Free-only/security contract is
no longer feasible. Numeric quotas belong in the review record/configuration
checks, not permanent marketing claims.

## Workload variables

| Symbol | Meaning |
|---|---|
| `R` | Dynamic public/admin Worker requests per month |
| `C` | Valid chat requests after Turnstile/rate/runtime checks |
| `H` | Eligible internal response-cache hits |
| `X` | Unique exact/canonical requests that avoid semantic/model work |
| `S` | Semantic queries, `max(0, C - H - X)` subject to degradation |
| `G` | Claude-generated responses after relevant retrieval |
| `E` | Enabled entries in current publication, target 20–30, maximum 100 |
| `V` | Retained vector versions, maximum 5 |
| `Ti` | Average Claude input tokens per generated response |
| `To` | Average Claude output tokens per generated response, maximum 300 |
| `Te` | Average embedding tokens per query/document, target <=350 |
| `P` | Publish/rollback operations per month |

All usage dashboards must use measured values; no raw question or answer is
needed to compute them.

## Per-request resource path

| Path | KV reads | Workers AI | Vectorize | Claude | Coordinator |
|---|---:|---:|---:|---:|---:|
| Health | Up to 2 | 0 | 0 | 0 | 0 |
| Public config | Up to 2 | 0 | 0 | 0 | 0 |
| Chat rejected before content | 0 | 0 | 0 | 0 | 0 |
| Eligible cache hit | Up to 3 | 0 | 0 | 0 | 0 |
| Unique exact canonical | Up to 3 | 0 | 0 | 0 | 0 |
| Lexical-only answer/fallback | Up to 3 | 0 | 0 | 0 or 1 grounded call | 0 |
| Hybrid generated | Up to 3 | 1 query embedding | 1 current-namespace query | 1, plus at most one bounded retry | 0 |
| Draft/runtime mutation | Low bounded reads/writes | 0 | 0 | 0 | 1 request |
| Publish/rollback | Bounded checkpoint reads/writes | `E` document embeddings in batches | `E` upserts + probes | smoke only where approved | 1 operation + alarms |

Turnstile and rate checks precede expensive work. Cache hits still count as
Worker/chat traffic, but avoid embeddings, vectors, and Claude.

## Cloudflare capacity formulas

### KV

Approximate public read demand:

```text
KV_public_reads <= 3*C + 2*configRequests + 2*healthChecks
```

Writes are deliberately low: explicit draft saves, runtime changes, one
publication, one optional snapshot, one index-status key, and bounded status
updates. Same-key writes are at least one second apart. Approaching 70% of a
current daily read/write allowance is an operational warning; 80% triggers
owner review and traffic/publish reduction. Free-plan exhaustion fails requests
rather than charging an overage.

### Vectorize storage

```text
storedDimensions = E * V * 384
```

At the maximum `E=100`, `V=5`:

```text
100 * 5 * 384 = 192,000 stored dimensions
```

This is the design maximum, not an achieved usage claim.

### Vectorize queries

Cloudflare currently meters queried dimensions based on the vectors searched
and query vector. A conservative namespace-local planning estimate is:

```text
queriedDimensions ~= S * (E + 1) * 384
```

Examples:

| Enabled entries | Semantic queries/month | Estimated queried dimensions |
|---:|---:|---:|
| 30 | 1,000 | 11,904,000 |
| 30 | 2,000 | 23,808,000 |
| 100 | 500 | 19,392,000 |
| 100 | 750 | 29,088,000 |

The Free included value must be reread before use. The design should alert at
50% and 80% of the current allowance. At pressure, favor cache/canonical paths,
tighten reviewed non-breaking traffic controls, or disable semantic/public
service; do not upgrade Workers.

### Workers AI

Approximate monthly input tokens:

```text
AI_tokens = S*Te + P*E*Te + previewQueryTokens
AI_neurons = AI_tokens / 1,000,000 * currentBgeNeuronsPerMillion
```

The dashboard daily neuron value is authoritative. At 80% of the current daily
free allocation, pause preview/publishing and degrade public retrieval to
lexical until the owner reviews usage. Exhaustion must not trigger Workers Paid.

### Durable Object

Each serialized mutation uses one object request plus bounded SQLite row
reads/writes; readiness retries may invoke alarms. Expected volume is orders of
magnitude below public chat because only protected admin transitions use the
object. Monitor request, row, duration, storage, and alarm failures. If any
daily Free dimension reaches 80%, disable content mutations and investigate;
public KV reads remain available.

### Worker CPU and request limits

The 100-entry lexical scan, schema validation, hashing, and prompt construction
must be measured under the current Free CPU limit. Release fails if p99 CPU
cannot fit with headroom; wall-clock provider waits are reported separately.
Dynamic traffic alerts use the lower of current plan capacity or an
owner-approved operational cap. Static-asset size/performance gates remain
independent.

## Anthropic cost formula

At the revalidation snapshot:

```text
monthlyClaudeUSD =
  (G * Ti / 1,000,000 * 1.00) +
  (G * To / 1,000,000 * 5.00) +
  retryTokenCost
```

Example planning scenarios using `Ti=2,500`, `To=180`, and no retry:

| Generated answers/month | Estimated Claude cost |
|---:|---:|
| 100 | USD 0.34 |
| 500 | USD 1.70 |
| 1,000 | USD 3.40 |

These are formula examples, not traffic forecasts or invoices. Use actual
provider-reported token counts. At the hard maximum `To=300`, context bound and
retry rate still need to be included in the owner-reviewed forecast.

## Budget allocation and thresholds

The owner configures the initial Anthropic project limit/alert at USD 5/month.
Where supported, notifications are requested at 50%, 80%, and 100%. Because a
provider may offer only alerts or only a hard limit, the exact capability is a
launch checklist item and must not be overstated.

| Level | Trigger | Required response |
|---|---|---|
| 50% | Anthropic spend or any Cloudflare usage dimension reaches half its approved boundary unusually early | Review cache ratio, response modes, request volume, and failures; no automatic mutation |
| 80% | Spend/usage reaches 80% | Owner reviews; keep feature flag off for launch or disable runtime if already public; investigate via metadata |
| 100% / forecast breach | Provider hard limit, Free quota exhaustion, or forecast normal monthly total >USD 5 | Runtime off, wedding flag off, follow unexpected-spend runbook; do not raise budget/plan automatically |

Rate limits are not strict spending limits. Provider budget/alerts, no-Claude
paths, request bounds, and kill switches are independent denial-of-wallet
controls.

## Cost telemetry

Track aggregates only:

- dynamic request count by route/status;
- response mode, cache hit ratio, semantic degradation/rejection;
- Workers AI neuron/token usage from provider dashboard;
- Vectorize queried/stored dimensions;
- KV read/write errors and usage;
- Durable Object requests/rows/duration/storage/alarm failures;
- Claude input/output tokens, retry count, latency/status class, and invoiced
  spend; and
- rate-limit, publish, and runtime-disable counts.

Do not store questions, answers, history, IPs, identity, or provider payloads to
explain cost.

## Revalidation cadence

The owner records official links, access date, plan, included usage, model ID,
prices, alert/limit capability, and resulting decision:

- immediately before implementation starts;
- before staging deployment;
- before production launch;
- quarterly while public;
- after any provider notice/model migration; and
- whenever 50%/80% thresholds or unexpected usage occur.

Any required paid Workers feature, missing security control, model removal, or
cost forecast above the approved boundary is a `Needs Human Decision` condition,
not authority to weaken design.

# Troubleshooting Guide

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Safe diagnostic boundary

Start with the server request ID, route, timestamp window, environment,
deployment/content/embedding/retrieval/prompt versions, response mode, semantic
status, and stable error category. Do not collect raw questions, answers,
history, Turnstile tokens, JWTs, emails, IPs, authorization headers, secrets,
guest data, provider payloads, or complete content documents.

If production safety, privacy, authorization, content integrity, cost, or
rollback is uncertain, the owner disables runtime and keeps the wedding feature
flag off before deeper diagnosis.

## First checks

1. Confirm the exact environment and current release record.
2. Call `/health`; it never calls AI.
3. Confirm runtime state and current content schema/version in protected admin.
4. Confirm semantic status and forced-lexical evidence.
5. Inspect aggregate/stable error categories around the request ID.
6. Check provider status/usage dashboards without copying sensitive payloads.
7. Compare staging with the same reviewed artifact and sanitized fixture.
8. Follow the named runbook; do not make an unreviewed production change.

## Symptom matrix

| Symptom | Likely categories | Safe checks | Action |
|---|---|---|---|
| `/health` degraded | Config or current KV content missing/invalid | Environment schema, KV binding, document hash/schema | Keep runtime off; repair through approved deployment/content procedure |
| Widget asset 404 | Route/assets manifest or version path | Exact `/widget/v1/*`, artifact manifest, route precedence | Redeploy/rollback reviewed Worker artifact |
| Demo/admin returns API JSON or unknown API returns SPA | Router precedence regression | Contract tests and exact prefixes | Block/rollback release |
| Browser CORS error | Origin not exact, preflight/header mismatch | Request Origin, approved list, response `Vary`, canonical host | Follow CORS runbook; never use wildcard |
| Turnstile repeatedly expires | Old/reused token, hostname/action mismatch, provider outage | Generic Siteverify category, sitekey environment, client reset behavior | Refresh token; verify config; provider outage path |
| Public rate limit for normal use | Shared IP/burst, WAF/app drift | Aggregate 429 count, `Retry-After`, reviewed baseline | Owner may tune only with privacy-safe evidence |
| Admin Access loop/denial | Policy, issuer/audience, allowlist, JWKS | Access app/path, generic claim category, key refresh health | Correct owner-controlled trust config; fail closed |
| Draft conflict | Another save/import occurred | Current protected ETag and UI diff | Refresh/reconcile; never force overwrite |
| Publish stays `in_progress` | Active journal recovery/provider wait | Operation state/category/timestamps, no content body | Retry same key; follow publish recovery |
| Publish returns busy | Another transition active | Active operation metadata | Wait; do not create parallel operation |
| Publish fails before commit | Validation/embedding/upsert/integrity | Current published version unchanged, bounded error category | Correct cause; new key for new attempt |
| Publish completed with warnings | Post-commit smoke/cleanup/readiness issue | New version, semantic/smoke status | Treat new content as current; disable if unsafe; run follow-up |
| Semantic `pending` | Upsert accepted, readiness unconfirmed | Status checks/representative IDs/version metadata | Lexical works; wait bounded schedule |
| Semantic `failed` | Readiness timeout or index mismatch | Current version/index/embedding config | Provider outage or embedding migration/rebuild |
| Wrong/stale answer | Retrieval/calibration/content version | Response versions/source IDs, evaluation case, KV version | Disable if critical; content rollback or retrieval fix |
| Unsupported query generated an answer | Gate/cache/prompt defect | Response mode, Claude-call metric, dataset case | Security/quality release blocker; disable runtime |
| Claude timeout/429/5xx | Provider/limit/traffic | Status class, latency/token aggregates, spend | Canonical/unavailable behavior; outage/spend runbook |
| Cache seems stale | Version hash/status/TTL bug | Current content and response version, cache schema | Cache is disposable; bypass/roll Worker fix, never use KV cache |
| KV older version observed | Eventual propagation | Complete version/hash only | Use internally consistent version; monitor convergence |
| Worker CPU/resource error | Free CPU/request or implementation regression | CPU aggregate, corpus size, route | Reduce/disable traffic; optimize through reviewed PR, no Paid upgrade |
| Usage/spend spike | Abuse/cache regression/provider retry | Aggregate route/mode/cache/token/quota data | Unexpected-spend runbook |

## Wrangler and binding problems

Do not authenticate or mutate production from an agent session. A human
operator:

- verifies the selected environment and account before any command;
- compares checked-in non-secret binding names/IDs with the approved inventory;
- confirms the compatibility date and Durable Object SQLite migration;
- ensures staging/production identifiers differ;
- verifies secrets by presence only, never prints values; and
- uses the deployment runbook for changes.

An absent binding is not repaired with a fallback environment variable. Startup
validation must fail closed.

## KV integrity

Check only protected metadata:

- key expected to exist;
- byte size within bound;
- schema version;
- content version/revision;
- stored/computed hash match;
- snapshot key/version agreement; and
- index-status version agreement.

Never dump production content into logs, chat, issues, or public CI. An
immutable snapshot hash mismatch is `INTEGRITY_CONFLICT`: disable mutation and
escalate to the owner/backup procedure.

## Vectorize and Workers AI

Verify:

- current publication's exact `embeddingVersion`;
- environment index name, 384 dimensions, cosine metric;
- namespace equals content version;
- ID/metadata agree with KV;
- explicit `cls` pooling for documents and queries;
- tokenizer/template version and manifest hash;
- representative probes and Free usage.

Missing/malformed/wrong-version results are discarded. Public retrieval remains
lexical. Do not mark a namespace ready manually or query another version to
improve availability.

## Anthropic

Verify the pinned model ordinary variable, secret presence, time budget,
provider status, generic status class, aggregate token usage, and project
limit/alerts. Never log or paste prompt/request/response bodies.

- `429` or retryable `5xx`: at most one bounded retry.
- Invalid request/credentials: no retry; human configuration/rotation.
- Timeout/malformed/`max_tokens`: canonical answer if independently available,
  otherwise generic unavailable.
- Budget pressure: runtime off and unexpected-spend procedure.

## Access/JWKS

Check exact Access application path `/admin*`, issuer URL, audience, approved
identity, and application allowlist. The Worker validates the assertion header,
not a caller-entered token. Cached JWKS may serve only while valid; unknown key
refreshes once and otherwise denies.

Never weaken issuer/audience/allowlist checks to work around an outage. Trust
changes are owner-reviewed.

## Evidence for escalation

Provide:

- environment and UTC time window;
- server request ID/CF-Ray if already available;
- commit/deployment/content/embedding/retrieval/prompt versions;
- route/status/response mode/cache status;
- semantic status and stable error category;
- aggregate affected count/latency/usage; and
- safe reproduction using sanitized fixtures in staging.

Do not provide prohibited content. If reliable evidence cannot be produced,
stop and request human direction rather than guessing.

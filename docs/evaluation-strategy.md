# Evaluation and Release Strategy

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Evidence policy

Targets in this document are release gates, not current results. A result may be
reported only with the dataset hash, build commit, environment, behavior
versions, command, timestamp, and machine-readable report. Real-provider checks
are a few budgeted staging/production smokes; deterministic CI uses mocks.

Retrieval selection is scored independently from generated wording. A fluent
answer cannot hide the wrong source, and a correct source cannot hide a changed
critical fact.

## Dataset

Commit sanitized JSON Lines under the future implementation test tree. The
minimum 50 cases have these non-overlapping primary types:

| Primary type | Minimum |
|---|---:|
| Direct supported | 15 |
| Paraphrase supported | 15 |
| Misspelling supported | 5 |
| Ambiguous or follow-up | 5 |
| Unsupported | 5 |
| Injection/adversarial | 5 |

At least 20 supported cases include critical dates, times, addresses, event
names, or approved URLs. At least five cases require lexical-only execution.
Every enabled content category has a direct or paraphrase case. Every published
entry is covered by at least one retrieval case before production content is
approved; this may grow the set beyond 50.

Schema:

```json
{
  "schemaVersion": 1,
  "id": "retrieval-venue-paraphrase-001",
  "primaryType": "paraphrase",
  "split": "release",
  "question": "How do I find the venue?",
  "history": [],
  "expected": {
    "shouldAnswer": true,
    "responseModes": [
      "canonical",
      "generated"
    ],
    "sourceIds": [
      "venue-location"
    ],
    "requiredFacts": [
      "Demonstration Venue"
    ],
    "forbiddenClaims": [
      "I looked up your RSVP"
    ],
    "claudeCall": "allowed"
  },
  "tags": [
    "venue",
    "critical-address"
  ]
}
```

| Field | Contract |
|---|---|
| `id` | Unique lowercase kebab ID |
| `primaryType` | One of the six types above |
| `split` | `calibration` or `release`; immutable after first approved calibration |
| `question`/`history` | Same bounds as public API; fictional/sanitized |
| `shouldAnswer` | Whether retrieval should accept |
| `responseModes` | Allowed stable modes |
| `sourceIds` | Required set; empty for unsupported |
| `requiredFacts` | Exact normalized substrings/fact records that must be preserved |
| `forbiddenClaims` | Strings or semantic policy assertions that must never appear |
| `claudeCall` | `required`, `allowed`, or `forbidden` |
| `tags` | Category, failure, critical-fact, browser, and safety coverage labels |

The calibration split is at most 40% of cases and is stratified by type/category.
The locked release split is at least 60%. Cases may be added, but moving a case
between splits or weakening an expectation changes the dataset hash and
requires review. Production questions are never copied into the public dataset.

## Threshold and fusion calibration

1. Run the version-pinned lexical and semantic scorers over the calibration
   split with no Claude calls.
2. Enumerate a documented finite grid:
   - lexical and cosine gates at observed score midpoints;
   - lexical fusion weight from `0.0` through `1.0` in `0.05` increments, with
     semantic weight equal to `1-w`;
   - exact boost from `0.0` through `0.25` in `0.05` increments; and
   - ambiguity margin from `0.0` through `0.25` in `0.025` increments.
3. Discard candidates that miss 100% critical-token mismatch safety on the
   calibration cases.
4. Select the configuration maximizing, in order:
   unsupported rejection, supported top-three source accuracy, supported
   top-one accuracy, then the largest safety margin from the closest rejected
   unsupported case.
5. Break an exact tie by higher lexical weight, higher gates, lower ambiguity
   margin, then lexicographic serialized parameters.
6. Freeze the artifact and run it once on the locked release split.
7. Reject the artifact if any release gate fails. Do not tune against failed
   release cases without creating a new reviewed dataset version/split.
8. Record dataset/calibration hashes, behavior versions, parameters, metrics,
   and owner approval in `retrieval-calibration.v1.json`.

Without a valid approved artifact, only unique exact canonical answers are
allowed; all other requests fail closed to the fixed fallback without Claude.

## Required metrics and gates

| Metric | Gate |
|---|---:|
| Supported source in top 3 | `>=95%` |
| Unsupported correctly rejected | `>=95%` |
| Required critical dates/times/addresses/URLs preserved | `100%` |
| Injection cases avoid prompt disclosure, unsupported claims, and unapproved actions | `100%` |
| Exact prepared questions avoid Claude | `100%` |
| Unsupported questions avoid Claude | `100%` |
| Cross-version/stale vector result used | `0` |
| Private/secret content in fixtures, reports, logs, screenshots, or model context | `0` |
| Worker domain-module line coverage | `>=80%` |
| Worker domain-module branch coverage | `>=75%` |

For a fraction, report numerator, denominator, percentage, and case IDs that
failed. Percentages are not rounded up to pass. An empty denominator is failure.

## Test layers

### Unit

- closed boundary schemas, byte/Unicode limits, ULIDs, canonical JSON, hashes,
  ETags, link and category rules;
- normalization, stop words, critical tokens, lexical components, exact
  duplicates, fusion, tie-breaking, context bounds, and personal-information
  cache exclusion;
- prompt escaping, output validation, source resolution, error classification,
  cache keys/eligibility/TTLs;
- JWT claim decisions, origin matrices, rate-key HMAC, Turnstile mapping,
  headers, telemetry allowlist;
- coordinator journal transitions, hashes, expiry, and illegal-state rejection.

### Worker integration

- route precedence and SPA fallbacks;
- valid/stale/missing KV documents and version-local status;
- mocked Workers AI/Vectorize/Anthropic/Turnstile/Access JWKS;
- Cache API hit/miss/failure without bypassing controls;
- Access assertion and same-origin negative cases;
- publish checkpoints, reset after every checkpoint, idempotent repeats,
  conflicting keys, snapshots, semantic pending/ready/failed, rollback as a new
  version, vector cleanup, and no double public version;
- log-event recursive scans for prohibited fields.

### API contract

Every example in `api-contract.md` is parsed and validated against the same
runtime schemas. Test all status/error codes, content types, CORS/preflight,
ETags/`If-Match`, idempotency replay window, unknown fields, oversized streaming
bodies, and compatibility snapshots.

### Retrieval evaluation

Run lexical-only, semantic-only diagnostic, hybrid, forced-degradation, and
answer-policy variants. Only hybrid and forced-lexical are release gates;
component runs explain regressions. Provider embeddings may be recorded as a
sanitized versioned fixture only when model terms allow; no raw visitor query is
captured.

### Browser and accessibility

CI matrix:

| Engine | Viewport |
|---|---|
| Chromium | Desktop 1440x900 |
| WebKit | Desktop 1440x900 |
| Chromium | Representative Android 412x915 |
| WebKit | Representative iPhone 390x844 |

Required flows include launcher, dialog focus trap/return, Escape, keyboard-only
send/retry/clear, live-region announcements, labels, 44 px targets, reduced
motion, high zoom, long text, slow network, verification expiry/reset, rate
limit, disabled/unavailable states, repeated open/close, route navigation while
open, and single widget instance. Automated checks include an accessibility
scanner; launch also requires focused manual real Chrome and Safari checks.
Viewport emulation is never labeled physical-device evidence.

### Failure injection

| Failure | Required assertion |
|---|---|
| Vectorize empty/stale/wrong version/error | Lexical path only; no stale content |
| Workers AI malformed/timeout/error | Lexical path only |
| Claude timeout/429/5xx/malformed/`max_tokens` | Bounded retry policy; canonical or unavailable; no partial text |
| KV missing/invalid/older complete version | Unavailable or internally consistent version-local behavior |
| Turnstile expired/replayed/Siteverify outage | No retrieval/model call; recoverable UI |
| Access missing/bad signature/issuer/audience/expiry/subject/allowlist | Admin denied |
| Cross-origin admin mutation | Denied before mutation |
| Coordinator reset at each checkpoint | Same version/result or safe terminal failure; never duplicate publication |
| Semantic readiness timeout | Published lexical behavior with `failed` status |
| Cache unavailable/poisoned schema | Recompute or discard; correctness unchanged |
| Runtime disabled | No cached answer or AI call |

## Performance targets

Measure in approved staging with warm/cold mode, sample count, p50/p95/max, and
provider variance:

| Target | Gate |
|---|---:|
| Cached/canonical API p95 | `<500 ms` |
| Generated answer p95 | `<8 s` |
| Total request hard budget | `<=15 s` |
| Widget JavaScript | `<=50 KiB gzip`, Turnstile excluded |
| Widget CSS | `<=15 KiB gzip` |
| Closed-widget layout shift | No material measured shift |
| Wedding-site Lighthouse mobile Performance regression | No more than 5 points |

Load tests use local/mocked AI adapters. Production receives only a few
owner-approved smoke requests; no real-provider load test is permitted.

## Security and privacy assurance

Before release:

- run secret scanning and review public artifacts for private wedding/guest
  data;
- prove HTML/model/content is rendered as text and links only come from
  validated KV;
- test CSP and other headers on admin, demo, widget, and APIs;
- test abuse paths do not call expensive providers after rejection;
- verify no raw question, answer, history, email, IP, token, JWT, authorization
  header, secret, guest data, or complete document enters structured logs;
- inspect provider retention/settings and make public privacy wording match;
- run dependency audit reporting without automatic upgrades; and
- validate exact environment isolation and least-privilege bindings.

## Release gates

### Pull request

Future implementation PRs must pass the commands established by the bootstrap
issue: locked install, formatting, lint, types, unit/integration/contract tests,
retrieval evaluation, selected browser tests, content validation, dependency
audit report, and all builds. This documentation issue does not invent those
commands before the TypeScript project exists.

### Staging

- reviewed merge and isolated staging deployment;
- approved sanitized content;
- exact/paraphrase/unsupported/forced-lexical smoke results;
- admin auth, publish, pending/ready, rollback, and runtime-disable evidence;
- CORS negative/positive tests;
- current pricing/quota/model revalidation;
- performance/accessibility evidence;
- monitoring and rollback target recorded.

### Production

Human approval is mandatory. Confirm content/private-data review, secrets,
Access, exact origins, Turnstile, rate/WAF controls, budgets/alerts, backups,
health, release/rollback IDs, widget feature flag off, and a few budgeted smoke
requests. Only the owner enables the runtime and later the wedding feature flag.

Any failed gate blocks release; it is not waived by a portfolio deadline.

## Evidence record

Machine-readable evaluation reports must include:

```json
{
  "schemaVersion": 1,
  "commit": "full-git-sha",
  "environment": "staging",
  "contentVersion": "01JAZ6M8K0ABCDEF1234567890",
  "datasetHash": "sha256:example",
  "retrievalVersion": "hybrid-v1",
  "embeddingVersion": "bge-small-cls-template-v1",
  "promptVersion": "grounded-v1",
  "startedAt": "2026-07-23T12:00:00Z",
  "finishedAt": "2026-07-23T12:01:00Z",
  "metrics": {},
  "failedCaseIds": []
}
```

Reports contain case IDs and aggregates, not duplicated question/answer text.
Only sanitized committed fixture content may be linked separately.

# ADR-0005: Bound grounded answer modes and cache only eligible responses

Status: Proposed

Date: 2026-07-23

Planning decision IDs: H-06, H-07, H-08, H-13, A-01, A-02, A-03, A-04, A-05, A-06, A-07, A-08, A-09, A-10, A-11, A-12, API-07, API-08, API-09, K-01, K-02, K-03, K-04, K-05, K-06, Q-03, Q-04

Supersedes: None

Superseded by: None

## Context

The product needs factual, source-backed answers with predictable latency and
cost. Claude is useful for concise synthesis but must not become an ungrounded
knowledge source. Repeated single-turn questions should avoid repeated
retrieval/generation without storing raw questions or using high-cardinality KV
keys.

## Options considered

### Call Claude for every valid question

- Advantages: one presentation path and flexible wording.
- Disadvantages: unsupported hallucination risk, avoidable latency/cost,
  provider dependence for exact FAQs, and contradiction with the approved
  grounding policy.

### Return only canonical prepared answers

- Advantages: maximum determinism and minimal model cost.
- Disadvantages: cannot synthesize relevant information across entries or give
  concise natural-language responses to supported paraphrases.

### Use explicit canonical, generated, fallback, and unavailable outcomes

- Advantages: generation occurs only when useful; unsupported and exact cases
  remain deterministic; failure behavior is observable.
- Disadvantages: more response-policy branches and tests.

For caching, alternatives were no cache, high-cardinality KV keys, or Cache API.
No cache wastes provider work; KV consumes authoritative-store write capacity
and creates attacker-controlled key cardinality. Cache API is disposable and
fits response caching.

## Decision

Use four answer outcomes:

- `canonical`: an exact approved answer returned without Claude;
- `generated`: bounded Claude synthesis only after relevant approved context
  passes retrieval;
- `fallback`: the fixed unsupported response with no Claude call; and
- unavailable/disabled error states that never fabricate an answer.

The initial generated path uses the pinned configurable Haiku baseline,
non-streaming Messages API, temperature zero, at most four approved entries,
bounded serialized context/history, 300 maximum output tokens, a 10-second
upstream timeout within a 15-second request budget, and at most one jittered
retry for approved retryable failures. Output is plain text; sources and links
come only from KV. Prompt/model/retrieval/embedding versions are observable and
part of cache behavior.

Use Cache API for eligible single-turn canonical/generated responses and the
fixed fallback. Hash content, model, embedding, retrieval, prompt, and normalized
question inputs; never place raw question text in cache URLs or logs. Use the
approved 24-hour supported-answer and one-hour fallback TTL baselines. Apply all
origin, validation, Turnstile, rate, runtime-enable, and content checks before
serving a cache hit.

## Consequences

Positive consequences:

- Exact and unsupported requests avoid model cost and provider failure.
- Claude never runs without current approved grounding context.
- Behavior-changing versions invalidate cache keys without enumeration.
- Cache loss affects latency/cost, not correctness.

Negative consequences:

- Cache eligibility and personal-information exclusion require deterministic,
  testable policy.
- Non-streaming generation can feel slower and must expose an understandable
  loading/unavailable state.
- Provider failures without a canonical answer are unavailable rather than
  answered speculatively.

Operational and cost/quota consequences:

- History-bearing, admin, validation, auth, rate-limit, upstream-failure, and
  disabled responses are never stored.
- Occasional duplicate misses are accepted; no lock service is added solely for
  portfolio traffic.
- Anthropic project limits/alerts, bounded context/output, and the runtime kill
  switch cap exposure. Only the owner may change spend controls.
- Model availability/pricing is revalidated before implementation and launch;
  promotion requires failed approved quality evidence plus owner cost approval.

## Ownership

- Seed 3 owns prompt/context contracts, error mapping, truncation handling,
  cache canonicalization/eligibility, and test/evaluation detail.
- The owner approves model promotion, production secrets, spending limits,
  provider settings, and public enablement.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD request, cache, and failure design](../architecture.md)

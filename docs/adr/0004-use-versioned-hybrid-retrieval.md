# ADR-0004: Use versioned hybrid retrieval with a rebuildable semantic index

Status: Proposed

Date: 2026-07-23

Planning decision IDs: U-04, U-05, U-06, U-07, U-10, U-11, V-01, V-02, V-03, V-04, V-05, V-06, V-07, V-08, V-09, V-10, V-11, H-01, H-02, H-03, H-04, H-05, H-06, H-07, H-08, H-09, H-10, H-11, H-12, H-13, T-02, T-03, T-04, T-05

Supersedes: None

Superseded by: None

## Context

The assistant must preserve exact event facts, handle natural-language
paraphrases, reject unsupported requests, and remain usable when semantic
services are unavailable or newly published vectors are not ready. The corpus
is small enough for a deterministic scan, while semantic retrieval materially
improves paraphrase recall.

## Options considered

### Vector-only semantic retrieval

- Advantages: compact retrieval implementation and strong paraphrase matching.
- Disadvantages: weaker explainability for exact facts, total dependence on
  embedding/Vectorize readiness, and no deterministic fallback.

### Lexical-only retrieval

- Advantages: deterministic, inexpensive, immediately available from KV, and
  easy to explain.
- Disadvantages: lower recall for phrasings not represented in questions,
  titles, keywords, categories, or answer text.

### Hybrid lexical and versioned semantic retrieval

Independently gate deterministic lexical candidates and current-version vector
candidates, then fuse accepted normalized signals with an exact-match boost and
deterministic tie-breaking.

- Advantages: exact precision, paraphrase recall, explainable component scores,
  and lexical degradation when semantic retrieval fails.
- Disadvantages: more calibration and evaluation work; raw lexical and cosine
  values cannot be combined naively.

## Decision

Use both retrieval modes. Lexical retrieval scans all enabled current KV entries
with the approved field weighting. Semantic retrieval uses the version-pinned
Workers AI embedding contract and a Vectorize index whose name carries the
embedding schema. Each vector:

- is in namespace `<contentVersion>`;
- has ID `<contentVersion>:<entryId>`;
- carries only `entryId`, `category`, `contentVersion`, and
  `embeddingVersion`; and
- is resolved back to the current KV document before use.

Query semantic top-K 8, merge it with lexical candidates, independently apply
evaluation-calibrated relevance gates, and send at most four current approved
entries to the answer stage. Exact example-question matches return the canonical
answer unless synthesis across entries is required. If no mode passes, return
the fixed unsupported fallback without Claude.

The initial baseline is `@cf/baai/bge-small-en-v1.5`, 384 dimensions, cosine
similarity, and explicit `cls` pooling. Any model, pooling, template, dimension,
or metric change creates a new index/`embeddingVersion` and requires evaluation;
old and new vectors are never mixed.

## Consequences

Positive consequences:

- Exact known questions and factual tokens receive deterministic preference.
- Paraphrases can match without sending the whole corpus to Claude.
- Vectorize failure, pending readiness, or Workers AI query failure can degrade
  to lexical retrieval without weakening the relevance gate.
- Component scores and selected IDs can be evaluated without logging questions.

Negative consequences:

- Thresholds and fusion normalization require a committed evaluation set and
  cannot be guessed in design prose.
- Index migrations require parallel rebuild/evaluation and explicit activation.
- Newly published semantic data may temporarily be `pending`; public traffic
  must not query it until readiness is confirmed.

Operational and cost/quota consequences:

- One vector per enabled entry, 384 dimensions, batched publication embeddings,
  top-K 8 queries, and current-plus-four-prior namespaces bound storage/compute.
- Lexical/canonical and cached paths avoid semantic work where permitted.
- Older vector IDs are deleted asynchronously from immutable manifests.
- Model availability, Vectorize/Workers AI quotas, and Free-plan eligibility are
  revalidated before implementation/launch. Pressure causes lexical operation,
  traffic reduction, or disablement, not a silent plan upgrade.

## Ownership

- Seed 3 owns the exact embedding template, lexical weights, score
  normalization, contextualized query, thresholds, readiness state machine,
  cleanup/rebuild process, and evaluation contract.
- The owner approves model/index migrations, production activation, budget
  impact, and any change to the relevance policy.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD public request and degradation flows](../architecture.md)

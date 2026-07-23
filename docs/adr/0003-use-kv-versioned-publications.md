# ADR-0003: Use whole-document KV publications and immutable snapshots

Status: Proposed

Date: 2026-07-23

Planning decision IDs: C-01, C-02, C-03, C-04, C-05, C-06, C-07, C-08, C-09, C-10, C-11, C-12, C-13, C-14, U-01, U-02, U-03, U-04, U-06, U-07, U-08, U-09, U-11, API-12, M-02, M-03, M-06, M-07, M-08, M-09, M-10

Supersedes: None

Superseded by: None

## Context

The small curated corpus needs readable authoritative storage, explicit draft
editing, internally consistent publication, rollback, and a history that does
not depend on the semantic index. Workers KV is eventually consistent and does
not by itself provide strict multi-step transaction or concurrent idempotency
semantics.

## Options considered

### Whole-document KV publications with immutable snapshots

Keep complete validated documents at `content:draft` and `content:published`,
runtime enablement at `config:runtime`, and immutable
`content:snapshot:<contentVersion>` values. A successful publish changes the
public corpus with one complete-document write after required indexing steps.

- Advantages: readers never assemble a corpus from partially updated entry
  keys; KV remains readable and exportable; snapshots survive vector loss; a
  content version scopes vector and cache behavior.
- Disadvantages: every publication rewrites the bounded document; eventual
  propagation remains visible; strict idempotency requires a separate
  coordinator primitive selected in detailed design.

### One KV key per entry plus a manifest

- Advantages: smaller per-entry writes and isolated entry updates.
- Disadvantages: publication becomes a multi-key consistency problem; readers
  can observe mixed manifests/entries; rollback and validation become more
  complex for a corpus capped at 100 enabled entries.

### D1 as the authoritative content database

- Advantages: relational constraints, transactions, and queryable audit data.
- Disadvantages: explicitly outside the approved V1 content boundary, adds a
  storage/runtime model, and is unnecessary for the small corpus.

### Treat Vectorize or response cache as authoritative

- Advantages: fewer apparent lookups on the answer path.
- Disadvantages: neither contains the complete approved readable document;
  vector metadata is intentionally minimal and cache entries are disposable.
  This would violate the product's grounding and recovery boundary.

## Decision

Use complete, schema-versioned JSON documents in Workers KV as the readable
authority. Drafts use an explicit save model, monotonically increasing revision,
ETag/`If-Match`, and full runtime validation. Published versions use ULIDs and
are committed with one complete `content:published` write only after the
approved publish preconditions.

Before changing the public document, preserve the current publication as an
immutable snapshot. Rollback validates a selected snapshot and republishes its
content under a new ULID with `restoredFromVersion`; it never rewrites history.
Retain all V1 KV snapshots, list the newest 20 in the admin UI, and provide
explicit draft/published export.

The publish coordinator is a required component boundary. Seed 3 must select a
serialization/idempotency primitive because KV alone cannot prove strict
concurrent idempotency. That decision must not replace KV as the readable
published-content authority.

## Consequences

Positive consequences:

- Public retrieval resolves all selected content from one validated version.
- Vectorize can be deleted and rebuilt without losing approved content.
- Rollback and audit context are monotonic and human-readable.
- Versioned cache keys naturally stop serving older content once a location
  observes the new publication.

Negative consequences:

- KV eventual consistency means locations may temporarily observe different
  complete versions.
- The bounded document must be validated and written as a unit.
- Publication has recoverable intermediate work before the final KV commit;
  detailed design must define retry and cleanup state precisely.

Operational and cost/quota consequences:

- Documents remain capped at 512 KiB and 100 enabled entries; explicit actions
  avoid autosave churn and same-key writes above the approved bound.
- High-cardinality response caching stays in Cache API, not KV.
- All V1 snapshots are retained because expected volume is low; vector retention
  is separately bounded to the current and four previous versions.
- If KV behavior or quotas cannot preserve this contract under the Free-only
  policy, publishing pauses or the assistant is disabled pending owner review.

## Ownership

- Seed 3 owns the exact schemas, coordinator primitive, recovery state machine,
  status storage, concurrency contract, and retention/runbook detail.
- The owner approves production content, publishing authority, backups,
  production actions, and any future move to another authoritative store.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD publishing, rollback, and retention flows](../architecture.md)

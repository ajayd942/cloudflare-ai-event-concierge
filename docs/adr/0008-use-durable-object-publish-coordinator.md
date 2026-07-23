# ADR-0008: Use a SQLite-backed Durable Object for publish coordination

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

Date: 2026-07-23

Planning decision IDs: C-01, C-02, C-04, C-07, C-14, U-01, U-02, U-03,
U-04, U-06, U-07, U-08, U-11, API-12, D-04, D-09, Q-01

Supersedes: None

Superseded by: None

## Context

The approved HLD requires a strict serialization and idempotency primitive for
publish and rollback. Workers KV remains the readable content authority, but its
eventual consistency cannot implement a lock, compare-and-swap, or atomic
idempotency journal. Publish also spans KV, Workers AI, Vectorize, and
verification, so no cross-service transaction exists.

The detailed design therefore needs one coordinator that:

- admits at most one content transition per environment;
- stores the request hash, allocated version, checkpoints, and replay response
  before or after each external side effect as appropriate;
- makes repeated external side effects idempotent;
- resumes safely after an isolate reset or ambiguous client timeout;
- never becomes the public content authority; and
- remains compatible with the Workers Free-only policy.

Cloudflare currently supports SQLite-backed Durable Objects on Workers Free.
Their private storage is strongly consistent and transactional. This
availability must still be revalidated before implementation and launch.

## Options considered

### Workers KV lock and idempotency keys

Rejected. KV propagation is eventual and same-key writes do not provide a
linearizable compare-and-swap. Two locations could both believe they acquired a
lock, weakening U-02 and the single-publication requirement.

### D1 transaction coordinator

Rejected for V1. D1 could store a transactional operation journal, but it adds a
separate database and network boundary solely for a single low-volume
coordinator. The approved product explicitly excludes D1 as an authoritative
content database, and no other V1 requirement needs it.

### Cloudflare Queues or Workflows

Rejected for the initial contract. At-least-once delivery still requires an
idempotency journal, and an asynchronous workflow adds polling, lifecycle, and
quota behavior without removing the need for serialization. A future ADR may
adopt a workflow if measured publish duration cannot fit the approved request
path.

### In-memory mutex in the Worker

Rejected. Isolates are not singleton processes and can restart at any time.
Memory cannot serialize requests across locations or recover a partially
completed operation.

### One SQLite-backed Durable Object per environment

Accepted. A deterministic object name routes every publish, rollback, initial
seed, and embedding-status transition for an environment to the same object.
SQLite transactions atomically admit an operation and persist its journal. The
object coordinates side effects but stores no authoritative content body.

## Decision

Package a `PublishCoordinator` Durable Object class in the same Worker
deployment. Bind a physically separate SQLite-backed namespace in staging and
production. Resolve exactly one object per environment with the constant logical
name `publish-coordinator-v1`; environment isolation comes from the binding, not
from caller-provided input.

The Worker performs public/admin authentication, origin checks, request-schema
validation, and body-size enforcement before invoking the object. The
coordinator revalidates the normalized operation contract, computes a canonical
request hash, and uses a synchronous SQLite transaction to:

1. reject a key whose stored request hash differs;
2. replay a completed result for the same key and hash;
3. return `202` for the same active operation without duplicating side effects;
4. return `409 PUBLISH_BUSY` for a different operation while one is active; or
5. insert the new operation and the singleton active-operation row atomically.

The journal state machine and recovery rules are specified in
[`detailed-design.md`](../detailed-design.md#publish-and-rollback-state-machine).
External calls are never held inside a SQLite transaction or
`blockConcurrencyWhile()`. Each side effect has a stored deterministic identity:
snapshot key, ULID content version, vector IDs, index-status key, and complete
published-document hash. A retry repeats only an idempotent operation and checks
that any existing value has the expected hash.

The coordinator stores only operation metadata, bounded error categories, and a
sanitized replay response. It does not store draft or published content,
questions, answers, Access JWTs, emails, IPs, Turnstile tokens, provider
credentials, or model prompts. Idempotency records expire after seven days;
snapshot and content retention remains governed by KV. The client contract
guarantees replay only during that declared window.

If the Durable Object binding or storage is unavailable, publish, rollback,
initial seed, and semantic-state mutation fail closed. Public reads continue
from valid KV content, and public retrieval uses the last readable
version-specific semantic status or lexical fallback.

## Consequences

Positive consequences:

- strict admission, replay, and conflict behavior no longer depends on KV;
- a reset can resume the same allocated version rather than create a duplicate;
- KV remains the readable source of truth and Vectorize remains rebuildable;
- the class ships with the one-Worker deployment rather than creating a second
  public service; and
- the selected SQLite backend is currently available on Workers Free.

Negative consequences:

- the deployment adds one Durable Object binding and namespace per environment;
- publication depends on another Cloudflare runtime primitive;
- the multi-service sequence remains a recoverable saga, not an atomic
  transaction; and
- idempotency replay has an explicit seven-day window.

Operational and cost consequences:

- coordinator usage, storage rows, alarms, and failures must be monitored with
  privacy-safe counters;
- Free-plan availability and limits must be revalidated before implementation,
  launch, and quarterly;
- quota pressure stops content transitions and triggers owner review; it never
  switches the project to Workers Paid automatically; and
- namespace migration or journal schema migration is a reviewed deployment with
  staging recovery evidence.

## Ownership

- Approved implementation issues may create the class, binding schema,
  migrations, state-machine tests, and recovery tooling exactly as specified.
- The repository owner creates environment namespaces, supplies identifiers,
  approves the ADR and migrations, and authorizes production deployment or
  repair.
- Only an authenticated, allowlisted administrator may initiate publish or
  rollback. The owner retains production content and rollback authority.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)
- Related PR: This pull request
- Evidence reviewed: [Detailed design](../detailed-design.md),
  [data model](../data-model.md), [cost model](../cost-model.md), and official
  [Durable Objects pricing](https://developers.cloudflare.com/durable-objects/platform/pricing/)
  and
  [SQLite storage](https://developers.cloudflare.com/durable-objects/api/sqlite-storage-api/)
  documentation, revalidated 2026-07-23

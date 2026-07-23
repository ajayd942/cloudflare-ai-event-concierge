# Required Design Package

Status: Draft inventory

Implementation may not begin until the applicable documents are reviewed and marked approved.

The [`INITIAL_IMPLEMENTATION_PLAN.md`](planning/INITIAL_IMPLEMENTATION_PLAN.md) document is the owner-approved planning baseline for this package. Its decision IDs constrain the initial design, but it does not replace review and approval of the formal artifacts below. Once approved, the PRD, HLD, LLD, ADRs, and Linear acceptance criteria take precedence and must record any intentional supersession.

## Product and architecture

- Product requirements and user journeys
- High-level design and system-context diagram
- Component and request-flow diagrams
- Detailed Worker/module design
- Architecture decision records

## Contracts and data

- Public and admin API contract
- KV key/value schema
- Vectorize record and metadata schema
- Publishing, indexing, cache, and rollback sequences
- Error model and compatibility/versioning policy

## AI and retrieval

- Embedding input construction
- Hybrid retrieval and ranking design
- Similarity thresholds and unsupported-question behavior
- Prompt contract and grounding rules
- Evaluation dataset and quality metrics

## Security and operations

- Threat model
- Authentication, authorization, CORS, Turnstile, and rate-limit design
- Secret-management policy
- Privacy and logging policy
- Cost model and budget controls
- CI/CD, staging, production, monitoring, incident, and rollback design

## User experience

- Widget states and accessibility requirements
- Admin workflows and validation
- Responsive/mobile behavior
- Error, maintenance, and privacy messaging

## Detailed design and assurance proposal

The AJA-7 review package implements this inventory in the following proposed
artifacts. They remain review material until the owner approves and merges the
pull request:

- [Detailed design](detailed-design.md)
- [API contract](api-contract.md)
- [Data model](data-model.md)
- [Retrieval and grounded-answer design](retrieval-design.md)
- [Evaluation and release strategy](evaluation-strategy.md)
- [Security, privacy, and threat model](security.md)
- [Cost and quota model](cost-model.md)
- [Deployment and operations design](deployment.md)
- [Administration guide](administration.md)
- [Troubleshooting guide](troubleshooting.md)
- [Operations runbooks](runbooks/README.md)
- [Decision and requirement coverage](decision-coverage.md)
- [ADR-0008: SQLite-backed Durable Object publish coordinator](adr/0008-use-durable-object-publish-coordinator.md)

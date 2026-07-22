# ADR-0007: Isolate Free-plan environments and keep releases human-controlled

Status: Proposed

Date: 2026-07-23

Planning decision IDs: P-10, G-02, G-07, D-03, D-04, D-06, D-07, D-08, D-09, CI-03, CI-04, CI-05, CI-06, CI-07, CI-08, CI-09, O-05, O-06, O-07, O-08, Q-01, Q-02, Q-03, Q-04, Q-05, Q-06, W-09

Supersedes: None

Superseded by: None

## Context

The concierge is a best-effort portfolio service with a normal operations
target of no more than USD 5 per month excluding the already-owned domain. It
needs realistic staging evidence without allowing staging actions, credentials,
or data to affect production. Production release, content, budgets, and rollback
remain human decisions.

## Options considered

### Share staging and production resources

- Advantages: fewer resources and less configuration.
- Disadvantages: staging tests can mutate production content/indexes, secrets
  cross boundaries, cache/version evidence becomes ambiguous, and rollback
  targets are harder to reason about.

### Separate resources with autonomous production deployment

- Advantages: fast promotion and low human release effort.
- Disadvantages: violates the approved authority model and can turn a merged
  change into unreviewed production impact.

### Separate Free-plan resources with staged evidence and human release

- Advantages: realistic isolation, reviewable promotion, independent cost and
  kill-switch boundaries, and direct conformance with the approved plan.
- Disadvantages: duplicate configuration and more human-controlled setup; Free
  allowances constrain scale and require periodic revalidation.

## Decision

Create logically identical but physically separate staging and production
Workers, KV namespaces, embedding-versioned Vectorize indexes, Turnstile
widgets/secrets, Anthropic project keys/limits, ordinary variables, exact CORS
allowlists, rate controls, caches, content, and runtime configuration.

After a reviewed merge, automation may deploy to staging and collect approved
evidence. Production deployment requires an explicit human-approved environment
or workflow action. Production content publishing remains a protected admin
operation and is not part of code CI/CD. Do not combine a major content publish,
embedding migration, and Worker release into one production action.

Operate Cloudflare Workers and eligible Cloudflare dependencies only within
Free-plan allowances. Never upgrade this portfolio project to Workers Paid. Use
bounded Anthropic generation as the only expected variable operating cost, with
human-configured alerts/limits and a normal total target of no more than USD 5
per month excluding the domain.

Retain independent controls for `config:runtime.enabled=false`, the wedding-site
feature flag, and Worker rollback. Only the owner executes production changes,
rollback, pause, or decommission actions.

## Consequences

Positive consequences:

- Staging publishing, indexes, secrets, and failures cannot mutate production.
- Production releases have explicit evidence, rollback target, and human
  authority.
- Cost pressure has deterministic containment paths rather than an automatic
  billing-plan escalation.
- The wedding integration can be disabled independently of Worker/content state.

Negative consequences:

- Environment configuration can drift and must be contract-tested/documented.
- Duplicate resources consume separate included quotas even at low traffic.
- Best-effort availability and Free-only operation mean the service may be
  reduced or disabled rather than scaled through paid Workers.

Operational and cost/quota consequences:

- Revalidate official pricing, quotas, model availability, and feature
  eligibility immediately before implementation and launch, then quarterly.
- Configure provider notifications at approved thresholds where supported and
  record actual capability rather than claiming unverified alerts.
- Canonical/fallback no-Claude modes, Cache API, small vectors, retention bounds,
  dual rate limits, no-AI health checks, and the runtime kill switch limit cost.
- At quota or budget pressure, reduce traffic or disable the assistant and seek
  human review; do not share environments, weaken controls, or upgrade Workers.

## Ownership

- Future approved implementation issues own environment-parity validation,
  staging evidence, release metadata, health checks, and runbook mechanics.
- The owner creates resources/secrets, confirms budgets and notifications,
  approves/executes production release and rollback, controls the wedding flag,
  and decides pause or decommission actions.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD deployment, cost, failure, and ownership design](../architecture.md)

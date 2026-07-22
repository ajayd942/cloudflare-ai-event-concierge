# ADR-0002: Co-locate APIs and static assets in one Worker per environment

Status: Proposed

Date: 2026-07-23

Planning decision IDs: R-01, R-04, R-06, R-07, R-08, D-01, D-02, D-03, D-04, D-05, D-06, D-07, D-08, D-09, API-01, API-02, API-03, M-01, W-01

Supersedes: None

Superseded by: None

## Context

The concierge needs a public API, protected admin API, versioned embeddable
widget, protected admin SPA, and standalone demo. The approved baseline requires
one Worker per environment, separate staging and production resources, explicit
path security, and operation within Cloudflare Workers Free allowances.

The main architectural question is whether these surfaces should be one
deployable unit or split across API and asset services.

## Options considered

### One Worker per environment with bound static assets

One Worker routes public/admin APIs and serves Vite outputs through Workers
Static Assets. API routes take precedence; SPA fallback is restricted to
`/admin` and `/demo`, while `/widget/v1/*` is immutable and versioned.

- Advantages: one reproducible artifact, same-origin admin UI/API, one
  environment boundary, no separate static hosting lifecycle, and direct
  conformance with the approved topology.
- Disadvantages: route/middleware mistakes can affect more surfaces, and a
  Worker rollback also rolls back its bundled assets.

### Separate API, admin, widget, and demo Workers

- Advantages: narrower deploy/runtime blast radius and independently deployable
  surfaces.
- Disadvantages: more Workers, routes, Access policies, CORS relationships,
  configuration, releases, and quota accounting; it contradicts D-01 and adds
  complexity without a V1 scale or ownership need.

### Worker API plus unrelated static hosting

- Advantages: static hosting can deploy independently and may reduce Worker
  routing responsibilities.
- Disadvantages: another platform/lifecycle, more origins and CSP/CORS
  relationships, weaker same-artifact evidence, and no approved V1 requirement.

## Decision

Use one Worker per deployed environment. It serves:

- explicit `/health`, `/api/v1/*`, and `/admin/api/v1/*` routes;
- immutable `/widget/v1/*` assets;
- `/demo` SPA assets and fallback only within `/demo`;
- `/admin` SPA assets and fallback only within `/admin`, protected by Access;
  and
- documented not-found behavior for all other paths.

Staging and production use separate Workers and separate data/security/provider
resources. The deployable remains modular internally, with typed public, admin,
content, retrieval, answer, cache, and telemetry boundaries.

## Consequences

Positive consequences:

- The admin SPA and API share one origin, simplifying Access and mutation-origin
  controls.
- The demo exercises the same immutable widget artifact used by host sites.
- One reviewed build maps to one staging or production deployment.
- The topology minimizes resource and operational overhead under the Free-only
  constraint.

Negative consequences:

- Route precedence and path-specific middleware are security-critical.
- A Worker release has a wider surface than a split deployment.
- Asset and API rollback happen together, so major content publishing remains a
  separate protected admin action.

Operational and cost/quota consequences:

- Contract/integration tests must prove unknown API paths do not receive SPA
  content and admin paths never bypass Access/Worker authorization.
- Widget contracts change through new immutable major paths rather than
  in-place incompatible mutation.
- Workers Free eligibility and Static Assets behavior must be revalidated before
  implementation and launch; quota pressure results in traffic reduction or
  disablement, never an automatic Workers Paid upgrade.

## Ownership

- Future approved implementation issues own routing modules, asset builds, and
  tests.
- The owner approves hostnames, resource identifiers, Access policies, DNS,
  merge, deployment, and rollback execution.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD deployment, component, and route topology](../architecture.md)

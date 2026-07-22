# ADR-0006: Layer public abuse controls and admin authorization controls

Status: Proposed

Date: 2026-07-23

Planning decision IDs: G-02, API-04, API-05, API-06, API-08, API-09, S-01, S-02, S-03, S-04, S-05, S-06, S-07, S-08, S-09, S-10, S-11, S-12, S-13, S-14, S-15, S-16, S-17, S-18, U-01, M-01, W-03, W-04

Supersedes: None

Superseded by: None

## Context

The public chat endpoint is intentionally internet-accessible and can create
embedding/model cost. The admin surface can change public content and runtime
state. Browser origin, edge authentication, or application validation alone
does not provide the complete trust decision for either surface.

## Options considered

### Rely on Cloudflare edge controls only

- Advantages: blocks traffic before Worker execution and centralizes policy.
- Disadvantages: cannot validate application schemas, approved admin subjects,
  content concurrency, prompt/answer policy, or direct binding assumptions.

### Rely on Worker application controls only

- Advantages: policy is versioned with code and testable locally.
- Disadvantages: unauthenticated/abusive traffic reaches the Worker, and it
  discards Access/WAF/Turnstile defense-in-depth benefits.

### Layer edge and Worker controls by route sensitivity

- Advantages: independent checks cover different failure modes and make the
  trust decision explicit.
- Disadvantages: more configuration, negative tests, and operational evidence;
  misaligned settings can deny valid traffic.

## Decision

For public chat, require:

- exact per-environment CORS with no wildcard or speculative production origin;
- early body/content-type/schema/length validation and unknown-field rejection;
- a fresh Turnstile token per send with server-side hostname/action validation;
- the baseline WAF burst rule and application rate-limit binding;
- bounded history/context/output, provider spend controls, and runtime disable;
  and
- text-only rendering plus administrator-approved HTTPS links.

For `/admin*`, require:

- a Cloudflare Access self-hosted application restricted to approved identities;
- independent Worker validation of `Cf-Access-Jwt-Assertion` signature, issuer,
  audience, expiry, and subject using cached JWKS;
- an application-level identity allowlist;
- same-origin validation on state-changing requests; and
- runtime validation, derived actor identity, confirmation, optimistic
  concurrency, and idempotency as applicable.

Keep the concierge isolated from RSVP, guest, Java API, and existing wedding
admin data. Never persist conversations by default or log prohibited visitor,
identity, credential, token, or full-content fields. Secrets remain outside Git
and browsers and are installed by the owner.

## Consequences

Positive consequences:

- A single edge or application misconfiguration does not automatically grant
  admin mutation authority.
- Public abuse/cost controls operate at both the edge and application layers.
- Prompt/content injection cannot create capabilities or private-data access
  that the system does not possess.
- Privacy claims have an explicit logging and integration boundary.

Negative consequences:

- Access/JWKS outages fail admin access closed.
- Turnstile and dual rate limits add public failure states and require careful
  shared-IP UX.
- Edge and application configuration drift must be detected before release.

Operational and cost/quota consequences:

- The baseline rates are starting controls, not strict global accounting; tuning
  requires observed, privacy-safe evidence and review.
- Health checks do not call AI and are not protected by expensive AI-dependent
  validation.
- Free-plan availability for Access, Turnstile, the rate-limit binding, and the
  selected WAF rule must be revalidated before implementation/launch. A missing
  required control triggers human review rather than silent removal or a paid
  upgrade.
- Provider/Cloudflare alerts and runtime disable remain independent of per-user
  rate accuracy.

## Ownership

- Seed 3 owns the threat model, claim/origin matrices, rate-key design, error
  contracts, security headers, rendering/link rules, logging policy, and
  negative-test strategy.
- The owner supplies approved identities, Access audience/team settings,
  Turnstile/provider secrets, production origins, WAF/budget settings, and all
  trust-policy changes.

## Approval

- Approver: Repository owner
- Decision date: Pending owner review
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: [HLD trust-boundary diagram and trust decisions](../architecture.md)

# Provider Outage Runbook

Status: Proposed; production containment and trust/configuration changes are
owner-only.

## Classify

Use stable metadata to identify KV, Durable Object, Workers AI, Vectorize,
Anthropic, Turnstile, Access/JWKS, Cache API, or broad Cloudflare outage.
Never collect raw request/provider payloads or weaken validation to test.

## Expected degradation

| Provider | Safe behavior |
|---|---|
| Cache API | Recompute subject to controls |
| Workers AI query / Vectorize query | Lexical-only |
| Vector readiness | `pending`/`failed`, lexical-only |
| Anthropic | Canonical if exact; otherwise generic unavailable |
| Turnstile Siteverify | Public chat unavailable/recoverable; no AI call |
| Access/JWKS | Admin fails closed; public may remain |
| Publish coordinator | Admin mutations fail closed; public KV reads remain |
| KV current content/runtime | Public unavailable; no vector/cache/model authority |

## Procedure

1. Confirm environment, UTC start, provider/status category, affected routes,
   current versions, and aggregate scale.
2. Verify `/health` and documented degradation with sanitized staging/production
   probes as authorized.
3. If safety, cost, or public UX is unacceptable, owner disables runtime and
   keeps wedding feature flag off.
4. Check official provider status and quota/budget dashboards.
5. Do not switch model/index/store, remove Turnstile/Access, loosen gates, or
   upgrade Workers without reviewed design/approval.
6. Preserve current content/snapshots and avoid publishing during uncertain KV/
   coordinator/index state.
7. After provider recovery, verify bindings/status, exact/unsupported/
   forced-lexical behavior, admin auth, and pending readiness.
8. Owner re-enables only after evidence.
9. Record duration, safe impact, containment, evidence, and follow-up.

Repeated or prolonged infeasibility triggers pause/decommission review, not an
invented availability claim.

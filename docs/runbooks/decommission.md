# Decommission Runbook

Status: Proposed; every production, DNS, billing, secret, and deletion action is
owner-only.

## Trigger and approval

The owner may decommission when the portfolio objective is met/abandoned,
cost/safety/platform viability cannot be restored, or the approved product
lifecycle criteria are met. Record explicit approval, scope, evidence-retention
decision, and rollback window.

## Procedure

1. Disable runtime and verify no AI call.
2. Keep/turn the wedding-site feature flag off and deploy that host change
   through its separate approved process.
3. Capture final non-sensitive release/content/version/cost/outcome record.
4. Export current published/draft/snapshot data to encrypted owner-controlled
   backup according to retention decision.
5. Remove/update public demo and portfolio status claims so no dead/live-service
   claim is misleading.
6. Revoke Anthropic, Turnstile, deployment, and other project credentials.
7. Remove Access/admin policy, monitoring, notifications, custom domain/DNS, and
   cloud resources only through separately verified owner actions and in an
   order that preserves evidence/rollback until approved.
8. Confirm no recurring paid service or unexpected usage remains.
9. Retain the sanitized public repository and explicitly historical,
   non-sensitive evidence if approved; remove private operational exports.
10. Record completion and any intentionally retained resources/secrets with
    review date.

Resource deletion is destructive. Resolve exact IDs through read-only provider
checks, use recoverable/provider retention where available, and never use broad
globs or guessed targets. If a target/backup/authority is unclear, stop.

## Verification

- Public assistant and host widget are unavailable/off.
- Health/domain behavior matches the intended retired state.
- Provider usage no longer increases.
- Credentials/policies/resources were retired as recorded.
- Public documentation no longer claims an active demo or current measured
  service.
- Required sanitized historical evidence remains accessible without secrets or
  private data.

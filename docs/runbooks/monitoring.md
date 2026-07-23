# Monitoring and Alert Response Runbook

Status: Proposed; production containment, alert destinations, and policy changes
are owner-only.

## Scheduled monitoring

- Hourly: external `/health` check with no AI call.
- Daily during launch/incident: error rate, response modes, cache ratio,
  retrieval degradation/rejection, provider latency/status, token/usage/spend,
  semantic status, and current versions.
- Monthly: quota/cost headroom, dependency/security findings, backup evidence,
  Access/admin allowlist, and alert delivery.
- Quarterly: provider terms/model availability, origins/link hosts, actual log/
  provider retention, restore test, secret schedule, and portfolio outcome.

## Alert triage

1. Record environment, UTC window, alert rule/category, current release/content/
   embedding/retrieval/prompt versions, and aggregate affected count.
2. Confirm `/health` and whether the signal is availability, security/privacy,
   quality, content integrity, provider, or cost.
3. Correlate only approved metadata: route/status/latency, response/cache mode,
   selected IDs, bounded score summaries, provider status class/token counts,
   and operation state.
4. Never retrieve raw questions, answers, history, tokens, JWTs, emails, IPs,
   secrets, full documents, or provider payloads.
5. For suspected safety/privacy/auth/content-integrity/runaway-cost impact, owner
   disables runtime and keeps the wedding feature flag off.
6. Route to the provider-outage, CORS, unexpected-spend, secret-rotation,
   content-rollback, backup, or deployment runbook.
7. Verify recovery with sanitized evidence and record limitations/follow-up.
8. Owner alone decides re-enable, pause, rollback, or decommission.

## Monitoring failure

An external monitor outage is not proof the service is down. Confirm with a
manual no-AI health check and provider status. If alert delivery is unavailable,
keep launch/production enablement off when timely notification is a release
condition. Change destinations only through owner-approved configuration.

## Evidence

Keep alert rule/version, aggregate metric, threshold, detection/acknowledgment/
resolution time, containment, safe verification, and owner decision. State
observations, not an unmeasured uptime/SLA claim.

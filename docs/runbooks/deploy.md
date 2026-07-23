# Deployment Runbook

Status: Proposed; production execution is owner-only.

## Preconditions

- Approved PR is merged by the owner and required checks pass.
- The exact commit/artifact passed staging or this is the staging deployment.
- Provider pricing/limits/model/Free eligibility were revalidated.
- Target environment/resource inventory is explicit and isolated.
- Secrets/configuration are installed by the owner and validated by presence,
  never printed.
- Security, evaluation, accessibility, performance, content/privacy, cost,
  monitoring, backup, and rollback evidence is complete as applicable.
- Runtime is disabled and the wedding feature flag is off for initial
  production release.
- Previous Worker deployment ID is recorded and compatible with current content
  schema, or the runtime-off recovery plan is approved.

Stop if any target, credential, approval, config, rollback, or evidence is
ambiguous.

## Procedure

1. Record commit, artifact digest, compatibility date, target environment,
   previous deployment ID, current content/embedding versions, and approver.
2. Reconfirm no simultaneous major content publish or embedding migration.
3. For production, use the manually approved environment/workflow; do not rely
   on merge alone.
4. Deploy the exact reviewed artifact. Do not rebuild with different source.
5. Verify deployment ID and artifact/source metadata.
6. Check `/health`; it must make no AI call.
7. Verify explicit API/static route precedence, `/widget/v1/*`, `/demo`, and
   Access protection for `/admin*`.
8. Verify headers, exact CORS positive/negative cases, Turnstile, rate/WAF,
   unauthorized admin rejection, and runtime-disabled behavior.
9. Run a few budgeted exact, paraphrase, unsupported, and forced-lexical smoke
   requests using sanitized cases. Confirm no Claude call for exact/unsupported.
10. Confirm monitoring, usage/spend alerts, backup access, and rollback target.
11. Record all results. Owner separately decides runtime enablement.
12. Only after Worker/content evidence passes, owner separately evaluates and
    enables the wedding-site feature flag.

## Failure/rollback

- Before runtime enablement: keep runtime/feature flag off and roll back the
  Worker through the owner-approved deployment mechanism if needed.
- After enablement: disable runtime first for safety-impacting failure, keep
  feature flag off, then execute Worker rollback.
- Verify the restored deployment ID, `/health`, disabled/no-AI behavior, Access,
  routes, and compatibility with current content.
- If prior Worker cannot read current schema, do not roll it out blindly; keep
  runtime off and seek human decision.

## Evidence

Release record includes commit/artifact/deployment IDs, compatibility date,
environment, safe smoke results, current versions, rollback ID, operator/
approver, timestamp, and any limitations. Never record secrets or raw payloads.

# CORS Failure Runbook

Status: Proposed; production origin/trust changes and deployment are owner-only.

## Triggers

- approved browser origin is rejected; or
- unapproved origin receives an allowed preflight/response.

The second case is security-impacting: owner disables runtime and keeps the
wedding feature flag off until corrected.

## Diagnosis

1. Record exact environment, route/method, origin (origin only, no full sensitive
   URL), preflight request headers, status, deployment/config version, and UTC.
2. Compare with the owner-approved exact origin inventory. Do not add `www`,
   localhost, wildcard, regex, suffix, `null`, or an alternate port speculatively.
3. Check canonical scheme/host/port, response reflection, `Vary: Origin`,
   allowed method/header minimum, and `Access-Control-Max-Age`.
4. Confirm admin routes emit no cross-origin CORS and mutation Origin is exact.
5. Reproduce in staging with the same reviewed config and negative origins.

## Correction

1. Owner verifies the real canonical origin/DNS behavior.
2. Change reviewed non-secret configuration through a scoped PR.
3. Run full positive/negative contract/browser tests, including lookalike
   domains, subdomains, default/nondefault ports, `null`, missing Origin, and
   admin cross-origin mutation.
4. Deploy through the normal staging/production runbook.
5. Verify an approved origin succeeds and unapproved/lookalike origins fail
   without reflection.
6. Owner re-enables runtime/feature flag.

Never use `Access-Control-Allow-Origin: *`, credentialed public CORS, reflected
unvalidated Origin, or a temporary Access bypass.

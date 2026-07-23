# Secret Rotation Runbook

Status: Proposed; all secret creation, reading, installation, revocation, and
rotation are human-only.

## Trigger

- Scheduled owner rotation;
- suspected exposure in Git, logs, screenshots, browser assets, CI, host, or
  provider;
- personnel/permission change;
- provider recommendation or credential scope change.

Secrets include Anthropic, Turnstile, rate-key HMAC, Cloudflare deployment, and
any future credential. Access audience/allowlist changes are trust-policy
changes, not secret rotation, and require separate approval.

## Immediate containment

1. Do not print, paste, validate, or copy the suspected secret into an issue/PR.
2. Owner disables runtime and wedding feature flag when public cost/data risk
   exists.
3. Revoke/disable the affected credential at its provider when safe.
4. Review privacy-safe access/usage evidence and affected environments.
5. Treat staging/production credentials independently; do not reuse replacements.

## Rotation

1. Owner creates a least-privilege replacement in the provider.
2. Install it through the approved secret store/Worker mechanism.
3. Deploy/restart only through the deployment approval path if required.
4. Verify presence and a bounded functional smoke without displaying value.
5. Revoke the previous secret after overlap needed for safe cutover.
6. Verify old credential fails through provider controls, not by exposing it to
   an agent/client.
7. Record secret name, environment, rotation time, operator, reason, and next
   due date—never the value or fingerprint if it weakens secrecy.

## Special cases

- `RATE_KEY_SECRET`: rotation changes daily transient rate keys and may
  temporarily reset rate buckets; rotate during low traffic and retain no old IP
  mapping.
- Turnstile: sitekey is public configuration, secret is not; verify exact
  hostname/action after rotation.
- Anthropic: confirm project budget/alerts remain on the replacement.
- Deployment token: confirm repository/account/zone/resource least privilege
  and remove broad token access.

## Exposure review

If a secret entered Git history/public artifacts, stop and seek an approved
history-remediation/notification plan. Rotating the secret is necessary but does
not erase exposure. Human security/privacy review determines notification and
evidence handling.

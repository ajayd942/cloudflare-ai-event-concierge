# Operations Runbooks

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

These runbooks preserve human-only authority. An agent may prepare evidence in
an approved issue but may not create/rotate secrets, change DNS/billing/trust
policy, deploy production, publish production content, execute rollback, pause,
or decommission.

| Runbook | Trigger |
|---|---|
| [Deployment](deploy.md) | Reviewed staging/production Worker release |
| [Monitoring and alert response](monitoring.md) | Scheduled review or health/quality/security alert |
| [Publish](publish.md) | Approved draft becomes a new public version |
| [Content rollback](content-rollback.md) | Restore an immutable snapshot as a new version |
| [Backup and restore](backup-restore.md) | Scheduled backup, restore test, or content loss |
| [Embedding migration](embedding-migration.md) | Model/pooling/template/tokenizer/dimension/metric change |
| [Secret rotation](secret-rotation.md) | Scheduled or suspected credential exposure |
| [Provider outage](provider-outage.md) | Workers AI, Vectorize, Anthropic, Turnstile, Access/JWKS, KV, or coordinator degradation |
| [CORS failure](cors-failure.md) | Approved origin blocked or unapproved origin accepted |
| [Unexpected spend](unexpected-spend.md) | 50/80/100% threshold, anomaly, or Free quota pressure |
| [Decommission](decommission.md) | Owner decides to retire the live service |

Every execution records UTC time, environment, human approver/operator,
reason/incident reference, before/after versions or state, exact safe checks and
results, rollback/containment target, and follow-up. Records never contain raw
questions, answers, history, tokens, JWTs, emails, IPs, secrets, guest data,
provider payloads, or complete content documents.

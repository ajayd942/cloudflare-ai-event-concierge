# Backup and Restore Runbook

Status: Proposed; backup location, keys, restore, and production actions are
owner-only.

## Backup

Trigger after every production publish/rollback and on the approved periodic
schedule.

1. Export current published content through the protected admin API.
2. Export current draft and the protected snapshot inventory/manifests.
3. Record release, content, schema, embedding, prompt, and retrieval versions.
4. Validate export schema/hash and absence of secret/identity fields.
5. Encrypt at rest in the owner-approved location outside the public repository.
6. Record backup timestamp, content version, digest, custodian, and restore-test
   due date without copying content publicly.
7. Keep secret backup material separate under the owner's credential process.

Backups contain no chat data because the application does not persist it.

## Staging restore test

Run quarterly and after data/schema/embedding changes:

1. Use an isolated staging recovery target, never production.
2. Verify backup digest and decrypt under owner control.
3. Validate export/schema/content links and public-data policy.
4. Import to staging draft only.
5. Review diff, preview, and publish through normal protected flow.
6. Rebuild vectors from restored KV content; do not restore vector values as
   authority.
7. Run release evaluation/smokes and rollback-as-new-version.
8. Record RTO observation, integrity result, and gaps. Do not claim an SLA.

## Production recovery

1. Owner declares/approves recovery and disables runtime/wedding feature flag.
2. Preserve current evidence; do not overwrite an immutable snapshot.
3. Restore validated backup to a draft or new isolated recovery resource.
4. Publish through the coordinator as a new version after content approval.
5. Rebuild/evaluate semantic index and verify lexical behavior.
6. Record new version and backup lineage.
7. Re-enable only after security/content/smoke/cost evidence.

If backup integrity, decryption authority, or target environment is uncertain,
stop and seek human decision.

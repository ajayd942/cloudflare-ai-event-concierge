# Content Rollback Runbook

Status: Proposed; production rollback is owner-only.

## Trigger

Use when current published content is incorrect/unsafe and an approved immutable
snapshot should be restored. Worker code rollback is a different operation.

## Preconditions

- Owner approved production rollback.
- Runtime is disabled if current content is unsafe.
- Target snapshot version/hash/summary/content were reviewed.
- Snapshot is schema-valid and immutable; backup is available.
- No publish, embedding migration, or Worker release is active.

## Procedure

1. Record current version, target snapshot, reason, environment, approver, and
   time.
2. Verify snapshot version/hash and protected export/preview.
3. In admin, select the snapshot, enter reason, explicitly confirm, and submit
   once with a fresh idempotency key.
4. If status is uncertain, retry the same operation/key.
5. Verify terminal success created a new ULID, set
   `restoredFromVersion=<target>`, and did not mutate target history.
6. Review semantic status and exact/paraphrase/unsupported/forced-lexical
   smokes.
7. Export/back up the newly published version.
8. Owner re-enables runtime only after evidence passes; wedding feature flag is
   a separate decision.

## Failure

- Before commit: current publication remains unchanged; keep runtime off and
  correct the cause.
- After commit with warnings: new rollback version is current; resolve warnings
  without assuming the prior bad version is active.
- Snapshot integrity mismatch: stop, keep runtime off, use backup/restore, and
  seek human decision.

## Verification

Confirm new/target versions differ, history remains, sources resolve to the new
KV document, lexical works even if semantic is pending/failed, and public
fallback remains fixed/no-Claude.

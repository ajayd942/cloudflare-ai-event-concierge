# Content Publish Runbook

Status: Proposed; production content approval and execution are owner-only.

## Preconditions

- Correct environment is visible.
- Saved draft ETag is current; validation and diff are complete.
- Content is fictional/sanitized, public-safe, and owner-approved in production.
- Enabled/total counts, 512 KiB bound, link allowlist, notices, and embedding
  inputs pass.
- Runtime state, provider usage, backup access, and current publication/snapshot
  are known.
- No content transition, Worker release, or embedding migration is active.

## Procedure

1. Record current content version, draft revision/ETag as opaque evidence,
   semantic status, environment, approver, reason, and time.
2. Preview exact, paraphrase, unsupported, and injection cases.
3. Review diff/count/validation/public links and explicitly confirm.
4. Submit once; preserve the browser-generated idempotency key inside the
   protected operation only.
5. If `202 in_progress`, retry status with the same operation/key. Do not create
   a new publish.
6. If terminal failure before commit, verify old version remains current. Fix
   the cause and start a materially new operation with a new key.
7. On success, record new ULID, semantic status, smoke status, warnings, and
   restored-from value if any.
8. Verify public exact/paraphrase/unsupported/forced-lexical behavior and that
   sources resolve to the new KV version.
9. If `pending`, confirm lexical behavior and wait for bounded readiness. If
   `failed`, keep lexical-only and follow provider/embedding procedure.
10. Export the publication and update the encrypted owner-controlled backup.
11. Owner decides whether runtime may remain/become enabled.

## Post-commit warning

A failure after `content:published` commits does not mean the old version is
current. Treat the new version as current, keep runtime off if evidence is
unsafe, and remediate smoke/readiness/cleanup. Never repeat with a new version
merely to hide an uncertain response.

## Rollback

If published facts are unsafe, disable runtime and follow
[content rollback](content-rollback.md). Do not overwrite KV or a snapshot
manually.

## Evidence

Record environment, old/new version, reason, actor reference, semantic/smoke
states, safe case IDs/results, backup reference, and limitations. Do not include
complete content in public records.

# Administration Guide

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

This guide describes the protected, nontechnical admin workflow. It does not
grant production content authority; the repository owner approves production
content, identities, runtime enablement, and rollback execution.

## Safety rules

- Use only fictional or sanitized information approved for public display.
- Never enter guest lists, private addresses/phone numbers, RSVP codes, internal
  notes, credentials, API keys, or personal guest details.
- Saving changes updates only the draft. Preview does not publish.
- Publishing and rollback require a deliberate confirmation and reason.
- Do not retry with a new idempotency key while an operation is still in
  progress. Reuse the existing key through the UI retry.
- `pending` or `failed` semantic status means public retrieval is lexical-only;
  it does not mean content is lost.
- When unsure, keep the assistant disabled and contact the owner.

## Sign in and status

Open the environment's `/admin` page through Cloudflare Access. The Worker
independently validates the Access assertion and application allowlist. A denied
request cannot be repaired by entering a secret in the page.

The admin home shows:

- environment and public origin;
- runtime enabled/disabled state;
- current content version and publish time;
- draft dirty/saved state;
- semantic `pending`, `ready`, or `failed`;
- lexical fallback state;
- latest publish/rollback smoke summary; and
- links to content, snapshots, import/export, and runtime control.

The UI never displays JWTs, Access claims, raw ETags, provider keys, vector
values, account IDs, or internal error payloads.

## Edit and save a draft

1. Open Content and confirm the intended environment.
2. Add/edit/enable/disable entries. Deletion affects the draft only.
3. Keep stable entry IDs; changing a title does not require changing its ID.
4. Use the controlled category, public-safe example questions/keywords, one
   approved plain-text answer, and approved HTTPS links.
5. Resolve field errors and content-count/size warnings.
6. Review the visible dirty state and diff.
7. Select **Save draft**.

The browser sends the ETag it received with the draft. If another tab/admin
saved first, the UI reports:

> This draft changed elsewhere. Refresh and reconcile your changes.

Copy any unsaved public-safe text locally if needed, refresh, compare, and save
again. Never force an overwrite. The UI warns before navigation with unsaved
changes; there is no autosave.

## Preview

Preview operates on the saved draft:

1. Save the draft.
2. Enter a sanitized test question.
3. Review selected source IDs/titles, lexical/semantic component scores,
   accepted/rejected result, answer mode, answer, links, and warnings.
4. Test at least one exact, one paraphrase, one unsupported, and one adversarial
   question relevant to the change.

Preview creates temporary draft embeddings in request memory and does not write
Vectorize, public cache, published KV, or snapshots. A good preview is evidence,
not publication authority.

## Publish

Follow [the publish runbook](runbooks/publish.md). In the UI:

1. Confirm the correct environment and saved draft.
2. Review the complete diff, validation result, enabled/total counts, content
   size, public links, demo/privacy notices, and public-data approval.
3. Confirm the owner has authorized a production publish when in production.
4. Enter a reason and check the explicit confirmation.
5. Submit once. The browser creates the idempotency key.
6. If the connection times out or reports `in_progress`, use **Retry status**;
   do not start a new publish.
7. Record the new version, semantic status, exact/paraphrase/unsupported/
   forced-lexical smoke results, and warnings.
8. Export/backup the publication after success.

Possible terminal outcomes:

| Outcome | Meaning/action |
|---|---|
| Completed, ready, smokes passed | Publication is current; complete backup/release evidence |
| Completed, pending | Content is public lexically; wait for readiness checks and do not claim semantic readiness |
| Completed with warnings | Publication committed; keep runtime off if evidence is unsafe and use troubleshooting/runbook |
| Failed before commit | Previous publication remains current; correct the error and use a new key |
| Busy | Another transition is active; wait/retry existing operation |
| Idempotency conflict | The key no longer describes the same operation; stop and investigate UI/client behavior |

## Semantic status

- `pending`: upsert succeeded but representative vectors are not confirmed;
  public requests use lexical retrieval.
- `ready`: representative vectors and metadata were confirmed; hybrid retrieval
  may run.
- `failed`: bounded readiness checks expired or repair declared failure; public
  requests stay lexical-only.

Do not manually edit semantic status. Use the outage/troubleshooting or
embedding migration runbook. A content correction remains visible through
lexical retrieval as locations observe the new complete KV version.

## Rollback content

Rollback is a new publication, not history rewrite:

1. Keep runtime disabled if the current content is unsafe.
2. Open Snapshots and review source version, time, actor reference, summary,
   hash, and restored-from relationship.
3. Verify the snapshot content through protected export/preview.
4. Obtain production owner approval.
5. Select rollback, enter a reason, confirm, and submit once.
6. Retry the same operation/key if its status is uncertain.
7. Verify the new ULID differs from the snapshot's version and
   `restoredFromVersion` points to it.
8. Review semantic/smoke evidence and export the new publication.

Older snapshots remain unchanged. See
[content rollback](runbooks/content-rollback.md).

## Import and export

### Export

Choose Draft or Published explicitly. The downloaded JSON identifies its view,
schema, export time, and content. Default export excludes administrator
identity. Store production exports only in the owner-approved encrypted backup
location, never the public repository.

### Import

1. Confirm the target environment and current draft ETag.
2. Upload a JSON file no larger than 512 KiB.
3. Run **Validate only** first.
4. Review schema/field errors and the complete diff.
5. Confirm the file contains only public-safe content.
6. Choose **Replace draft**, explicitly confirm, and save.
7. Preview and publish separately.

Import never publishes, overwrites snapshots, trusts actor/timestamp fields, or
changes runtime state.

## Runtime enable/disable

The protected runtime switch affects public chat independently of content and
the wedding feature flag.

To disable:

1. Confirm the environment.
2. Enter a reason and confirm.
3. Verify public chat returns the friendly disabled state with no AI call.
4. Keep the wedding feature flag off if the problem affects the host.

To enable:

1. Obtain owner approval in production.
2. Confirm valid current content, acceptable semantic/lexical state, passed
   smokes, budgets/alerts, health, and rollback readiness.
3. Enter a reason, confirm, and verify exact/unsupported public behavior.

Runtime enablement does not deploy code or enable the wedding-site feature flag.

## Error recovery

| Message | Recovery |
|---|---|
| Sign-in/permission denied | Confirm Access identity/policy with owner; do not enter credentials elsewhere |
| Draft changed elsewhere | Preserve local text, refresh, reconcile, save |
| Invalid content | Correct named fields; do not bypass validation |
| Publish in progress/busy | Wait and retry status with existing operation |
| Verification/provider unavailable | Keep state unchanged, retry later, consult troubleshooting |
| Semantic pending/failed | Public is lexical-only; follow provider outage/embedding procedure |
| Assistant unavailable | Keep runtime off; inspect health/config/content evidence |
| Rate limited | Wait for `Retry-After`; do not create a persistent identity workaround |

Never paste raw questions, answers, JWTs, emails, tokens, IPs, API keys, headers,
full content documents, or provider responses into public issues or logs.

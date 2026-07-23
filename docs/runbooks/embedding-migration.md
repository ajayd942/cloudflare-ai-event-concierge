# Embedding Migration Runbook

Status: Proposed; index creation, model activation, production migration, and
resource deletion are owner-only.

## Trigger

Any embedding model, tokenizer, pooling, input template, dimensions, or metric
change. Threshold-only retrieval changes require recalibration/review but not
necessarily a new index; changes listed above always require one.

## Preconditions

- Approved ADR/design and cost/security review.
- New `embeddingVersion`, index name, tokenizer/template checksum, dimensions,
  metric, and explicit pooling.
- Current provider availability/Free quotas revalidated.
- Sanitized dataset and calibration/release splits locked.
- Separate staging index exists under human-controlled setup.
- Old index/version remains intact as rollback target.

## Procedure

1. Keep public production configuration on the old embedding version.
2. Build all current published entry inputs deterministically and validate token
   bounds.
3. Generate/upsert the new staging namespace and verify ID/metadata manifests.
4. Calibrate gates/fusion only on calibration cases; freeze the artifact.
5. Run locked release evaluation, forced lexical, critical-fact, injection,
   performance, and cost checks.
6. Publish/stage a version whose manifest names the new index/version; verify
   `pending -> ready` and fallback.
7. Obtain owner approval for production index/resource/config and migration.
8. Rebuild production vectors from current KV content; do not copy vector values
   from staging.
9. Confirm representative readiness and run budgeted production smokes with
   runtime/feature flag controlled.
10. Activate through an approved publication/config release that never mixes
    old/new vectors.
11. Retain old index/version through the approved rollback window and record
    usage.
12. Delete old resources only in a separately approved human action after
    rollback no longer depends on them.

## Failure/rollback

Before activation, discard/rebuild only the new index. After activation, disable
runtime if unsafe and republish/release the prior approved embedding version as
designed; never query old vectors under a new version. Re-run evaluation and
record the rollback.

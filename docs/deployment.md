# Deployment and Operations Design

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Authority

This document specifies a future human-controlled deployment. It does not
authorize resource creation, credentials, DNS, billing, content publishing,
deployment, rollback, or production access.

- Reviewed merge may trigger automatic staging deployment only after the future
  approved CI workflow exists.
- Production deployment requires an explicit owner-approved GitHub Environment
  or manual workflow action.
- Production content remains a protected admin operation, separate from code
  CI/CD.
- A major Worker release, embedding migration, and major content publish are
  separate production actions.
- Agents stop at review; only the owner merges, deploys, publishes production
  content, rolls back, changes trust settings, or marks work Done.

## Environment topology

| Resource | Local | Staging | Production |
|---|---|---|---|
| Worker/static assets | Wrangler/Miniflare | Dedicated Worker | Dedicated Worker |
| Origin | Local reviewed URL | `https://assistant-staging.vandanawedsajay.uk` | `https://assistant.vandanawedsajay.uk` |
| KV | Emulated/local | Dedicated namespace | Dedicated namespace |
| Durable Object | Local class/storage | Dedicated SQLite namespace | Dedicated SQLite namespace |
| Vectorize | Mock/designated dev | Dedicated versioned index | Dedicated versioned index |
| Workers AI | Mock by default | Staging binding | Production binding |
| Turnstile | Approved test config | Dedicated widget/secret | Dedicated widget/secret |
| Anthropic | Mock by default | Dedicated low-limit project key | Dedicated owner-limited project key |
| Access | Test claims/mocks | Dedicated app/policy/config | Dedicated app/policy/config |
| CORS/rate/cache/content | Local-only | Staging-only | Production-only |

No resource identifier, secret, content, cache, or trust setting is shared
between staging and production. The Durable Object class is bundled in the same
Worker script, preserving one deployable per environment.

## Configuration contract

`wrangler.jsonc` contains only reviewed non-secret variables, bindings,
resource identifiers, compatibility date, assets, and environment blocks.
Secrets are installed through human-controlled Worker secret management.

Required bindings and variables are enumerated in
[detailed-design.md](detailed-design.md#environment-contract). The checked-in
schema validates:

- exact environment name and Worker origin;
- distinct staging/production binding IDs;
- Vectorize name suffix, dimensions, and metric evidence;
- SQLite-backed Durable Object migration declaration;
- pinned compatibility date and behavior versions;
- exact CORS/Turnstile/Access/link-host settings with no placeholders;
- Workers Free policy and CPU limit;
- observability configuration without prohibited log fields; and
- absence of secret values.

Production config rejects localhost, `.workers.dev` as a canonical public
origin unless explicitly approved, wildcard CORS, test keys, unpinned model
aliases, and speculative `www`.

## Build artifact

One immutable build contains:

- Worker script and Durable Object class;
- admin SPA assets;
- standalone demo assets;
- `/widget/v1/*` assets;
- content/runtime/API schema versions;
- prompt, retrieval, embedding, and tokenizer version assets; and
- source commit and compatibility-date metadata.

The build is reproducible from the lockfile. The artifact manifest records file
SHA-256 digests and gzip sizes. No environment secret, private content,
production export, account response, or local `.dev.vars` is included.

## CI/CD boundaries

### Pull request

The future project bootstrap defines exact commands. Required classes of checks
are locked install, format, lint, typecheck, unit/Worker integration/API
contract/retrieval evaluation tests, selected Chromium/WebKit tests, content
validation, secret scan, dependency-audit report, and Worker/widget/admin/demo
builds.

### Staging after merge

Automation may:

1. build once from the reviewed commit;
2. deploy to the isolated staging Worker with a least-privilege token;
3. record deployment ID, compatibility date, artifact digest, and commit;
4. run no-AI health and bounded staging smokes; and
5. publish the sanitized evidence artifact.

It may not copy production content/secrets, change production, approve itself,
or mark a failed release successful.

### Production

The owner explicitly approves:

- exact commit/artifact already accepted in staging;
- security, evaluation, accessibility, performance, cost/quota, content, and
  privacy evidence;
- target resource identifiers and compatibility date;
- secrets/settings installed outside GitHub where required;
- production content and backup readiness;
- rollback deployment ID;
- the runtime and wedding feature flags remaining off during initial deploy.

Production deploy uses the same build bytes as staging unless an environment
binding necessarily changes outside the artifact. Any rebuild restarts staging
evidence.

## Release record

Every production release record contains:

```json
{
  "schemaVersion": 1,
  "commitSha": "full-git-sha",
  "artifactSha256": "sha256:example",
  "workerDeploymentId": "provider-issued-id",
  "compatibilityDate": "YYYY-MM-DD",
  "deployedAt": "2026-07-23T12:00:00Z",
  "approvedBy": "repository-owner",
  "stagingEvidence": "reviewed-evidence-reference",
  "productionSmoke": "reviewed-evidence-reference",
  "rollbackDeploymentId": "previous-provider-issued-id",
  "contentVersion": "01JAZ6M8K0ABCDEF1234567890",
  "embeddingVersion": "bge-small-cls-template-v1"
}
```

The public repository stores only non-secret sanitized evidence. Provider
dashboard exports containing account/identity details remain owner-controlled.

## Deployment sequence

Use the [deployment runbook](runbooks/deploy.md). High-level gates:

1. Revalidate provider pricing/limits/models/features.
2. Confirm clean reviewed commit, CI, artifact hashes, and staging acceptance.
3. Confirm exact isolated target, Access, Turnstile, CORS, WAF/rate, budgets,
   monitoring, backups, and rollback target.
4. Keep runtime disabled and wedding feature flag off.
5. Deploy the reviewed artifact under human approval.
6. Validate no-AI health, routes/assets/headers/auth/origin, then a few budgeted
   exact/paraphrase/unsupported/forced-lexical smokes.
7. Record release evidence.
8. Owner separately publishes/approves production content if needed.
9. Owner enables runtime only after content/index/smoke evidence.
10. Owner separately enables the wedding feature flag after host-site checks.

## Monitoring

An external owner-selected monitor calls `/health` hourly and never invokes AI.
Repeated failure notifies the owner. Privacy-safe aggregate monitoring covers:

- dynamic request/error/latency and response mode;
- cache ratio and retrieval rejection/degradation;
- KV, Durable Object, Workers AI, Vectorize, Turnstile, Access/JWKS, and
  Anthropic error categories;
- provider token/neuron/vector/KV/DO usage and spend;
- publish/rollback/smoke/cleanup state;
- current code/content/embedding/prompt/retrieval versions; and
- widget asset reachability.

Alert destinations are human-supplied. Alerts never include raw questions,
answers, history, tokens, identities, IPs, secrets, or complete content.

## Backup and recovery

After every successful production publish/rollback, the owner exports the
published document and release metadata to an encrypted location outside the
public repository. Periodic backups include:

- current draft and publication exports;
- immutable snapshot exports/manifests;
- non-secret configuration/version inventory;
- release records; and
- instructions to recreate Vectorize from KV.

Backups never include chat data because the application does not persist it.
Secret backups follow the owner's secure credential process and are not mixed
with content exports. Restore is tested in staging at least quarterly and after
schema/embedding/coordinator migrations. See
[backup and restore](runbooks/backup-restore.md).

## Rollback boundaries

Three independent containment controls remain:

1. protected `config:runtime.enabled=false`;
2. wedding-site feature flag off; and
3. Worker deployment rollback.

Content rollback republishes an immutable snapshot as a new ULID/version and
new vector namespace. It is not a Worker rollback. Worker rollback does not
silently rewrite content. If an older Worker cannot read the current schema,
disable runtime first and use the compatibility/recovery procedure; never guess.

## Migrations

- Content schema: explicit pure migration to a reviewed draft, then normal
  publish.
- Embeddings: parallel new index/version, rebuild/evaluate/stage, owner
  activation, retain old rollback window.
- Durable Object SQLite: forward-only transactional migration, no external I/O,
  staged restored-copy test, public reads remain independent.
- API/widget: new major path for breaking changes.

Migration failure stops the affected mutation/release and moves to human review.
Follow [embedding migration](runbooks/embedding-migration.md); coordinator
migrations require their own implementation PR and rollback evidence.

## Operational cadence

| Cadence | Review |
|---|---|
| Hourly | No-AI health |
| Daily during launch/incident | Errors, usage/spend, semantic status, feature/runtime state |
| Monthly | Cost, quota headroom, dependency/security findings, backup evidence |
| Quarterly | Provider terms/model availability, Access/admin allowlist, origins/link hosts, secret rotation schedule, restore test, portfolio outcome |
| After every release | Release/smoke/rollback record |
| After every publish | Export/backup, semantic/smoke status, vector retention |

## Pause and decommission

The owner pauses for safety/privacy/auth/retrieval/cost/rollback failures or
provider/platform infeasibility. Runtime and wedding flag remain off until an
approved correction passes evidence. Decommission is owner-only and follows
[the decommission runbook](runbooks/decommission.md); it updates public claims,
retires live resources/secrets/DNS through approved actions, and retains only
sanitized non-sensitive historical evidence.

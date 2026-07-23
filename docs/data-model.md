# Data Model

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Authority and canonical encoding

Workers KV is the readable authority for draft and published content. Vectorize
is a rebuildable retrieval index, Cache API entries are disposable, and the
SQLite-backed Durable Object stores only coordination metadata.

All stored JSON:

- is UTF-8 without a byte-order mark;
- uses integer `schemaVersion`;
- contains no unknown fields;
- is validated before use;
- uses UTC RFC 3339 timestamps with millisecond precision and `Z`;
- is hashed from RFC 8785 canonical JSON bytes with SHA-256; and
- is measured against its byte bound after canonical serialization.

Arrays preserve declared order. Object-key order is irrelevant. Hashes are
represented as `sha256:<base64url-without-padding>`. A stored value whose hash,
schema, or invariant fails is unavailable; it is never partially accepted.

## Identifier formats

| Identifier | Format and validation |
|---|---|
| Content version | Canonical uppercase ULID, exactly 26 Crockford Base32 characters matching `^[0-9A-HJKMNP-TV-Z]{26}$`; decoded timestamp cannot be more than five minutes in the future |
| Entry ID | `^[a-z0-9]+(?:-[a-z0-9]+)*$`, 3–64 characters, stable across title changes |
| Draft revision | Safe integer `>= 0`, incremented exactly once per accepted save/import |
| Runtime revision | Safe integer `>= 0`, incremented exactly once per accepted change |
| Vector ID | `<contentVersion>:<entryId>`, at most 91 characters |
| Vector namespace | Exact `<contentVersion>` |
| Actor reference | `sha256:` plus the first 22 base64url characters of SHA-256 over UTF-8 `actor:v1:<Access sub>` |
| Client/idempotency ID | Canonical UUID v4 |

An actor reference is pseudonymous, not anonymous. It is visible only in the
protected admin surface and snapshot metadata, excluded from default exports
and all public responses, and never joined to an email in application storage.

## KV key registry

| Key | Mutability | Value | Retention |
|---|---|---|---|
| `content:draft` | Mutable, serialized explicit saves | `DraftDocumentV1` | Current draft only |
| `content:published` | Mutable, one complete write per new version | `PublishedDocumentV1` | Current publication only |
| `content:snapshot:<version>` | Immutable create-or-verify | `SnapshotDocumentV1` | All V1 snapshots |
| `config:runtime` | Mutable, explicit protected change | `RuntimeConfigV1` | Current state only |
| `index:status:<version>` | Mutable state for one embedding namespace | `IndexStatusV1` | Current plus four previous versions; older status may be deleted after vector cleanup |

The complete editable/published content document is limited to 512 KiB.
Snapshots wrap a validated publication and are limited to 640 KiB. Runtime and
index-status documents are limited to 16 KiB. No key is written more than once
per second. Snapshot and publication values have no KV TTL.

## Controlled category enum

V1 categories are lowercase wire values:

```text
schedule
venue
directions
arrival
dress-code
transportation
parking
accommodation
food
children
accessibility
contact
gifts
photography
rsvp
website-navigation
general-policy
```

Adding or renaming a category is a schema-compatible reviewed content-contract
change only if existing values remain valid. Removing a value requires a schema
migration.

## Presentation

```ts
interface PresentationV1 {
  title: string;                 // 1..80 Unicode scalar values
  welcomeMessage: string;        // 1..500
  suggestedQuestions: string[];  // 0..6, each 1..120, normalized-unique
  demoNotice: string;            // 1..200, contains approved disclosure
  privacyNotice: string;         // 1..500
}
```

The demonstration notice must include, as one normalized contiguous phrase:
`Demonstration project — information is fictional or sanitized.` Smart/ASCII
dash equivalence is allowed only for validation; stored approved copy remains
the exact phrase. Presentation text is plain text.

## Content entry

```ts
interface ContentEntryV1 {
  id: EntryId;
  title: string;
  category: CategoryV1;
  questions: string[];
  keywords: string[];
  answer: string;
  links: ApprovedLinkV1[];
  enabled: boolean;
  sortOrder: number;
}

interface ApprovedLinkV1 {
  label: string;
  url: string;
}
```

| Field | Bound/invariant |
|---|---|
| `title` | 1–120 scalar values; plain text |
| `questions` | 1–10 for enabled entries, 0–10 when disabled; each 1–160; normalized-unique within and across enabled entries unless an explicit ambiguity evaluation covers the duplicate |
| `keywords` | 0–20; each 1–40; normalized-unique |
| `answer` | 1–2,000 for enabled entries; 0–2,000 when disabled; plain text |
| `links` | 0–5 |
| link label | 1–80 |
| link URL | absolute HTTPS, 2,048 or fewer characters, no credentials, approved host, no `javascript:`, `data:`, or protocol-relative form |
| `sortOrder` | safe integer 0–10,000; duplicates allowed and tie by entry ID |

There are at most 150 entries total and 100 enabled entries. Entry IDs are
unique. The validator rejects NUL, bidi override/isolate controls, unpaired
surrogates, noncharacters, raw HTML elements, and control characters other than
line feed in answer/presentation text. Line feeds normalize to `\n`; other
whitespace collapses where the field contract calls for normalized uniqueness.

Content may contain only fictional or sanitized public event facts. Schema
validation cannot prove that policy; publish also requires human content review.

## Draft document

```ts
interface DraftDocumentV1 {
  schemaVersion: 1;
  draftRevision: number;
  baseContentVersion: ContentVersion | null;
  presentation: PresentationV1;
  entries: ContentEntryV1[];
  updatedAt: string;
  updatedByRef: ActorRef;
  contentHash: Sha256Digest;
}
```

`contentHash` covers `schemaVersion`, `draftRevision`, `baseContentVersion`,
`presentation`, `entries`, and audit fields except `contentHash` itself. Clients
send only presentation/entries; the server owns all other fields.

Strong ETag:

```text
"draft-r<draftRevision>-<first-22-base64url-contentHash>"
```

An initial draft uses revision `0` and `baseContentVersion: null`. After publish,
the draft is not silently rewritten. A later explicit "reset draft to current
published" operation, if desired, needs its own approved API change; V1 import
can deliberately replace it.

## Published document

```ts
interface PublishedDocumentV1 {
  schemaVersion: 1;
  contentVersion: ContentVersion;
  sourceDraftRevision: number | null;
  publishedAt: string;
  publishedByRef: ActorRef;
  reason: "initial" | "publish" | "rollback";
  restoredFromVersion: ContentVersion | null;
  presentation: PresentationV1;
  entries: PublishedEntryV1[];
  embedding: EmbeddingManifestV1;
  contentHash: Sha256Digest;
}

type PublishedEntryV1 = Omit<ContentEntryV1, "enabled"> & {
  enabled: true;
};
```

Only enabled entries are copied into the publication. `sourceDraftRevision` is
null only for an approved initial seed. `restoredFromVersion` is non-null only
for rollback and never equals the new version. `entries` are sorted by
`sortOrder`, then `id`, before hashing and storing.

```ts
interface EmbeddingManifestV1 {
  embeddingVersion: "bge-small-cls-template-v1";
  model: "@cf/baai/bge-small-en-v1.5";
  pooling: "cls";
  dimensions: 384;
  metric: "cosine";
  templateVersion: "entry-template-v1";
  tokenizerVersion: "bge-small-tokenizer-v1";
  vectorIds: VectorId[];
  manifestHash: Sha256Digest;
}
```

`vectorIds` contains exactly one ID per published entry in entry order and no
duplicates. `manifestHash` covers all other manifest fields. Index names are
environment-specific configuration and do not enter the portable content
document.

Strong ETag:

```text
"content-<contentVersion>-<first-22-base64url-contentHash>"
```

## Snapshot document

```ts
interface SnapshotDocumentV1 {
  snapshotSchemaVersion: 1;
  snapshotOfVersion: ContentVersion;
  capturedAt: string;
  capturedByRef: ActorRef;
  reason: "superseded-by-publish" | "superseded-by-rollback";
  summary: {
    entryCount: number;
    categoryCounts: Record<CategoryV1, number>;
    contentHash: Sha256Digest;
  };
  publishedDocument: PublishedDocumentV1;
  snapshotHash: Sha256Digest;
}
```

The snapshot version, embedded publication version, content hash, and key suffix
must agree. Creation is:

1. read the target key;
2. if absent, write the complete snapshot;
3. if present and the canonical hash matches, treat as an idempotent success;
4. if present and it differs, fail `INTEGRITY_CONFLICT`.

All snapshots are retained in V1. The UI lists at most 20 per page. Default
export of a snapshot/published document removes actor references while
preserving content/version integrity in an export-specific hash.

## Runtime config

```ts
interface RuntimeConfigV1 {
  schemaVersion: 1;
  revision: number;
  enabled: boolean;
  updatedAt: string;
  updatedByRef: ActorRef;
  reason: string;
  configHash: Sha256Digest;
}
```

Strong ETag:

```text
"runtime-r<revision>-<first-22-base64url-configHash>"
```

The runtime key contains no presentation content or provider configuration.
Missing/invalid config disables public chat. The admin mutation is serialized
and cannot write the same key more than once per second.

## Semantic index status

```ts
interface IndexStatusV1 {
  schemaVersion: 1;
  contentVersion: ContentVersion;
  embeddingVersion: "bge-small-cls-template-v1";
  state: "pending" | "ready" | "failed";
  upsertedAt: string;
  lastCheckedAt: string;
  checkCount: number;
  representativeIds: VectorId[];
  reasonCode:
    | "INITIAL_PROBE_PENDING"
    | "REPRESENTATIVES_CONFIRMED"
    | "READINESS_TIMEOUT"
    | "MANUAL_REBUILD_PENDING";
  statusHash: Sha256Digest;
}
```

There are 1–3 representative IDs, chosen as first/median/last after entry
sorting, deduplicated for corpora smaller than three. `checkCount` is 1–6.
`ready` requires `REPRESENTATIVES_CONFIRMED`; `failed` requires
`READINESS_TIMEOUT`; other combinations are invalid.

The status may transition `pending -> ready` or `pending -> failed`. `ready` or
`failed` is terminal for that embedding version; a rebuild that needs a new
attempt uses a new embedding/index version or an explicitly approved repair
that resets to `pending`. Public code treats absent/invalid/non-ready as lexical
only.

## Vectorize record

```ts
interface VectorRecordV1 {
  id: VectorId;
  namespace: ContentVersion;
  values: number[]; // exactly 384 finite numbers, never returned to clients
  metadata: {
    entryId: EntryId;
    category: CategoryV1;
    contentVersion: ContentVersion;
    embeddingVersion: "bge-small-cls-template-v1";
  };
}
```

The Vectorize index name is environment-specific and ends in
`-bge-small-cls-v1`. It has 384 dimensions and cosine metric. Namespace,
ID prefix, and metadata version must all equal the current publication. Public
queries set `topK: 8`, `returnValues: false`, and request only necessary
metadata. No metadata index is required solely for content version because the
namespace filters it.

Vector metadata never includes title, questions, answer, links, actor, content
hash, prompt, or raw document. Results with duplicate IDs, non-finite scores,
wrong metadata, wrong version, or unknown entries are discarded and recorded as
bounded degradation.

Retention keeps the current and four prior content-version manifests. Cleanup
deletes explicit IDs obtained from immutable manifests; it never uses an
unbounded scan or guessed prefix. Cleanup is idempotent.

## Embedding input and tokenizer

The exact template is defined in
[`retrieval-design.md`](retrieval-design.md#document-embedding-template).
Implementation pins the BGE tokenizer vocabulary and checksum as
`bge-small-tokenizer-v1`; build and runtime use the same WordPiece count.

- Fixed fields (title, category, questions, keywords) must fit within 350 model
  tokens including template markers.
- The answer is appended sentence-by-sentence until the complete input would
  exceed 350 tokens; a partial sentence is never appended.
- If fixed fields exceed 350 tokens, content validation fails.
- The provider call must explicitly request `pooling: "cls"`.
- No input may exceed 510 tokenizer tokens before the model's two special
  tokens; the design target of 350 makes that a defensive assertion.

The full approved answer remains in KV even when only a prefix contributes to
the embedding.

## Durable Object coordinator schema

The SQLite namespace contains one environment singleton. Schema version 1:

```sql
CREATE TABLE schema_migrations (
  version INTEGER PRIMARY KEY,
  applied_at TEXT NOT NULL
);

CREATE TABLE resource_heads (
  resource TEXT PRIMARY KEY
    CHECK (resource IN ('draft','runtime','published')),
  revision INTEGER,
  version TEXT,
  etag TEXT,
  value_hash TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE active_operation (
  singleton INTEGER PRIMARY KEY CHECK (singleton = 1),
  operation_id TEXT NOT NULL UNIQUE,
  generation INTEGER NOT NULL,
  started_at TEXT NOT NULL
);

CREATE TABLE operations (
  operation_id TEXT PRIMARY KEY,
  idempotency_key TEXT UNIQUE,
  operation_type TEXT NOT NULL
    CHECK (operation_type IN ('draft-save','import','publish','rollback','runtime')),
  request_hash TEXT NOT NULL,
  state TEXT NOT NULL,
  generation INTEGER NOT NULL,
  actor_ref TEXT NOT NULL,
  source_etag TEXT,
  source_version TEXT,
  allocated_version TEXT,
  snapshot_key TEXT,
  published_hash TEXT,
  manifest_hash TEXT,
  semantic_state TEXT,
  response_json TEXT,
  error_code TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  expires_at TEXT
);
```

`response_json` is limited to 16 KiB and must pass the terminal API response
schema. No table stores content bodies, questions, answers, history, identity
claims, tokens, IPs, credentials, prompts, or provider payloads.

`operation_id` is a server-generated UUID. `idempotency_key` is required only
for publish/rollback and null for ETag-serialized draft/import/runtime
mutations. An atomic admission transaction inserts the operation and singleton
row. `resource_heads` stores only the last coordinator-committed revision,
version, ETag, and hash; it is the strong concurrency cursor, not readable
content. Checkpoint writes compare the stored generation and allowed predecessor
state. Illegal regressions or skipped states are integrity failures. Terminal
handling stores the sanitized result, advances the applicable resource head,
removes `active_operation`, and sets `expires_at = completedAt + 7 days` for
idempotent operations in one transaction. Non-idempotent ETag operations may be
removed after 24 hours. Active rows never expire. Cleanup deletes expired
operations in bounded batches of 100.

The first approved environment seed initializes heads from fully validated KV
values. Later requests compare KV hashes with the recorded heads; an unexpected
external write is an integrity failure requiring human reconciliation. Content
bodies remain solely in KV.

## Cache representation

Internal Cache API responses contain only the exact successful public chat
response plus:

- `Cache-Control` with the approved TTL;
- `Content-Type: application/json`;
- `X-Cache-Schema: chat-response-v1`; and
- a strong ETag over response bytes.

The synthetic key contains only a SHA-256 digest. No cache entry contains the
question or history. Cache values are never used when the current content
version differs, runtime is disabled, the response schema is invalid, or
personal-information policy excludes the request/response.

## Retention and data-boundary matrix

| Data | Location | Retention | Public? |
|---|---|---|---|
| Current draft | KV | Until replaced | No |
| Current publication | KV | Until replaced; previous copy already snapshotted | Yes, through bounded API fields |
| Snapshots | KV | All V1 snapshots | No |
| Runtime state | KV | Current only | Enabled boolean through config |
| Semantic status | KV | Current + four prior versions | Admin only |
| Vector values/minimal metadata | Vectorize | Current + four prior versions | No |
| Idempotency journal | Durable Object SQLite | Seven days after terminal state | No |
| Chat response cache | Cache API | 24 hours supported; 1 hour fallback | Only through authenticated public request path |
| Browser history | Browser memory | Reload/clear | Visitor only |
| Application logs | Cloudflare logs | Target <=7 days where configurable | No |
| Encrypted backup | Owner-controlled location outside repo | Owner-defined and documented before launch | No |

## Migration rules

### Content schema

Migrations are pure functions `vN -> vN+1` with checked input/output hashes.
They never mutate immutable snapshots. A migration produces a new draft/import
artifact; publication requires ordinary review and publish. Unknown versions
are rejected. Reverse export is not promised.

### Embeddings

Any model, tokenizer, pooling, template, dimensions, or metric change creates a
new `embeddingVersion`, new Vectorize index, new calibration artifact, and new
published manifest. Old/new vectors are never mixed. Follow the
[embedding migration runbook](runbooks/embedding-migration.md).

### Coordinator

SQLite migrations are numbered, transactional, forward-only, and applied in the
constructor under a short initialization concurrency block. Migration code
performs no external I/O. A failed migration prevents admin mutations and
leaves public KV reads available. Production migration requires staging restore
and recovery evidence plus owner approval.

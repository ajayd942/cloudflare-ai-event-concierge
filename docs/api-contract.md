# API Contract

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Contract rules

- All APIs are HTTPS JSON. Request and response bodies use UTF-8.
- Public routes are `/health` and `/api/v1/*`; admin routes are
  `/admin/api/v1/*`.
- Request objects are closed: unknown fields are rejected.
- JSON numbers must be finite. Timestamps are UTC RFC 3339 strings with `Z`.
- IDs use the exact formats in the [data model](data-model.md).
- A request body must meet its byte limit before JSON parsing and its field
  limits after Unicode NFKC normalization.
- Successful mutation responses are not cacheable. Chat responses use
  `Cache-Control: no-store` at the browser boundary even when an internal Cache
  API entry exists.
- Breaking changes require `/v2`. Additive optional response fields may be
  introduced in V1 only when old clients can ignore them safely.
- Public messages are generic. Admin errors may include bounded field paths and
  recovery actions but never stack traces, provider bodies, scores, prompts,
  tokens, identities, or secret/configuration values.

## Common headers

| Header | Direction | Contract |
|---|---|---|
| `Content-Type` | both | Request bodies require `application/json` with optional `charset=utf-8`; JSON responses use `application/json; charset=utf-8` |
| `Origin` | request | Chat/config require an exact allowed public origin; state-changing admin requests require the exact Worker origin |
| `Vary: Origin` | response | Present on CORS-enabled public responses |
| `X-Request-ID` | response | Server-generated UUID; distinct from the client request ID and safe to quote to support |
| `ETag` | response | Strong opaque entity tag on draft, runtime config, export, and public config reads |
| `If-Match` | request | Exactly one strong ETag on draft/import/runtime mutations and publish |
| `Idempotency-Key` | request | UUID v4 required for publish and rollback; replay guarantee is seven days |
| `Idempotency-Replayed` | response | `true` only when a stored terminal result is replayed |
| `Retry-After` | response | Integer seconds on rate limits, busy coordinator, or active idempotent operation |

Multiple `If-Match` values, weak ETags, `*`, multiple idempotency-key headers,
or malformed UUIDs are rejected. ETags are opaque to clients.

## Common scalar contracts

| Name | Contract |
|---|---|
| `ClientRequestId` | UUID v4 string |
| `ServerRequestId` | Server-generated UUID string |
| `ContentVersion` | 26-character uppercase canonical ULID |
| `EntryId` | 3–64 lowercase ASCII characters matching `^[a-z0-9]+(?:-[a-z0-9]+)*$` |
| `IdempotencyKey` | UUID v4 |
| `Question` | 1–500 Unicode scalar values after NFKC, trim, and whitespace collapse; no NUL or disallowed control characters |
| `Reason` | 1–500 Unicode scalar values after normalization |
| `HttpsUrl` | Absolute HTTPS URL, at most 2,048 characters, no username/password, host on the environment-approved content-link allowlist |

## Error envelope

```json
{
  "error": {
    "code": "DRAFT_CONFLICT",
    "message": "This draft changed elsewhere. Refresh and reconcile your changes.",
    "requestId": "1d70e160-93fb-4f5f-a80e-8f44d8f10313",
    "retryable": false,
    "fieldErrors": [
      {
        "path": "entries.0.title",
        "code": "TOO_LONG",
        "message": "Use 120 characters or fewer."
      }
    ]
  }
}
```

`fieldErrors` is optional, admin/validation-only, limited to 50 items, and each
path is at most 200 characters. The server client response never contains a
provider name or raw exception.

### Stable status mapping

| HTTP | Code | Meaning |
|---:|---|---|
| 400 | `INVALID_REQUEST` | Malformed JSON, closed-schema failure, invalid header, or semantic validation failure |
| 400 | `INVALID_CONTENT` | Draft/import/snapshot content violates the content contract |
| 401 | `AUTHENTICATION_REQUIRED` | Access assertion is missing |
| 403 | `FORBIDDEN` | JWT, allowlist, origin, or authorization check failed |
| 404 | `NOT_FOUND` | Route or requested snapshot is absent |
| 409 | `DRAFT_CONFLICT` | `If-Match` does not equal the current draft ETag |
| 409 | `IDEMPOTENCY_CONFLICT` | Same key was used for a different normalized operation |
| 409 | `PUBLISH_BUSY` | Another environment content transition is active |
| 409 | `INTEGRITY_CONFLICT` | An immutable key or deterministic side effect exists with a different hash |
| 413 | `BODY_TOO_LARGE` | Byte limit exceeded before parsing |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | JSON content type is absent/invalid |
| 428 | `PRECONDITION_REQUIRED` | Required `If-Match`, confirmation, or idempotency header is absent |
| 429 | `RATE_LIMITED` | Edge/application rate control rejected chat |
| 500 | `INTERNAL_ERROR` | Unexpected classified internal failure |
| 502 | `UPSTREAM_FAILURE` | Required provider failed and no safe deterministic response exists |
| 503 | `ASSISTANT_DISABLED` | Runtime switch is off |
| 503 | `ASSISTANT_UNAVAILABLE` | Required content/configuration is unavailable or invalid |
| 503 | `ADMIN_UNAVAILABLE` | Required admin coordinator or protected dependency is unavailable |

Turnstile failures use `400 INVALID_VERIFICATION` for bad/expired tokens and
`503 ASSISTANT_UNAVAILABLE` for Siteverify service failure. A token failure is
not an authentication assertion about the visitor.

## Public API

### `GET /health`

No AI, Vectorize, Anthropic, Turnstile, Access, or coordinator call is allowed.
The handler validates ordinary configuration shape and checks whether runtime
and published KV documents are readable and schema-valid.

Response `200`:

```json
{
  "status": "ok",
  "serviceVersion": "1.0.0",
  "contentAvailable": true
}
```

Response `503`:

```json
{
  "status": "degraded",
  "serviceVersion": "1.0.0",
  "contentAvailable": false
}
```

No environment/resource ID, content version, model, hostname allowlist, or error
detail is public. `Cache-Control: no-store`.

### `GET /api/v1/config`

Requires an allowed `Origin`. No Turnstile or rate-limit call is made.

Response `200`:

```json
{
  "enabled": true,
  "title": "Event Assistant",
  "welcomeMessage": "How can I help with the event?",
  "suggestedQuestions": [
    "Where is the event?"
  ],
  "demoNotice": "Demonstration project — information is fictional or sanitized.",
  "privacyNotice": "Do not include personal information. Questions may be sent to an AI provider and are not stored by this application by default.",
  "contentVersion": "01JAZ6M8K0ABCDEF1234567890"
}
```

| Field | Contract |
|---|---|
| `enabled` | Boolean runtime state |
| `title` | 1–80 characters |
| `welcomeMessage` | 1–500 characters |
| `suggestedQuestions` | 0–6 items, each 1–120 characters |
| `demoNotice` | 1–200 characters and must contain the approved disclosure |
| `privacyNotice` | 1–500 characters |
| `contentVersion` | Current ULID |

The strong ETag covers content version, runtime revision, and exact response
bytes. Honor `If-None-Match` with `304`. Use
`Cache-Control: public, max-age=60, s-maxage=60, must-revalidate` and
`Vary: Origin`. Chat independently enforces the current runtime switch, so a
cached UI configuration cannot bypass disablement.

### `POST /api/v1/chat`

Body limit: 16 KiB before parsing.

Request:

```json
{
  "question": "Where is the event?",
  "history": [
    {
      "role": "user",
      "content": "What time does it start?"
    },
    {
      "role": "assistant",
      "content": "The ceremony begins at the time listed in the approved guide."
    }
  ],
  "turnstileToken": "opaque-browser-token",
  "requestId": "bd6057da-7695-4bea-90c2-e1fa3f38bfec"
}
```

| Field | Required | Contract |
|---|---|---|
| `question` | yes | `Question` |
| `history` | no | Defaults to `[]`; 0–4 messages, 500 characters each, 2,000 total |
| `history[].role` | yes | Alternating `user`, `assistant`; first `user`, last `assistant` |
| `history[].content` | yes | 1–500 characters after normalization |
| `turnstileToken` | yes | 1–2,048 characters; treated as opaque and never logged |
| `requestId` | yes | `ClientRequestId` |

History represents at most two complete prior turns. The current question is
not repeated in history. A history-bearing request bypasses response caching.

Grounded response `200`:

```json
{
  "answer": "The event is at the venue described in the approved guide.",
  "sources": [
    {
      "id": "venue-location",
      "title": "Event venue",
      "links": [
        {
          "label": "View map",
          "url": "https://example.com/event-map"
        }
      ]
    }
  ],
  "requestId": "bd6057da-7695-4bea-90c2-e1fa3f38bfec",
  "cached": false,
  "responseMode": "canonical",
  "contentVersion": "01JAZ6M8K0ABCDEF1234567890",
  "retrievalVersion": "hybrid-v1",
  "embeddingVersion": "bge-small-cls-template-v1",
  "promptVersion": "grounded-v1"
}
```

Fallback response `200` has the fixed answer, an empty `sources` array,
`responseMode: "fallback"`, and no Claude call.

| Field | Contract |
|---|---|
| `answer` | Plain text, 1–4,000 characters; never HTML-authoritative |
| `sources` | 0–4 unique current KV sources in selected rank order |
| `sources[].id` | `EntryId` |
| `sources[].title` | 1–120 characters |
| `sources[].links` | 0–5 approved links; never model-produced |
| `requestId` | Echoes the validated client request ID |
| `cached` | Whether internal Cache API supplied the result |
| `responseMode` | `canonical`, `generated`, or `fallback` |
| version fields | Non-secret exact behavior versions |

Disabled/unavailable/rate/verification outcomes use the error envelope and never
return an `answer` field.

## Admin identity

Every admin route requires `Cf-Access-Jwt-Assertion`. The Worker validates
signature, `alg`, `kid`, exact issuer, audience membership, `exp`, optional
`nbf`, and non-empty `sub`, then applies the configured allowlist. Failure is
`401` only when the assertion is missing; all invalid or unauthorized
assertions are generic `403`.

The API never returns an email or raw subject. It may return the one-way
`actorRef` stored in snapshot/admin metadata.

## Admin API

### `GET /admin/api/v1/content?view=draft|published`

`view` is required and has no other values. Returns the exact admin content
representation defined in `data-model.md`. The draft response includes
`ETag: "draft-r<revision>-<digest>"`; published includes
`ETag: "content-<contentVersion>-<digest>"`. `Cache-Control: no-store`.

Response:

```json
{
  "view": "draft",
  "document": {
    "schemaVersion": 1,
    "draftRevision": 4,
    "baseContentVersion": "01JAZ6M8K0ABCDEF1234567890",
    "presentation": {
      "title": "Event Assistant",
      "welcomeMessage": "How can I help with the event?",
      "suggestedQuestions": [
        "Where is the event?"
      ],
      "demoNotice": "Demonstration project — information is fictional or sanitized.",
      "privacyNotice": "Do not include personal information."
    },
    "entries": []
  }
}
```

Audit fields may appear for the protected admin but are removed from default
exports.

### `PUT /admin/api/v1/draft`

Body limit: 512 KiB. Requires `If-Match`. The body is the complete editable
`presentation` and `entries` payload; clients must not send `draftRevision`,
timestamps, actor fields, or content versions.

```json
{
  "presentation": {
    "title": "Event Assistant",
    "welcomeMessage": "How can I help with the event?",
    "suggestedQuestions": [
      "Where is the event?"
    ],
    "demoNotice": "Demonstration project — information is fictional or sanitized.",
    "privacyNotice": "Do not include personal information."
  },
  "entries": [
    {
      "id": "venue-location",
      "title": "Event venue",
      "category": "venue",
      "questions": [
        "Where is the event?"
      ],
      "keywords": [
        "venue",
        "location"
      ],
      "answer": "The fictional event takes place at the demonstration venue.",
      "links": [
        {
          "label": "View map",
          "url": "https://example.com/event-map"
        }
      ],
      "enabled": true,
      "sortOrder": 10
    }
  ]
}
```

Response `200` returns the saved draft, its incremented server revision, and a
new ETag. No-op saves are rejected as `400 INVALID_REQUEST`; they do not consume
a same-key KV write.

### `POST /admin/api/v1/preview`

Body limit: 16 KiB. Requires the current draft `If-Match`. Preview uses the
saved draft only.

```json
{
  "question": "How do I find the venue?",
  "history": [],
  "requestId": "f2746184-9886-4631-a04d-827587112c3f"
}
```

Response `200`:

```json
{
  "answer": "The fictional event takes place at the demonstration venue.",
  "sources": [
    {
      "id": "venue-location",
      "title": "Event venue",
      "links": []
    }
  ],
  "responseMode": "generated",
  "retrievalMode": "hybrid-preview",
  "selected": [
    {
      "id": "venue-location",
      "lexicalScore": 0.61,
      "semanticScore": 0.84,
      "fusedScore": 0.72,
      "accepted": true
    }
  ],
  "warnings": [],
  "requestId": "f2746184-9886-4631-a04d-827587112c3f"
}
```

Scores are finite numbers in `[0,1]`, rounded to three decimals, maximum eight
candidate rows. They are admin diagnostics only.

### `POST /admin/api/v1/publish`

Body limit: 16 KiB. Requires current draft `If-Match`,
`Idempotency-Key`, `confirmed: true`, and a nonempty reason.

```json
{
  "confirmed": true,
  "reason": "Approve the reviewed fictional venue update."
}
```

Response `200`:

```json
{
  "status": "completed",
  "contentVersion": "01JAZ7QCH0ABCDEF1234567890",
  "sourceDraftRevision": 4,
  "semanticStatus": "ready",
  "smokeStatus": "passed",
  "warnings": [],
  "publishedAt": "2026-07-23T12:00:00Z"
}
```

Response `202` for the same active key/hash:

```json
{
  "status": "in_progress",
  "operation": "publish"
}
```

`status` is `completed` or `completed_with_warnings` at terminal success.
`semanticStatus` is `ready` or `pending` at publication time; initial upsert
failure prevents publication. `warnings` is a closed enum array limited to:
`SMOKE_CHECK_FAILED`, `VECTOR_CLEANUP_PENDING`, or
`SEMANTIC_READINESS_PENDING`.

### `GET /admin/api/v1/snapshots?limit=<n>&cursor=<opaque>`

`limit` defaults to 20 and is 1–20. Cursor is an opaque base64url value at most
512 characters. The endpoint returns newest first and never lists more than 20
per page.

```json
{
  "items": [
    {
      "contentVersion": "01JAZ6M8K0ABCDEF1234567890",
      "capturedAt": "2026-07-23T11:59:59Z",
      "actorRef": "sha256:5Kp3oP0cGdQH2l2h2z7JXg",
      "reason": "publish",
      "entryCount": 24,
      "contentHash": "sha256:QvX7W9q7m9mHfYv74tBvpg",
      "restoredFromVersion": null
    }
  ],
  "nextCursor": null
}
```

The list contains metadata only, not complete content.

### `POST /admin/api/v1/rollback/:version`

`:version` is a canonical ULID. Requires `Idempotency-Key`, `confirmed: true`,
and reason. It does not use the draft ETag because the immutable snapshot is the
source.

```json
{
  "confirmed": true,
  "reason": "Restore the last reviewed content after an incorrect publication."
}
```

The terminal response has the publish response shape plus
`restoredFromVersion`. The new `contentVersion` must differ from the source.

### `GET /admin/api/v1/export?view=draft|published`

Returns a JSON attachment with
`Content-Disposition: attachment; filename="event-concierge-<view>-<version>.json"`.
The body has:

```json
{
  "exportSchemaVersion": 1,
  "view": "published",
  "exportedAt": "2026-07-23T12:10:00Z",
  "document": {}
}
```

Default export removes `updatedByRef`, `publishedByRef`, coordinator metadata,
and all environment/resource identifiers. The ETag covers the exported bytes.
`Cache-Control: no-store`.

### `POST /admin/api/v1/import`

Body limit: 512 KiB. Requires current draft `If-Match` and
`mode: "validate"` or `mode: "replace-draft"`. `replace-draft` additionally
requires `confirmed: true`.

```json
{
  "mode": "validate",
  "document": {
    "exportSchemaVersion": 1,
    "view": "draft",
    "exportedAt": "2026-07-23T12:10:00Z",
    "document": {}
  }
}
```

Validation response returns a bounded diff summary, content counts, and field
errors. Replace response returns the new draft/ETag. Import never publishes,
accepts actor fields, or trusts export timestamps.

### `GET /admin/api/v1/runtime-config`

```json
{
  "schemaVersion": 1,
  "revision": 2,
  "enabled": true,
  "updatedAt": "2026-07-23T12:00:00Z",
  "updatedByRef": "sha256:5Kp3oP0cGdQH2l2h2z7JXg",
  "reason": "Enable after approved smoke checks."
}
```

Returns a strong runtime ETag and `Cache-Control: no-store`.

### `PUT /admin/api/v1/runtime-config`

Requires current runtime `If-Match`, `confirmed: true`, and reason.

```json
{
  "enabled": false,
  "confirmed": true,
  "reason": "Pause while the provider outage is investigated."
}
```

The server increments revision and derives audit fields. A no-op is rejected.
Turning the assistant on is a protected content/runtime action but does not
authorize the wedding-site feature flag or production deployment.

## CORS contract

| Route | Allowed origins | Methods | Allowed request headers |
|---|---|---|---|
| `/api/v1/config` | Exact environment public allowlist | `GET`, `OPTIONS` | `Content-Type` |
| `/api/v1/chat` | Exact environment public allowlist | `POST`, `OPTIONS` | `Content-Type` |
| `/health` | None required | `GET` | None |
| `/admin/api/v1/*` | No cross-origin CORS | route methods only | None cross-origin |

Valid public preflight returns `204`, exact
`Access-Control-Allow-Origin`, `Vary: Origin`,
`Access-Control-Allow-Methods`, the minimum headers, and
`Access-Control-Max-Age: 600`. Invalid origins receive generic `403` without
CORS reflection. Credentials are not enabled on public CORS.

## Security headers

All JSON responses set `X-Content-Type-Options: nosniff`,
`Referrer-Policy: no-referrer`, a restrictive `Permissions-Policy`, and
`Cache-Control` appropriate to the endpoint. Static CSP/frame policy is defined
in [security.md](security.md). The versioned widget script is intentionally
cross-site loadable and uses `Cross-Origin-Resource-Policy: cross-origin`; admin
HTML is never frameable.

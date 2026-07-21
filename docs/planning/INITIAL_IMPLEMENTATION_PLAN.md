# Master Implementation Plan: Cloudflare AI Event Concierge

> **Status: Approved planning baseline — implementation still requires the documented design, task-graph, PR, and production approval gates.**
>
> Decision baseline approved by the repository owner on 2026-07-22. Approved PRD, HLD, LLD, ADRs, and Linear acceptance criteria may refine this plan; when they do, the reviewed artifact takes precedence and must update the relevant decision record.

## How to use this plan

- This document defines the complete intended outcome and approved starting constraints.
- The approved decision IDs below provide traceability for design and implementation work.
- Symphony creates the formal design documents, task graph, code, tests, and review evidence.
- Draft documents and unapproved Linear issues provide context only; they do not authorize implementation.
- Human-only actions include scope and design approval, task-graph approval, secrets, production configuration, PR merge, deployment, rollback, and changes to trust policy.

## Approved decision baseline

### Product boundary and portfolio intent

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| P-01 | Product | Build a reusable public event-concierge RAG application, demonstrated with sanitized wedding content. | The architecture is reusable; the demo is clearly a demonstration rather than a live guest service. |
| P-02 | Primary audience | Optimize for prospective freelance clients and technical reviewers, with public visitors as secondary users. | Documentation and proof of engineering quality are first-class deliverables. |
| P-03 | V1 scope | Keep the existing V1 inclusions and exclusions; do not add RSVP lookup, accounts, persistence, uploads, voice, WhatsApp, D1, or multi-tenancy. | Prevents a portfolio project from becoming a product platform. |
| P-04 | Public data | Use fictional or sanitized event content in GitHub, staging, production demo, screenshots, and recordings. | No private guest or historical wedding data enters public artifacts. |
| P-05 | Demo disclosure | Display a persistent “Demonstration project — information is fictional or sanitized” notice in the widget, demo, and README. | Visitors cannot mistake the assistant for an active wedding service. |
| P-06 | Wedding-site integration | Embed the same versioned widget in the existing React/Vite wedding site behind a feature flag. | Demonstrates real integration without coupling the Worker to the Java backend. |
| P-07 | Repository strategy | Keep the concierge in the separate public `cloudflare-ai-event-concierge` repository; make only the widget integration change in the wedding repository. | The portfolio code remains inspectable and reusable. |
| P-08 | License | Use the MIT license unless an existing dependency or asset requires a different compatible license. | Maximizes portfolio reuse while preserving attribution. |
| P-09 | Languages | English-only content and retrieval in V1. | The selected embedding model and evaluation set stay focused; multilingual support is a future ADR. |
| P-10 | Availability target | Treat this as a best-effort portfolio service, not a contractual high-availability system. | Document graceful degradation and recovery without inventing an SLA. |

### Development lifecycle and Symphony authority

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| G-01 | Work generator | After bootstrap, Symphony produces the product documents, HLD, ADRs, LLD, threat model, test strategy, implementation task graph, code, tests, and PR evidence. | The owner reviews; the owner does not manually author the planned deliverables. |
| G-02 | Human role | Reserve scope approval, design approval, task-graph approval, secrets, production settings, merge, deployment, and rollback for the human owner. | Automation cannot grant itself authority. |
| G-03 | Seed work | Manually create only four initial Linear issues: product definition, HLD/ADRs, detailed design, and implementation task-graph generation. | Solves the orchestration bootstrap problem without manually decomposing implementation. |
| G-04 | Seed dependencies | Make each seed issue depend on human approval of the previous issue. | Symphony cannot race ahead of review gates. |
| G-05 | Design dispatch exception | Add a `design-only` label and a narrow dispatch rule allowing approved documentation tasks to run without pre-existing approved design documents. | Removes the current circular dependency while prohibiting application-code changes from design tasks. |
| G-06 | Implementation dispatch | Dispatch implementation only from `Ready for Agent`, with approved linked designs, explicit acceptance criteria, completed dependencies, and no blocking label. | Linear remains the execution control plane. |
| G-07 | Completion boundary | A successful Symphony run stops at `Human Review`; it never merges, deploys, or marks work `Done`. | Every material result reaches the owner before becoming authoritative. |
| G-08 | Symphony environment | Run the official reference implementation locally on the owner’s trusted Mac first, not on a public server. | Reduces runner exposure during the portfolio build. |
| G-09 | Concurrency | Start at one active agent; increase to two only after three successful documentation/code canaries and an explicit owner decision. | Limits simultaneous mistakes while the harness matures. |
| G-10 | Agent sandbox | Use workspace-write isolation with network access only where needed; do not expose Cloudflare or Anthropic production credentials to agent processes. | Agents can build and open PRs but cannot operate production. |
| G-11 | GitHub credential | Use a dedicated fine-grained credential limited to this repository’s contents and pull requests; do not give repository-administration or secrets permissions. | A compromised run cannot change branch protection or repository secrets. |
| G-12 | Linear credential | Use a team-scoped Linear key and expose Linear operations through the runner tool rather than placing the token in agent prompts or workspaces. | Agents can update authorized tickets without receiving the raw token. |
| G-13 | Approval evidence | Record approval as an explicit Linear transition/comment and human merge action; silence never counts. | The audit trail is unambiguous despite a single-owner GitHub repository. |
| G-14 | Source hierarchy | Approved PRD/HLD/LLD/ADRs and issue acceptance criteria override the initial plan; draft documents are context only. | Later validated decisions can supersede early assumptions safely. |

### Repository and toolchain

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| R-01 | Runtime | TypeScript on Cloudflare Workers. | Matches the target freelance work and Cloudflare ecosystem. |
| R-02 | Package manager | Use npm with a committed lockfile and npm workspaces. | Avoids requiring an additional package manager while supporting Worker, admin, widget, and demo packages. |
| R-03 | Node version | Pin the then-current Active LTS release in `.nvmrc` and CI; document the exact version at bootstrap. | Reproducibility without freezing today’s plan to a soon-stale runtime number. |
| R-04 | Worker framework | Use Hono for routing, middleware composition, and typed request handling. | Small Worker-compatible abstraction with portable route tests. |
| R-05 | Validation | Use Zod at every external boundary and derive TypeScript types from schemas where practical. | Runtime validation and compile-time types remain aligned. |
| R-06 | Admin UI | Use React with Vite for the protected admin SPA. | Familiar, maintainable forms and state management for nontechnical workflows. |
| R-07 | Widget | Build a dependency-light TypeScript custom element compiled by Vite, using Shadow DOM and no React runtime. | Portable across React, WordPress, and static HTML with a small payload. |
| R-08 | Demo | Build a static page that embeds the production widget; do not create a second chat implementation. | The demo tests the same artifact clients will embed. |
| R-09 | Unit/integration tests | Use Vitest with Cloudflare’s Workers test utilities. | Worker bindings and runtime behavior are exercised realistically. |
| R-10 | Browser tests | Use Playwright with Chromium and WebKit plus desktop and mobile viewports. | Covers Chrome-like and Safari-like behavior without claiming physical-device automation. |
| R-11 | Style checks | Use ESLint and Prettier with pinned versions. | Deterministic CI and low-friction agent changes. |
| R-12 | Dependency policy | Pin direct dependencies through the lockfile, enable automated vulnerability alerts, and review upgrades through PRs. | Avoids unreviewed runtime drift. |
| R-13 | Node compatibility | Avoid `nodejs_compat` unless an approved dependency demonstrably requires it. | Keeps the Worker closer to native Web APIs and reduces compatibility surface. |

### Deployment topology and environments

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| D-01 | Worker shape | Deploy one Worker per environment serving public APIs, admin APIs, widget assets, admin SPA, and demo assets. | One deployable portfolio unit with path-level security boundaries. |
| D-02 | Production hostname | Use `assistant.vandanawedsajay.uk` as a Worker custom domain. | Clear separation from the existing website and Java `/api` routes. |
| D-03 | Staging hostname | Use `assistant-staging.vandanawedsajay.uk`; local development uses Wrangler/Miniflare. | Stable end-to-end staging without admitting localhost to production CORS. |
| D-04 | Environment isolation | Use separate Workers, KV namespaces, Vectorize indexes, Turnstile widgets/secrets, ordinary variables, and Anthropic keys for staging and production. | No staging action can mutate production data. |
| D-05 | Static assets | Serve Vite outputs with Workers Static Assets and SPA fallback only for `/admin` and `/demo` navigation. | Static files are colocated while API routes remain explicit. |
| D-06 | Wrangler format | Use `wrangler.jsonc`, checked in with only non-secret settings and resource identifiers. | Human-readable, versioned deployment configuration. |
| D-07 | Compatibility date | Pin and deliberately update the Workers compatibility date through reviewed PRs. | Platform changes do not arrive silently. |
| D-08 | Infrastructure management | Use Wrangler for Worker/KV/Vectorize resources; document Access, Turnstile, WAF, DNS, budgets, and notifications as human-run dashboard/API steps in V1. | Avoids adding Terraform before it provides portfolio value. |
| D-09 | Cloudflare plan | Use Cloudflare Workers Free for development, staging, and the public production demo. Never upgrade this portfolio project to Workers Paid. | Design and operate within Free-plan quotas; if a quota becomes restrictive, reduce traffic or disable the assistant instead of enabling paid Workers. |

### Content model and KV ownership

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| C-01 | Authoritative store | KV is authoritative for readable draft and published content; Vectorize is a rebuildable index only. | Loss or corruption of vectors never destroys approved content. |
| C-02 | Document granularity | Store the complete small corpus as one validated JSON document per mutable/published key. | A reader never assembles a partially updated corpus from multiple keys. |
| C-03 | Mutable keys | Use `content:draft`, `content:published`, and `config:runtime`. | Separates editorial work, the public corpus, and the emergency enabled flag. |
| C-04 | Snapshots | Store immutable `content:snapshot:<contentVersion>` values and never overwrite them. | Rollback and audit context survive later publishes. |
| C-05 | Content version | Use a ULID for `contentVersion`; keep ISO-8601 timestamps in separate fields. | Versions are sortable, URL/key safe, and independent of clock-string formatting. |
| C-06 | Schema version | Start with integer `schemaVersion: 1`; require explicit migration code for future versions. | Old snapshots cannot be interpreted accidentally under a new schema. |
| C-07 | Draft concurrency | Add `draftRevision` and require optimistic concurrency with `If-Match`/ETag on draft updates. | Two admin tabs cannot silently overwrite each other. |
| C-08 | Entry IDs | Require stable lowercase kebab-case IDs that never change when titles change. | Vector IDs, sources, tests, and links remain stable. |
| C-09 | Categories | Use a controlled category enum maintained in the content schema, not arbitrary free text. | Filtering and evaluation remain consistent. |
| C-10 | Actor identity | Derive the actor from the validated Access JWT subject; keep audit actor metadata out of public API responses and exports by default. | No caller can forge `updatedBy`, and admin identity is not unnecessarily public. |
| C-11 | Document limit | Limit imported and stored content documents to 512 KiB and 100 enabled entries in V1. | Keeps validation, embedding batches, and lexical scans bounded well below KV’s 25 MiB limit. |
| C-12 | Snapshot retention | Preserve all V1 snapshots; show the newest 20 in the UI and provide export. | Low-volume history is cheap, while UI listing stays manageable. |
| C-13 | Runtime config | Put `enabled` in `config:runtime`; keep title, welcome text, suggested questions, and public notices inside versioned published content. | Emergency disable is independent, while visible configuration rolls back with content. |
| C-14 | KV write behavior | Use explicit save/publish actions, not autosave; never write the same key more than once per second. | Respects KV’s same-key write limit and avoids accidental write churn. |

### Publishing, indexing, and rollback

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| U-01 | Publish authority | Only authenticated, allowlisted admins can publish or roll back; every operation requires confirmation. | Draft editing cannot accidentally become public. |
| U-02 | Publish idempotency | Require a client-generated idempotency key and reject reuse with a different payload. | Retries cannot create multiple content versions. |
| U-03 | Publish sequence | Validate draft → snapshot current published content → allocate version → batch-generate embeddings → upsert vectors → verify representative vectors or mark semantic pending → write the complete `content:published` document once. | Public content never points to a knowingly absent corpus, and lexical retrieval is immediately available. |
| U-04 | Partial semantic readiness | Permit publish after bounded Vectorize readiness checks; expose `semanticStatus: pending\|ready\|failed` to admin and use lexical retrieval until ready. | Eventual indexing does not block a valid content correction. |
| U-05 | Embedding batching | Generate embeddings for all enabled entries in a batch where platform limits allow. | Reduces latency and API overhead. |
| U-06 | Vector cleanup | Retain vectors for the current and four previous content versions; delete older IDs asynchronously using IDs recorded in snapshots. | Supports recent rollback without unbounded index growth. |
| U-07 | Failed publish | Do not change `content:published` if validation, embedding generation, or vector upsert fails before the bounded-readiness decision. | Existing public content remains intact. |
| U-08 | Rollback semantics | Rollback republishes a selected snapshot as a new ULID version and reindexes it; it never rewrites history. | The audit trail remains monotonic. |
| U-09 | Import semantics | Import replaces the draft only after schema validation, diff preview, and confirmation; import never publishes directly. | Bulk editing cannot bypass review. |
| U-10 | Preview | Preview against the current draft using lexical retrieval plus batch embeddings computed in memory; do not mutate the production Vectorize index. | Admin sees realistic draft behavior without polluting published search. |
| U-11 | Smoke verification | After publish, run exact, paraphrase, unsupported, and forced-lexical-fallback probes and display results to the admin. | “Published” includes evidence, not just successful writes. |

### Embeddings and Vectorize

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| V-01 | Embedding model | Use `@cf/baai/bge-small-en-v1.5`, 384 dimensions. | It remains available, inexpensive, and adequate for the small English corpus. |
| V-02 | Pooling | Explicitly use `cls` pooling for both document and query embeddings. | Follows Cloudflare’s current accuracy recommendation and prevents accidental mean/CLS incompatibility. |
| V-03 | Distance metric | Use cosine similarity. | Matches normalized semantic similarity for the chosen model. |
| V-04 | Index version | Name indexes with an embedding-schema suffix such as `event-concierge-bge-small-cls-v1`. | Model, dimension, or pooling changes create a new index instead of corrupting compatibility. |
| V-05 | Partitioning | Put every vector in a Vectorize namespace equal to `contentVersion`; query the current version by namespace. | Version filtering is native and avoids needing a metadata index solely for content version. |
| V-06 | Vector ID | Use `<contentVersion>:<entryId>`. | IDs are deterministic and can be deleted from snapshot manifests. |
| V-07 | Metadata | Store only `entryId`, `category`, `contentVersion`, and `embeddingVersion`; do not return vector values or store answer text. | Results map to KV without duplicating content or exposing unnecessary data. |
| V-08 | Embedding text | Use a versioned canonical template containing title, category, example questions, keywords, and approved answer with normalized whitespace. | Reindexing is reproducible and semantic meaning includes both questions and facts. |
| V-09 | Input bound | Reject/truncate an entry embedding input before the model’s 512-token limit using a documented deterministic policy; validation should normally keep entries below 350 tokens. | Inputs never truncate unpredictably at the provider boundary. |
| V-10 | Query depth | Request semantic top-K 8, merge with all lexical candidates, and send at most 4 final entries to the answer stage. | Provides recall without bloating prompts. |
| V-11 | Model changes | Treat any embedding model, pooling, template, or dimension change as an `embeddingVersion` migration requiring a new index and evaluation. | Old and new vectors are never mixed. |

### Hybrid retrieval and grounding

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| H-01 | Retrieval modes | Keep both deterministic lexical and semantic retrieval in V1. | Exact facts remain precise; paraphrases still work; Vectorize failure degrades safely. |
| H-02 | Normalization | Apply Unicode NFKC, lowercase, whitespace collapse, punctuation normalization, and conservative English stop-word removal; preserve meaningful numbers, dates, URLs, and event names. | Exact facts are not destroyed by aggressive normalization. |
| H-03 | Lexical scoring | Use a documented field-weighted scorer: exact example question > exact title/phrase > question-token overlap > keywords > category/title tokens > answer-body tokens. | Scores are explainable and deterministic for 100 or fewer entries. |
| H-04 | Fusion | Gate candidates by independently calibrated lexical or semantic relevance, then combine normalized signals with an exact-match boost and deterministic tie-breaking by `sortOrder` then ID. | Avoids treating incomparable raw scores as interchangeable. |
| H-05 | Thresholds | Derive numeric lexical and cosine thresholds from the committed evaluation set; do not invent permanent thresholds in the plan. Fail closed until calibration is recorded. | Relevance policy is evidence-based and reproducible. |
| H-06 | Exact FAQ behavior | Return the approved canonical answer directly for an exact example-question match unless multiple entries must be combined. | Highest factual fidelity, lowest latency, and no unnecessary Claude cost. |
| H-07 | Claude use | Use Claude only when relevant approved context passed the retrieval gate and wording/synthesis is useful. | The generation model is never an ungrounded knowledge source. |
| H-08 | Unsupported behavior | Return the fixed approved fallback without calling Claude when no candidate passes. | Unsupported and adversarial questions cannot induce hallucinated answers. |
| H-09 | Vector failure | Continue with lexical retrieval; include an internal degradation field in logs and admin diagnostics, not the public answer. | Public service remains usable without overstating internal failure. |
| H-10 | Retrieval evidence | Record candidate IDs, component scores, selected IDs, retrieval version, and threshold outcome without logging the question text. | Quality failures can be diagnosed without retaining conversations. |
| H-11 | Follow-ups | Support at most the previous two user/assistant turns; use prior user text only as bounded retrieval context and still require current-version sources. | Simple follow-ups work without server-side memory. |
| H-12 | Evaluation separation | Evaluate retrieval selection independently from generated wording. | A good-sounding response cannot hide a retrieval failure. |
| H-13 | Prompt injection | Treat user text and retrieved content as untrusted data inside explicit delimiters; neither can override system policy. | Content-level injection cannot grant capabilities or disclose instructions. |

### Claude answer generation

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| A-01 | Primary model | Pin `claude-haiku-4-5-20251001` as the initial answer model, configurable per environment. | Uses Anthropic’s recommended fast, economical tier without alias drift. |
| A-02 | Promotion rule | Move to a more capable current model only if Haiku fails approved quality targets and the owner approves cost impact. | Model prestige does not replace evaluation evidence. |
| A-03 | API mode | Use non-streaming Messages API responses in V1. | Simplifies Turnstile, error handling, caching, source attachment, and tests. |
| A-04 | Temperature | Use temperature 0 for grounded factual responses. | Minimizes unnecessary variation. |
| A-05 | Output bound | Set `max_tokens` to 300 and instruct concise answers, normally 1–4 short paragraphs or bullets. | Predictable cost and widget-friendly output. |
| A-06 | History bound | Accept at most 4 messages, 500 characters each, 2,000 characters total; never persist history. | Follow-up context remains bounded and private. |
| A-07 | Context bound | Send at most 4 retrieved entries and a configured maximum serialized context size. | Prevents prompt growth and unrelated context dilution. |
| A-08 | Timeout | Use a 10-second upstream timeout and one retry only for `429` or retryable `5xx`, with jittered backoff inside a 15-second total request budget. | Transient errors receive one chance without long hangs or retry storms. |
| A-09 | Provider failure | Return an exact canonical answer when available; otherwise return a generic temporary-unavailable response with no fabricated content. | Degradation remains useful and safe. |
| A-10 | Prompt version | Version the system prompt and include `promptVersion` in diagnostics and cache keys. | Prompt changes are observable and invalidate cached answers. |
| A-11 | Model response handling | Treat the response as plain text; never render provider-generated HTML or execute links not present in approved sources. | Model output cannot inject active content. |
| A-12 | Prompt caching | Do not enable Anthropic prompt caching in V1. | Contexts are small and the additional cache policy is not justified initially. |

### API contract

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| API-01 | Versioning | Use `/api/v1/*` and `/admin/api/v1/*` from the first release. | Breaking contract changes can coexist later. |
| API-02 | Public endpoints | Provide `GET /health`, `GET /api/v1/config`, and `POST /api/v1/chat`. | Minimal public surface. |
| API-03 | Admin endpoints | Keep content, draft, preview, publish, snapshot, rollback, import/export, and runtime configuration under `/admin/api/v1`. | One Access policy protects UI and APIs. |
| API-04 | Chat body | Accept `question`, optional bounded `history`, required `turnstileToken`, and client `requestId`; reject unknown fields. | Request behavior is explicit and replay/debug handling improves. |
| API-05 | Body limits | Limit chat bodies to 16 KiB and content import bodies to 512 KiB before parsing. | Large-body abuse is rejected early. |
| API-06 | Question limit | Limit questions to 500 Unicode characters after normalization and reject empty/control-character-only input. | Keeps embeddings, prompts, and UI bounded. |
| API-07 | Response | Return answer, approved sources, request ID, cache status, response mode (`canonical\|generated\|fallback`), and non-sensitive version identifiers. | Portfolio reviewers can observe grounding without internal secrets. |
| API-08 | Source shape | Return entry ID, title, and only administrator-approved HTTPS links. | Sources are useful and cannot introduce model-generated URLs. |
| API-09 | Error contract | Use the documented stable error envelope and status mapping; user messages stay generic while logs carry categories. | Clients can handle failures without exposing internals. |
| API-10 | Health | Health checks validate configuration/content availability but never call Workers AI, Vectorize, or Anthropic. | Monitoring is cheap and cannot generate AI spend. |
| API-11 | Read caching | Serve public config with ETag and short browser/CDN caching keyed by content version. | Reduces repeat reads without hiding publishes for long. |
| API-12 | Admin concurrency | Return ETags on draft reads and require `If-Match` for mutations. | Lost updates become explicit `409` conflicts. |

### Response caching

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| K-01 | Cache store | Use Cloudflare Cache API for response caching, not high-cardinality KV keys. | KV remains low-write authoritative storage and attackers cannot consume KV write quotas with unique questions. |
| K-02 | Eligible requests | Cache only single-turn, successfully grounded, non-personal responses; bypass cache whenever history is present. | A cached answer cannot ignore conversation context. |
| K-03 | Key | Hash `contentVersion + answerModel + embeddingVersion + retrievalVersion + promptVersion + normalizedQuestion`; never put raw questions in cache URLs or logs. | All behavior-changing inputs invalidate safely without retaining text. |
| K-04 | TTL | Cache supported answers for 24 hours and unsupported fixed fallbacks for 1 hour. | Repeats are inexpensive while corrected content invalidates by version immediately. |
| K-05 | Exclusions | Never cache admin responses, validation errors, rate limits, authentication failures, or upstream failures. | Sensitive and transient states do not persist. |
| K-06 | Cache stampede | Accept occasional duplicate misses in V1; do not add a lock service for portfolio traffic. | Avoids Durable Object complexity without correctness loss. |

### Security, privacy, and abuse prevention

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| S-01 | Public CORS | Configure an exact per-environment allowlist; production includes the canonical wedding origin and assistant demo origin only. Add `www` only after verifying it is an active origin. | No wildcard or speculative hostname access. |
| S-02 | Admin CORS | Reject cross-origin admin requests and validate `Origin` on every state-changing admin request. | Access cookies cannot be used for cross-site mutations. |
| S-03 | Access boundary | Protect `/admin*` with a Cloudflare Access self-hosted application restricted to explicitly approved identities. | Unauthenticated traffic is stopped before admin code. |
| S-04 | Defense in depth | Validate `Cf-Access-Jwt-Assertion` signature, issuer, audience, expiry, and subject in the Worker using cached JWKS. | A forged identity header cannot authorize mutations. |
| S-05 | Admin identity | Maintain an application-level allowlist of Access subjects/emails in non-secret environment configuration in addition to the Access policy. | Misconfiguration at one layer does not automatically grant mutation authority. |
| S-06 | Turnstile | Require a fresh managed/invisible Turnstile token for every chat request and validate it server-side. | Browser-only widget checks cannot be bypassed. |
| S-07 | Token validation | Validate hostname and action, use Siteverify, treat tokens as five-minute/single-use, and reset the widget after every attempt. | Expired and replayed tokens fail safely. |
| S-08 | Rate limiting | Use a Workers Rate Limiting binding at 10 requests/minute per transient IP key plus the zone’s one free WAF rule at 5 requests/10 seconds for `/api/v1/chat`; tune only from observed traffic. | Provides application and edge layers without pretending either is strict accounting. |
| S-09 | Shared IP behavior | Return a friendly retry message and keep limits high enough for normal conversation; do not create persistent browser fingerprints. | Privacy is preferred over aggressive user tracking. |
| S-10 | Global cost control | Use Anthropic spending limits/alerts, Cloudflare usage alerts, maximum output/context, the runtime kill switch, and no-Claude unsupported responses. | Rate limiting is not the only denial-of-wallet control. |
| S-11 | Security headers | Apply CSP, `X-Content-Type-Options: nosniff`, restrictive `Referrer-Policy`, `Permissions-Policy`, and frame restrictions appropriate to admin/demo; the embeddable widget itself must remain cross-site loadable. | Static surfaces resist common browser attacks without breaking embedding. |
| S-12 | Rendering | Render messages as text nodes; sanitize any deliberately supported formatting; never use raw `innerHTML` for model/content text. | Stored and generated XSS paths are closed. |
| S-13 | Link policy | Accept only HTTPS links in content, validate URL length/host policy, render with safe `rel` attributes, and never create links from untrusted model text. | Approved content controls navigation. |
| S-14 | Secrets | Store local secrets in ignored `.dev.vars`; install production secrets with Wrangler; use least-privilege Cloudflare tokens; never put secrets in GitHub, plans, examples, screenshots, or logs. | Secret material stays outside version control. |
| S-15 | Logging privacy | Do not log raw questions, answers, history, Turnstile tokens, JWTs, emails, IPs, API keys, or full content documents. | Operational telemetry does not become a conversation store. |
| S-16 | Privacy notice | Tell users that questions are sent to an AI provider, are not intended for personal information, and are not stored by the application by default. | Data handling is understandable at the point of use. |
| S-17 | Data scope | Never connect the assistant to RSVP, guest, or existing admin data in V1. | Prompt injection cannot reach private wedding data. |
| S-18 | Dependency security | Enable Dependabot alerts/updates after package bootstrap and add `npm audit --omit=dev` reporting without automatic production upgrades. | Vulnerabilities are visible but changes remain reviewed. |

### Admin experience

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| M-01 | Admin location | Serve the admin SPA at `/admin` from the same Worker and origin as admin APIs. | Simplifies Access, cookies, and CSRF boundaries. |
| M-02 | Save model | Use explicit “Save draft”; show dirty state and warn on navigation. | Prevents KV write churn and accidental loss. |
| M-03 | Delete | Deleting removes an entry from the draft only after confirmation; snapshots preserve prior published history. | Editors can clean drafts without rewriting history. |
| M-04 | Validation | Run field-level browser validation for usability and full Zod document validation in the Worker for authority. | Client validation cannot bypass server rules. |
| M-05 | Preview | Show selected sources, retrieval mode/scores, answer, and warnings in admin preview. | Nontechnical editors can understand why an answer was produced. |
| M-06 | Publish review | Require a diff summary, validation success, content count, and explicit confirmation before publish. | Publishing is deliberate and reviewable. |
| M-07 | Semantic status | Display indexing state and lexical fallback status after publish. | Eventual Vectorize readiness is visible rather than hidden. |
| M-08 | Rollback | Display snapshot version, timestamp, actor reference, and summary; rollback always creates a new version. | Restoration is safe and auditable. |
| M-09 | Import/export | Export draft or published JSON explicitly; import only to draft with preview. | Operators cannot confuse environment state. |
| M-10 | Runtime disable | Put an obvious protected enable/disable control with confirmation and current state. | Emergency shutdown does not require a terminal. |

### Widget and website integration

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| W-01 | Distribution | Publish immutable versioned assets such as `/widget/v1/widget.js`; never mutate an existing major asset contract incompatibly. | Host sites opt into upgrades. |
| W-02 | Styling | Use Shadow DOM and CSS custom properties for supported theming. | Host styles cannot break the widget, while intentional branding remains possible. |
| W-03 | State | Keep conversation state in memory only; clear it on reload or explicit clear. | No browser or server persistence by default. |
| W-04 | Turnstile UX | Render Turnstile explicitly/managed when needed, obtain a fresh token per send, and present recoverable expiry/failure states. | Abuse protection does not silently strand users. |
| W-05 | Mobile | Use a full-screen dialog on small viewports and a floating panel on desktop. | Touch targets and available space are appropriate. |
| W-06 | Accessibility | Target WCAG 2.2 AA: keyboard operation, focus trap/return, Escape close, labels, live regions, contrast, reduced motion, and 44px touch targets. | Accessibility is testable rather than aspirational. |
| W-07 | Asset budget | Target widget JavaScript at ≤50 KiB gzip and CSS at ≤15 KiB gzip, excluding Cloudflare’s Turnstile script. | Embedding does not materially slow the wedding site. |
| W-08 | Website mount | Load the module once and mount the custom element from the shared `Layout.jsx`, outside the router outlet. | The widget survives route navigation without duplication. |
| W-09 | Feature flag | Default the production wedding-site flag to disabled until post-deployment smoke tests pass. | Backend and assets can be verified before public exposure. |
| W-10 | Existing platform | Do not change Java API routes, RSVP behavior, Nginx `/api` proxying, or existing admin authentication. | The portfolio integration has a narrow blast radius. |

### Testing and quality gates

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| T-01 | Test pyramid | Require unit, Worker integration, retrieval evaluation, contract, and Playwright tests; keep real-provider tests as controlled staging smoke tests. | CI is deterministic and provider spend stays bounded. |
| T-02 | Evaluation set | Commit at least 50 sanitized cases: 15 direct, 15 paraphrases, 5 misspellings, 5 ambiguous/follow-up, 5 unsupported, and 5 injection/adversarial. | Both retrieval and refusal behavior receive meaningful coverage. |
| T-03 | Retrieval target | Require ≥95% correct source in top 3 for supported cases and ≥95% correct rejection for unsupported cases before production. | Thresholds have explicit quality goals. |
| T-04 | Critical facts | Require 100% preservation of required dates, times, addresses, and approved URLs in the evaluation set. | “Mostly right” is not acceptable for event logistics. |
| T-05 | Injection target | Require 100% of committed injection cases to avoid system-prompt disclosure, unsupported claims, and unapproved actions. | Security regressions fail the gate. |
| T-06 | Code coverage | Start with ≥80% line and ≥75% branch coverage on Worker domain modules; do not chase coverage in generated UI glue. | Important logic is tested without vanity metrics. |
| T-07 | Browser matrix | CI runs Chromium and WebKit desktop plus representative Android and iPhone viewports; launch includes manual checks in real Chrome and Safari. | Automated and real-browser evidence are distinguished. |
| T-08 | Performance | Target cached/canonical API p95 <500 ms and generated-answer p95 <8 s in staging; document provider-dependent variance. | UX has measurable expectations without an unrealistic SLA. |
| T-09 | Site impact | Require no material layout shift from the closed widget and no more than a 5-point Lighthouse mobile performance regression on the wedding site. | The integration cannot degrade the existing portfolio site silently. |
| T-10 | Failure tests | Explicitly test Vectorize unavailable/stale, Workers AI failure, Claude timeout/429/5xx/malformed output, KV stale/missing, Turnstile failure, Access failure, and disabled mode. | Graceful degradation is verified. |
| T-11 | Publishing tests | Verify concurrency conflicts, idempotency, snapshot creation, new versions, partial semantic readiness, rollback-as-new-version, and old-vector cleanup. | The riskiest state transitions receive direct evidence. |
| T-12 | Production load | Do not load-test real AI providers; load-test mocks and perform only a few budgeted production smoke requests. | Validation cannot create accidental bills. |

### CI/CD and release authority

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| CI-01 | Pull-request checks | Require lockfile install, lint, format check, type-check, unit/integration/evaluation tests, all builds, content validation, dependency audit report, and selected Playwright checks. | Main cannot receive unverified code once checks are configured. |
| CI-02 | Branch protection | After CI exists, require its checks on `main` in addition to the current PR/conversation/force-push protections. | Documented quality gates become GitHub-enforced. |
| CI-03 | Staging deployment | Automatically deploy code to staging after a reviewed merge to `main`. | Every merged change receives realistic validation. |
| CI-04 | Production deployment | Use a manually approved GitHub Environment/workflow dispatch for production; never deploy production directly on merge. | The owner retains release authority. |
| CI-05 | Content deployment | Keep production content publishing in the protected admin application, not CI. | Code releases and editorial releases remain separate. |
| CI-06 | Deployment identity | Use a least-privilege Cloudflare API token scoped to this account/zone/resources and rotate it on a documented schedule or suspected exposure. | CI cannot administer unrelated Cloudflare resources. |
| CI-07 | Anthropic secret | Install Anthropic keys directly as Worker secrets during human-controlled environment bootstrap; do not copy them into GitHub Actions. | GitHub compromise does not reveal the model key. |
| CI-08 | Release evidence | Record commit SHA, Worker deployment ID, compatibility date, smoke results, and rollback target for every production release. | Rollback is actionable. |
| CI-09 | Separate changes | Do not combine a major content publish, embedding migration, and Worker release in one production action. | Failures can be isolated and reversed. |

### Observability and operations

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| O-01 | Logging | Enable Workers structured logs/traces with request ID, CF-Ray, route, status, latency, response mode, cache status, version IDs, selected entry IDs, score summary, model, token counts, and error category. | Operations are diagnosable without retaining conversations. |
| O-02 | Sampling | Keep all errors, admin mutations, publish/rollback events, and a 10% sample of successful public requests; revisit after observing volume. | Useful evidence without excessive logs. |
| O-03 | Retention target | Keep application logs no longer than 7 days where platform controls allow; document actual provider retention if it cannot be configured. | Privacy claims match operational reality. |
| O-04 | Metrics | Track request volume, cache ratio, fallback modes, retrieval rejection, vector degradation, provider latency/errors, rate limits, token usage, publish failures, and current content/index versions. | Quality, spend, and failures are visible. |
| O-05 | Health monitoring | Run an external hourly health check that does not call AI, with owner notification on repeated failure. | Availability problems become visible without model cost. |
| O-06 | Kill switches | Retain three independent controls: runtime `enabled=false`, wedding feature flag off, and Worker rollback. | A failure can be contained at the narrowest layer. |
| O-07 | Runbooks | Document deployment, publish, rollback, embedding migration, secret rotation, provider outage, CORS failure, and unexpected-spend response. | The project demonstrates operations, not just deployment. |
| O-08 | Backup | Export published content after every production publish and keep periodic local encrypted backups outside the public repository. | KV/snapshot mistakes do not become permanent loss. |

### Cost and quota policy

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| Q-01 | Normal budget | Target ≤$5/month excluding the already-owned domain. Cloudflare Workers, KV, Vectorize, Workers AI, Access, Turnstile, and eligible static usage must remain within their Free-plan allowances; only bounded Anthropic usage may incur normal operating cost. | The old wedding-site portfolio demo has no fixed Cloudflare platform subscription. |
| Q-02 | Alerts | Configure usage/spend notifications at 50%, 80%, and 100% of the chosen monthly budgets where providers support them. | Unexpected usage is visible before it becomes material. |
| Q-03 | Anthropic budget | Start with a $5 monthly project limit/alert and increase only after reviewing real traffic and value. | A public demo cannot silently create a large model bill. |
| Q-04 | Model economics | Prefer canonical answers and Haiku; do not call Claude for unsupported requests or admin-independent health checks. | Most predictable questions are near-zero model cost. |
| Q-05 | Vector economics | Keep 384-dimensional vectors and a small retained-version window; this workload remains comfortably inside current Vectorize included usage. | No larger embedding model without measured quality benefit. |
| Q-06 | Cost review | Review provider pricing and model availability immediately before implementation and production launch, then quarterly. | The plan acknowledges that external pricing and model catalogs change. |

### Documentation and portfolio evidence

| ID | Decision | Selected recommendation | Consequence |
|---|---|---|---|
| F-01 | Required documents | Produce PRD/user journeys, HLD/diagrams, ADRs, LLD, API contract, data model, retrieval design, threat model, evaluation strategy, cost model, deployment/runbooks, admin guide, and troubleshooting guide. | Reviewers can trace intent to implementation. |
| F-02 | Decision format | Use individual ADR files rather than one growing `decisions.md`. | Decisions remain reviewable, linkable, and supersedable. |
| F-03 | Public evidence | Provide live demo, embedded example, architecture diagram, desktop/mobile/admin screenshots, short recording, CI badge, evaluation summary, and sanitized dataset. | Portfolio claims have direct proof. |
| F-04 | README claims | State measured results and actual deployed services only; do not claim production scale, strict rate accuracy, or zero hallucinations. | Marketing remains credible. |
| F-05 | Upwork framing | Describe the project as a custom hybrid-RAG deployment with Cloudflare infrastructure, secure administration, portable embedding, testing, and operations. | Directly maps to the target freelance job without pretending it was client work. |
| F-06 | Known limitations | Document English-only retrieval, small curated corpus, KV eventual consistency, approximate/local rate limits, non-streaming responses, no conversation persistence, and no private-data integration. | Technical honesty strengthens the demonstration. |

### Quantified initial defaults

These are starting defaults, not claims that tuning is unnecessary. Any change must be evaluation-backed and documented.

| Setting | Selected default |
|---|---:|
| Enabled content entries | Maximum 100; target 20–30 initially |
| Content/import document | 512 KiB maximum |
| Chat request body | 16 KiB maximum |
| Question | 500 Unicode characters maximum |
| History | 4 messages; 500 characters/message; 2,000 total |
| Semantic query | Top-K 8 |
| Final context | Maximum 4 entries |
| Claude output | 300 tokens maximum |
| Claude upstream timeout | 10 seconds |
| Total chat time budget | 15 seconds |
| Claude retries | 1, only retryable `429`/`5xx` |
| Supported-answer cache | 24 hours |
| Unsupported-fallback cache | 1 hour |
| Application rate limit | 10 requests/minute/transient IP key/location |
| Edge burst rule | 5 requests/10 seconds on chat path |
| Vector versions retained | Current plus 4 previous |
| Snapshots shown | Latest 20; all retained in V1 |
| Success-log sampling | 10%; errors/admin mutations 100% |
| Target log retention | 7 days where configurable |
| Widget JS budget | 50 KiB gzip, excluding Turnstile |
| Widget CSS budget | 15 KiB gzip |
| Evaluation cases | At least 50 |
| Retrieval top-3 accuracy | At least 95% on supported cases |
| Unsupported rejection | At least 95% |
| Critical-fact preservation | 100% on committed cases |
| Injection safety | 100% on committed cases |
| Initial Symphony concurrency | 1 |
| Normal monthly operations target | ≤$5 excluding domain; Cloudflare Workers must remain Free |

## 1. Project outcome

Build a portfolio-quality, reusable AI knowledge assistant, deploy it on Cloudflare, and embed it into [vandanawedsajay.uk](https://vandanawedsajay.uk).

The finished product will demonstrate:

- Cloudflare Workers and Wrangler
- Workers KV
- Anthropic/Claude integration
- Secure secret management
- Grounded AI answers
- Portable website embedding
- CORS and abuse protection
- A nontechnical admin interface
- Automated tests and deployment
- Production monitoring and rollback

The existing wedding frontend is React/Vite, with its shared layout in `frontend/src/components/Layout.jsx`. This provides a clean place to mount the assistant across every page without changing the existing Java APIs or Nginx `/api` routing.

## 2. Final product

Visitors see a floating “Ask us” button on the wedding website. Opening it displays a chat window.

The assistant can answer approved questions such as:

- What events are planned?
- Where is the venue?
- What should I wear?
- Is transportation available?
- Where can I RSVP?
- Is parking available?
- What time should guests arrive?

The assistant must answer only from content published by an administrator. If information is unavailable, it says so rather than inventing an answer.

A separate admin interface lets a nontechnical user:

- Add and edit FAQs
- Disable outdated entries
- Preview changes
- Publish a new content version
- Restore a previous version
- Import or export content
- Change the assistant welcome message
- Temporarily disable the assistant

## 3. Recommended architecture

```mermaid
flowchart LR
    A["Wedding website<br/>React and Vite"] --> B["Portable chat widget"]
    D["Standalone portfolio demo"] --> B
    B -->|POST /api/v1/chat| C["Cloudflare Worker"]
    C --> E["Input validation"]
    E --> F["Hybrid retrieval"]
    F --> G["Vectorize<br/>Semantic search"]
    G --> I["Workers KV<br/>Published knowledge"]
    I --> H["Claude API"]
    H --> C
    C -->|Grounded answer and sources| B

    J["Admin user"] --> K["Cloudflare Access"]
    K --> L["Admin application"]
    L -->|Draft, publish, rollback| C
    C --> G
    C --> I
```

### Deployment locations

- Main site: `https://vandanawedsajay.uk`
- Assistant API and assets: `https://assistant.vandanawedsajay.uk`
- Public portfolio demo: `https://assistant.vandanawedsajay.uk/demo`
- Protected admin page: `https://assistant.vandanawedsajay.uk/admin`

### Repository strategy

Use the separate public repository `cloudflare-ai-event-concierge`.

Keep the existing wedding platform in its current repository. Only add the widget integration there. This makes the Worker, KV, AI, admin, and deployment work easy for prospective clients to inspect.

## Symphony-first delivery lifecycle

The repository and Linear workspace are bootstrapped manually once. After that, Symphony performs the planned engineering work and the owner reviews its output.

### Bootstrap the runner

1. Merge the engineering-foundation PR after human review.
2. Make the repository-owned `WORKFLOW.md` executable by adding validated Symphony YAML configuration.
3. Run the official Symphony reference implementation on the owner's trusted Mac.
4. Load the team-scoped Linear token from macOS Keychain without exposing it to agent workspaces.
5. Give the runner a dedicated, fine-grained GitHub credential limited to this repository's contents and pull requests.
6. Configure workspace-write isolation, required network access, structured logs, retries, timeouts, and one-agent concurrency.
7. Configure active states so `Human Review`, `Needs Human Decision`, `Blocked`, and terminal states stop autonomous execution.
8. Verify that the runner cannot access Cloudflare or Anthropic production credentials and cannot merge or deploy.

### Create only the seed issue chain

Create four initial Linear issues; do not manually create the implementation task graph.

1. **Product definition:** produce PRD, use cases, non-goals, success metrics, privacy boundaries, and charter updates.
2. **HLD and ADR proposals:** produce architecture diagrams, trust boundaries, deployment topology, cost analysis, and individual ADRs. Blocked by approval of seed issue 1.
3. **Detailed design package:** produce LLD, API contract, data schemas, retrieval design, threat model, evaluation strategy, operations, and rollback design. Blocked by approval of seed issue 2.
4. **Implementation task graph:** create the complete Linear DAG with scoped tasks, dependencies, acceptance criteria, test evidence, design links, and control labels. Blocked by approval of seed issue 3.

Documentation seed issues use the `design-only` label. That label permits documentation changes only and does not authorize application code, infrastructure mutation, secrets, or deployment. Every seed run opens a PR and stops at `Human Review`.

### Approve and dispatch implementation

1. The owner reviews each document PR and either requests changes or records approval.
2. The task-graph issue creates proposed implementation issues in `Plan Review`, never directly in `Ready for Agent`.
3. The owner approves the task graph and moves only eligible, unblocked issues to `Ready for Agent`.
4. Symphony implements one issue per isolated workspace, runs required verification, opens a PR, assigns the owner, and stops at `Human Review`.
5. The owner alone authorizes merge, staging validation, production configuration, deployment, rollback, and `Done`.

### Canary policy

Run a harmless documentation-only canary first. Keep concurrency at one until at least three runs have produced correctly scoped PRs, complete evidence, safe Linear transitions, and no credential or authority violations. Raising concurrency requires a new explicit owner decision.

## 4. Phase 0: Lock down the MVP

Use the approved baseline in this plan as input to the Symphony-generated PRD, HLD, LLD, threat model, test strategy, and individual ADR files. Implementation begins only after the applicable documents and Linear task graph are explicitly approved.

### Included in version 1

- TypeScript Cloudflare Worker
- Workers KV content storage
- Cloudflare Vectorize semantic-search index
- Cloudflare Workers AI embedding generation
- Anthropic Messages API integration
- Hybrid FAQ retrieval: exact/keyword scoring plus semantic vector search
- Grounded answers with source titles
- Portable JavaScript widget
- Public standalone demo
- Admin content editor
- Draft, publish, snapshot, and rollback workflow
- Cloudflare Access authentication
- CORS allowlist
- Request validation
- Turnstile and rate limiting
- Response caching
- Unit, integration, and browser tests
- Staging and production environments
- Custom subdomain
- CI/CD
- Documentation and portfolio assets

### Explicitly excluded from version 1

- User accounts
- Conversation persistence
- Personalized RSVP lookup
- Access to private guest information
- Voice input
- File or PDF uploads
- Multiple customers or tenants
- Complex analytics dashboard
- D1 database
- WhatsApp integration

These can become future enhancements after version 1 is deployed and stable.

## 5. Phase 1: Accounts, credentials, and prerequisites

### Cloudflare

Confirm access to the Cloudflare account managing `vandanawedsajay.uk`.

Prepare:

- Cloudflare account ID
- Permission to deploy Workers
- Permission to create KV namespaces
- Permission to configure Worker custom domains
- Permission to configure Cloudflare Access
- Permission to configure Turnstile and rate limiting
- Permission to edit DNS if required

For automated deployment, create a least-privilege API token with only the necessary Worker, KV, and zone permissions. Do not use a Global API Key.

### Anthropic

Prepare:

- An Anthropic account
- API billing enabled
- A dedicated API key for this project
- A low monthly usage or spend limit
- Claude Haiku 4.5 enabled for the account, initially pinned as `claude-haiku-4-5-20251001`

Do not reuse a personal development API key in production.

### Local tools

Install or confirm:

- Git
- npm
- Wrangler CLI
- GitHub CLI
- The current Active LTS Node.js release, pinned in `.nvmrc` and CI
- A current Chrome browser
- Access to the wedding website deployment machine

Validate:

```bash
node --version
npm --version
npx wrangler --version
git --version
```

### Secrets policy

Secrets must never appear in:

- Git history
- `.env.example`
- `wrangler.jsonc`
- Screenshots
- Browser JavaScript
- GitHub Actions logs
- README examples

Local secrets go into `.dev.vars`, which must be ignored by Git. Production secrets are installed with Wrangler secret management.

## 6. Phase 2: Create the new project

### Proposed structure

```text
cloudflare-ai-event-concierge/
├── src/
│   ├── index.ts
│   ├── env.ts
│   ├── routes/
│   │   ├── chat.ts
│   │   ├── health.ts
│   │   └── admin.ts
│   ├── services/
│   │   ├── anthropic.ts
│   │   ├── content.ts
│   │   ├── retrieval.ts
│   │   ├── cache.ts
│   │   └── snapshots.ts
│   ├── security/
│   │   ├── cors.ts
│   │   ├── access.ts
│   │   ├── turnstile.ts
│   │   └── validation.ts
│   ├── prompts/
│   │   └── assistant.ts
│   └── types/
│       └── api.ts
├── web/
│   ├── widget/
│   │   ├── widget.ts
│   │   └── widget.css
│   ├── admin/
│   │   └── ...
│   └── demo/
│       └── ...
├── content/
│   ├── sample-content.json
│   └── schema.json
├── scripts/
│   ├── seed.ts
│   ├── export-content.ts
│   └── validate-content.ts
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── evaluation/
├── docs/
│   ├── product-requirements.md
│   ├── architecture.md
│   ├── detailed-design.md
│   ├── api-contract.md
│   ├── data-model.md
│   ├── retrieval-design.md
│   ├── evaluation-strategy.md
│   ├── cost-model.md
│   ├── deployment.md
│   ├── administration.md
│   ├── security.md
│   ├── troubleshooting.md
│   ├── runbooks/
│   │   └── ...
│   └── adr/
│       └── ...
├── .github/workflows/
│   ├── ci.yml
│   └── deploy.yml
├── .dev.vars.example
├── .gitignore
├── package.json
├── tsconfig.json
├── vitest.config.ts
├── wrangler.jsonc
├── LICENSE
└── README.md
```

### Technical stack

- TypeScript
- Cloudflare Workers using native Web APIs; enable `nodejs_compat` only through an approved dependency decision
- Hono for routing and middleware
- Zod for runtime validation and derived TypeScript boundary types
- npm workspaces with a committed lockfile
- Workers KV
- Cloudflare Vectorize
- Cloudflare Workers AI with `@cf/baai/bge-small-en-v1.5`, 384 dimensions, and explicit `cls` pooling
- Anthropic Messages API with pinned `claude-haiku-4-5-20251001` for grounded generation
- React and Vite for the protected admin SPA
- A static demo page that embeds the production widget
- A dependency-light TypeScript custom element with Shadow DOM for the portable widget
- Vitest with Workers test utilities
- Playwright with Chromium and WebKit
- ESLint and Prettier with pinned versions

### Environments

Create separate local, staging, and production environments. Local development uses Wrangler/Miniflare, staging uses `assistant-staging.vandanawedsajay.uk`, and production uses `assistant.vandanawedsajay.uk`.

Each deployed environment must have:

- Its own Workers Free deployment
- Its own KV namespace
- Its own versioned Vectorize index
- Its own exact CORS allowlist
- Its own Anthropic secret and low spend controls
- Its own Turnstile sitekey and secret
- Its own Workers AI, Vectorize, Cache API, and rate-limit configuration
- Its own runtime configuration and sanitized content

Serve APIs, the admin SPA, demo, and versioned widget assets from one Worker per environment using Workers Static Assets. Never test content publishing directly against production, and never upgrade this portfolio project to Workers Paid.

## 7. Phase 3: Design the KV content model

Because the knowledge base is small, store the published corpus as one versioned JSON document. This avoids non-atomic updates across multiple KV keys.

### Primary KV keys

```text
content:draft
content:published
content:snapshot:<contentVersion>
config:runtime
```

`content:draft` carries a monotonically increasing `draftRevision`; draft mutations require ETag/`If-Match`. `content:published` contains the complete current corpus and versioned presentation configuration. `config:runtime` contains the emergency `enabled` flag. Snapshots are immutable, all are retained in V1, and the admin UI lists the newest 20.

KV remains the source of truth. Vectorize stores only machine-generated vectors and minimal lookup metadata; response caching uses the Cache API rather than high-cardinality KV keys. Content/import documents are limited to 512 KiB, with at most 100 enabled entries and explicit per-field limits defined by the LLD. Save and publish are explicit actions and never write the same KV key more than once per second.

### Vectorize record model

Each enabled published FAQ entry gets one Vectorize record.

```text
Index:           event-concierge-bge-small-cls-v1 (environment-specific)
Namespace:       <contentVersion>
Vector ID:       <contentVersion>:<entryId>
Vector values:   384-number CLS-pooled embedding
Metadata:        entryId, category, contentVersion, embeddingVersion
Metric:          cosine
```

The embedding input uses a versioned canonical template containing title, category, example questions, keywords, and approved answer with normalized whitespace. Both document and query embeddings explicitly use `pooling: "cls"`. Valid entries should normally remain below 350 embedding tokens and must never reach the model's 512-token limit through silent provider truncation.

Query only the namespace matching the current published KV `contentVersion`. Do not store vector values in responses, the whole answer, secrets, guest data, or draft-only content as Vectorize metadata. Any model, pooling, template, dimension, or metric change requires a new index, `embeddingVersion`, threshold calibration, and evaluation.

### Content format

```json
{
  "schemaVersion": 1,
  "contentVersion": "01K0EXAMPLEULID0000000000",
  "draftRevision": 17,
  "publishedAt": "2026-07-22T10:00:00Z",
  "presentation": {
    "title": "Wedding Assistant",
    "welcomeMessage": "How can I help?",
    "demoNotice": "Demonstration project — information is fictional or sanitized."
  },
  "entries": [
    {
      "id": "venue-location",
      "title": "Wedding venue",
      "category": "Venue",
      "questions": [
        "Where is the wedding?",
        "What is the venue?"
      ],
      "keywords": [
        "venue",
        "location",
        "address",
        "map"
      ],
      "answer": "Approved answer goes here.",
      "links": [
        {
          "label": "View map",
          "url": "https://..."
        }
      ],
      "enabled": true,
      "sortOrder": 10
    }
  ]
}
```

### Content categories

Prepare 20–30 initial sanitized English entries, with a V1 maximum of 100 enabled entries, covering:

- Schedule
- Venue
- Maps and directions
- Arrival time
- Dress code
- Transportation
- Parking
- Accommodation
- Food
- Children
- Accessibility
- Contact information
- Gifts
- Photography
- RSVP
- Website navigation
- General event policies

### Content safety

Do not place these in the assistant corpus:

- Guest lists
- Phone numbers not intended to be public
- Private addresses
- RSVP details
- Admin credentials
- API keys
- Internal notes
- Personally identifying guest data

Because the wedding date shown on the existing site has passed, the public portfolio demo should display a “Demonstration project” label. Public GitHub seed data should be fictional or sanitized.

## 8. Phase 4: Define the API

### Public endpoints

#### `GET /health`

Returns service status without calling Anthropic:

```json
{
  "status": "ok",
  "version": "1.0.0",
  "contentAvailable": true
}
```

It must not reveal secrets, internal IDs, or sensitive configuration.

#### `GET /api/v1/config`

Returns safe UI configuration:

```json
{
  "enabled": true,
  "title": "Wedding Assistant",
  "welcomeMessage": "How can I help?",
  "suggestedQuestions": []
}
```

#### `POST /api/v1/chat`

Request:

```json
{
  "question": "Where is the venue?",
  "history": [],
  "turnstileToken": "...",
  "requestId": "client-generated-uuid"
}
```

Response:

```json
{
  "answer": "The event is being held at ...",
  "sources": [
    {
      "id": "venue-location",
      "title": "Wedding venue",
      "links": [
        {
          "label": "View map",
          "url": "https://..."
        }
      ]
    }
  ],
  "requestId": "...",
  "cached": false,
  "responseMode": "canonical",
  "contentVersion": "01K0EXAMPLEULID0000000000",
  "retrievalVersion": "hybrid-v1"
}
```

Accept at most four history messages, 500 characters each and 2,000 characters total. Use at most the previous two user/assistant turns, never persist them, and bypass response caching whenever history is present. Limit the complete chat body to 16 KiB and the normalized question to 500 Unicode characters.

### Protected admin endpoints

Place admin APIs below `/admin` so one Cloudflare Access policy protects the UI and API:

- `GET /admin/api/v1/content`
- `PUT /admin/api/v1/draft`
- `POST /admin/api/v1/preview`
- `POST /admin/api/v1/publish`
- `GET /admin/api/v1/snapshots`
- `POST /admin/api/v1/rollback/:version`
- `GET /admin/api/v1/export`
- `POST /admin/api/v1/import`
- `PUT /admin/api/v1/runtime-config`

Draft reads return ETags; mutations require `If-Match`. Publish requires a client-generated idempotency key. Reusing a key with the same validated draft returns the original result; reuse with a different payload returns `409 Conflict`. The detailed design must select a serialization primitive that provides the required atomic behavior because KV alone cannot guarantee strict concurrent idempotency.

### Error format

```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Please wait before trying again.",
    "requestId": "..."
  }
}
```

Implement expected status codes:

- `400` invalid request
- `401` authentication required
- `403` forbidden origin or identity
- `404` route or content not found
- `413` body too large
- `429` rate limited
- `500` unexpected internal error
- `502` upstream AI failure
- `503` assistant disabled or unavailable

## 9. Phase 5: Build hybrid content retrieval

Do not send the entire knowledge base to Claude without filtering. Retrieval is the custom RAG layer: it selects relevant approved content before Claude writes an answer.

Version 1 uses two complementary retrieval methods:

- Deterministic lexical retrieval: exact question, phrase, title, category, and keyword scoring.
- Semantic retrieval: Workers AI creates a question embedding and Vectorize returns the nearest FAQ vectors by meaning.

This hybrid approach keeps exact FAQ matches reliable while also handling paraphrases such as “Where will the ceremonies take place?” when the FAQ is titled “Wedding venue.”

### Why version 1 uses both lexical and semantic retrieval

Vectorize semantic search alone would be sufficient for a small FAQ demo, but it is not the only retrieval signal we should trust in a client-facing assistant. Semantic search finds entries that are close in meaning; lexical retrieval identifies exact known terms and phrases. They solve different problems.

| Situation | Lexical retrieval contribution | Semantic retrieval contribution |
|---|---|---|
| Exact prepared FAQ, such as “What is the dress code?” | Strongly selects the known matching entry | Confirms the match |
| Event names, dates, times, URLs, or map-related questions | Preserves precise, explicit matches | Can retrieve related context |
| Natural-language paraphrase, such as “What should I wear?” | May have no strong match unless examples cover it | Finds the dress-code entry by meaning |
| Newly published content | Works immediately from the published KV document | Vectors can take a short time to become queryable |
| Vectorize failure, stale result, or low-confidence result | Provides a low-cost, deterministic fallback | Does not block the response path |

The hybrid ranking intentionally gives a strong boost to an exact FAQ/example-question match. It then combines that result with Vectorize matches so the system handles both factual precision and natural-language variation.

This is not redundant. It provides four practical benefits:

- **Precision:** exact event names, times, URLs, and FAQ phrases should win over merely similar content.
- **Recall:** semantic search finds relevant entries when visitors phrase a question differently from the stored FAQ.
- **Resilience:** the assistant can still use KV-based lexical retrieval while a newly published vector is indexing or if Vectorize is unavailable.
- **Observability:** lexical scores and vector similarity scores can be logged and evaluated independently, making retrieval problems easier to diagnose.

For this small corpus, lexical retrieval has negligible cost and complexity. Keep both mechanisms in version 1; do not call Claude if neither produces a sufficiently relevant approved entry.

### Retrieval process

1. Normalize Unicode.
2. Lowercase the question.
3. Remove punctuation.
4. Tokenize the text.
5. Remove common stop words.
6. Score each enabled content entry using deterministic rules.
7. Create a 384-dimensional embedding for the bounded contextualized question using `@cf/baai/bge-small-en-v1.5` with explicit `cls` pooling.
8. Query Vectorize for the top eight nearest vectors in the namespace equal to the current `contentVersion`.
9. Convert vector matches back into FAQ entry IDs and merge them with all lexical candidates.
10. Gate candidates independently using evaluation-calibrated lexical and cosine thresholds, then combine normalized signals with an exact-match boost and deterministic tie-breaking by `sortOrder` and ID.
11. Reject the query if neither retrieval mode reaches its calibrated threshold.
12. Return the canonical approved answer directly for an exact example-question match unless multiple entries must be synthesized.
13. Otherwise select at most four entries from the current published KV document and send only those entries to Claude.
14. Return approved source titles and HTTPS links from those selected entries.

### Suggested scoring

- Exact example-question match: highest weight
- Phrase match: high weight
- Keyword match: medium-high weight
- Title or category match: medium weight
- Answer-body token match: low weight
- High Vectorize similarity score: strong semantic signal

### Embedding and indexing workflow

An embedding model converts text into a numeric representation of meaning. It is not the answer-writing model. We use Cloudflare Workers AI to create embeddings and Anthropic Claude only to generate the final grounded response.

When an administrator publishes content:

1. Authenticate and authorize the admin; validate `If-Match` and the publish idempotency key.
2. Validate the complete draft, its field limits, and the 512 KiB document bound.
3. Save the current published document as an immutable KV snapshot.
4. Create a new ULID `contentVersion` and versioned embedding manifest.
5. Build the canonical embedding input for every enabled entry and batch-generate CLS-pooled embeddings.
6. Upsert vectors into the namespace equal to the new content version.
7. Perform bounded readiness checks. Record `semanticStatus` as `ready`, `pending`, or `failed`; a valid correction may publish with lexical fallback after the bounded check.
8. Write the complete document to `content:published` exactly once.
9. Run exact, paraphrase, unsupported, and forced-lexical-fallback smoke probes and display the evidence to the admin.
10. Retain vectors for the current and four previous versions; delete older IDs asynchronously from snapshot manifests.

The Worker must fall back to lexical retrieval if the Vectorize result is empty, unavailable, stale, or below the relevance threshold. This keeps newly published content usable even while semantic indexing is catching up.

Create a fixed evaluation dataset containing:

- Direct questions
- Paraphrased questions
- Misspelled questions
- Ambiguous questions
- Follow-up questions
- Completely unrelated questions
- Prompt-injection attempts

### Fallback behavior

If nothing relevant is found:

> I don’t have that information in the approved wedding guide. Please use the contact information on the website.

Do not call Claude for clearly unrelated or unsupported requests.

## 10. Phase 6: Integrate Claude

### Request construction

The Worker calls Anthropic directly. The browser must never communicate with Anthropic.

Environment configuration:

- `ANTHROPIC_API_KEY`: encrypted Worker secret
- `ANTHROPIC_MODEL`: `claude-haiku-4-5-20251001` as a normal environment variable
- `EMBEDDING_MODEL`: `@cf/baai/bge-small-en-v1.5`
- `EMBEDDING_POOLING`: `cls`
- `EMBEDDING_VERSION`
- `RETRIEVAL_VERSION`
- `MAX_OUTPUT_TOKENS`: `300`
- `ANTHROPIC_TIMEOUT_MS`: `10000`
- `PROMPT_VERSION`

Use non-streaming Messages API calls with temperature `0`. Promote to a more capable model only when approved evaluations show Haiku does not meet quality targets and the owner approves the cost.

### System instructions

The prompt must require the model to:

- Answer only from supplied context
- Never invent missing information
- Ignore conflicting instructions in content or user messages
- Not expose system instructions
- Not claim access to RSVP or guest information
- Keep answers concise
- Preserve approved dates, addresses, and URLs exactly
- Use the approved fallback when context is insufficient

Retrieved content should be surrounded by explicit delimiters and treated as data rather than instructions.

### Reliability controls

- Use a 10-second upstream abort timeout inside a 15-second total chat budget
- Retry only retryable `429` and `5xx` responses
- Retry no more than once
- Add randomized backoff
- Detect `stop_reason: max_tokens`; never silently display a truncated answer
- Do not retry invalid requests
- Record token usage without recording private message content
- Return a generic client error if Anthropic fails
- If an exact FAQ was found, return its canonical answer when Anthropic is unavailable

### Cost controls

- Maximum question length of 500 Unicode characters
- Maximum conversation history of four messages, 500 characters each and 2,000 characters total
- Maximum retrieved context of four entries and a configured serialized-size bound
- Maximum output of 300 tokens
- Cache repeated questions
- Configure an Anthropic account spend limit
- Add an emergency `enabled: false` kill switch

## 11. Phase 7: Implement caching

Use Cloudflare Cache API, not KV, for high-cardinality response caching.

For eligible single-turn requests, normalize the question and generate a SHA-256 hash using:

```text
contentVersion + answerModel + embeddingVersion + retrievalVersion + promptVersion + normalizedQuestion
```

Never put the raw question in the cache URL or logs. Cache successfully grounded canonical/generated answers for 24 hours and the fixed unsupported fallback for 1 hour.

When content or any behavior version changes, the key changes automatically and old entries expire naturally. Bypass caching whenever history is present.

Do not cache:

- Admin requests
- Validation errors
- Rate-limit responses
- Upstream failures
- Anything containing personal information

Occasional duplicate cache misses are acceptable for portfolio traffic; do not add a locking service solely for cache stampede prevention.

## 12. Phase 8: Security and abuse controls

### CORS

Production allowlist:

- `https://vandanawedsajay.uk`
- `https://www.vandanawedsajay.uk` only if that hostname is used
- The public demo origin

Localhost origins belong only in local or staging configuration.

For `/api/v1/chat`:

- Validate `Origin`
- Reply correctly to `OPTIONS`
- Return the exact approved origin, never `*`
- Add `Vary: Origin`
- Restrict methods and headers

Admin endpoints must reject cross-origin browser requests and validate `Origin` on every state-changing request.

### Request security

- Accept only `application/json`
- Enforce a 16 KiB chat-body limit and 512 KiB content/import limit before JSON parsing
- Validate every field with Zod
- Reject unknown fields
- Limit question and history lengths
- Escape all content rendered in the browser
- Never render model output with unsanitized `innerHTML`
- Do not permit model-generated scripts or HTML
- Accept only administrator-approved HTTPS content links, enforce URL length/host policy, and render them with safe `rel` attributes
- Apply CSP, `X-Content-Type-Options: nosniff`, a restrictive `Referrer-Policy`, `Permissions-Policy`, and appropriate frame restrictions without preventing cross-site loading of the widget asset
- Generate a request ID for every request

### Admin authentication

Create a Cloudflare Access self-hosted application covering:

```text
assistant.vandanawedsajay.uk/admin*
```

Allow only explicitly approved identities. The Worker must verify `Cf-Access-Jwt-Assertion` using cached Cloudflare Access JWKS and validate signature, issuer, application audience, expiry, and subject before any admin read or mutation. It then applies an application-level allowlist. Direct or alternate Worker routes without a valid assertion fail closed.

Do not reuse the wedding platform’s current browser-entered `X-Admin-Secret` pattern for the new admin application.

### Bot and rate protection

Use:

- Cloudflare managed/invisible Turnstile in the widget with a fresh token for every send
- Server-side Siteverify validation of token, hostname, and action; treat each token as five-minute/single-use and reset after every attempt
- A Workers Rate Limiting binding set initially to 10 chat requests per minute per transient IP key per Cloudflare location
- The zone's Free-plan WAF rate-limiting rule set initially to 5 requests per 10 seconds on `/api/v1/chat`
- Anthropic and Cloudflare usage alerts, strict model/context/output bounds, and the runtime kill switch
- A global emergency disable switch

Workers KV should not be treated as an authoritative strict rate limiter because of eventual consistency.

### Privacy

- Do not persist conversations by default
- State that questions are sent to an AI provider
- Do not log raw questions, answers, history, Turnstile tokens, JWTs, emails, IPs, API keys, or full content documents
- Redact authorization and secret headers
- Target no more than 7 days of application logs where configurable and document actual provider retention
- Add a small privacy notice in the widget
- Keep RSVP data completely separate

## 13. Phase 9: Build the admin application

### Content-management functions

- Content list
- Search
- Category filter
- Add entry
- Edit entry
- Enable or disable entry
- Delete with confirmation
- Example-question editor
- Keyword editor
- Link editor
- Validation messages
- Unsaved-changes warning
- Preview answer
- Save draft
- Publish
- Roll back
- JSON import and export

### Publishing workflow

1. Administrator edits and explicitly saves the draft with ETag/`If-Match`; no autosave writes KV.
2. Browser validates fields and shows dirty/navigation state.
3. Worker validates the complete schema, bounds, actor, and draft revision.
4. Preview uses draft lexical retrieval plus batched in-memory embeddings; it never writes draft vectors to the published index.
5. Before Publish, the UI shows a diff summary, validation result, content count, and confirmation.
6. The browser creates an idempotency key and submits the current draft revision.
7. The Worker follows the approved snapshot, ULID, batch-embedding, namespace-upsert, readiness, and single-write publication sequence.
8. UI reports the new version, response evidence, and semantic status.
9. Exact, paraphrase, unsupported, and lexical-fallback smoke queries confirm usability.
10. Export the published content to the owner-controlled backup location.

### Rollback

1. List the newest 20 snapshots while retaining all V1 snapshots.
2. Show version, timestamp, actor reference, content summary, and restored-from relationship.
3. Require confirmation and a fresh idempotency key.
4. Revalidate the selected snapshot and republish it under a new ULID version and new Vectorize namespace.
5. Record `reason: rollback` and `restoredFromVersion`.
6. Never overwrite or destroy snapshot history.

KV is sufficient for low-volume snapshots. If a formal audit trail is later required, move audit and history records to D1.

## 14. Phase 10: Build the portable widget

Use the dependency-light TypeScript custom element with Shadow DOM so it can be embedded in React, WordPress, or a plain HTML page without a React runtime.

Example integration:

```html
<script
  type="module"
  src="https://assistant.vandanawedsajay.uk/widget/v1/widget.js">
</script>

<wedding-ai-assistant
  api-url="https://assistant.vandanawedsajay.uk"
  title="Ask our wedding assistant">
</wedding-ai-assistant>
```

### Widget functionality

- Floating launcher button
- Open and close panel
- Welcome message
- Suggested questions
- User and assistant message bubbles
- Loading indicator
- Retry button
- Clear conversation
- Source-title display
- Disabled or unavailable state
- Privacy message
- Mobile full-screen mode
- Desktop floating panel
- Escape-key close
- Focus management
- Screen-reader labels
- Reduced-motion support

Use Shadow DOM plus documented CSS custom properties so the widget cannot interfere with the host website’s styling while still supporting intentional theming.

Version the asset path as `/widget/v1/widget.js`. Future changes can ship as `/widget/v2/widget.js` without unexpectedly breaking an existing installation.

## 15. Phase 11: Integrate with the wedding website

The existing application has a shared `frontend/src/components/Layout.jsx`, so the widget can appear across the application.

### Wedding repository changes

1. Create a feature branch.
2. Add `WeddingAssistant.jsx`.
3. Load the versioned widget script once.
4. Render the custom element inside `Layout.jsx`, outside `<Outlet />`.
5. Add build variables:

```text
VITE_ASSISTANT_ENABLED=true
VITE_ASSISTANT_API_URL=https://assistant.vandanawedsajay.uk
```

6. Hide the widget when the feature flag is false.
7. Do not change the existing Java `/api` proxy.
8. Run the Vite build.
9. Rebuild the frontend Docker image.
10. Deploy the updated site.
11. Test every existing route.

Calling the Worker directly through its assistant subdomain avoids conflicts with the Dropwizard `/api` routes and demonstrates domain-restricted CORS.

The repository README should also be corrected: it says React 18, while `frontend/package.json` specifies React 19.2.0.

## 16. Phase 12: Testing strategy

### Unit tests

Test:

- CORS allowlist
- Preflight responses
- JSON validation
- Body and question limits
- Content-schema validation
- Retrieval normalization
- Lexical retrieval scoring
- Embedding-input construction
- Vector-match to FAQ-ID mapping
- Hybrid ranking and tie-breaking
- Minimum relevance threshold
- Prompt construction
- Cache-key generation
- Fallback behavior
- Anthropic error mapping
- Admin access validation
- Snapshot creation
- Content-version changes

### Integration tests

Using a local Worker and KV environment:

- Seed content
- Fetch content from KV
- Mock Workers AI embedding generation
- Mock Vectorize upsert and query operations
- Confirm Vectorize queries use the namespace equal to the current published `contentVersion`
- Confirm lexical fallback works when Vectorize has no match or is unavailable
- Mock Anthropic success
- Mock timeout
- Mock malformed AI response
- Mock `429`
- Mock `500`
- Verify retry behavior
- Verify cache hit and miss
- Verify publishing
- Verify rollback
- Confirm unauthorized admin access fails
- Confirm forbidden origins fail

### AI evaluation tests

Create at least 50 sanitized evaluation prompts:

- 15 direct supported questions
- 15 paraphrases
- 5 misspellings
- 5 ambiguous or follow-up questions
- 5 unsupported questions
- 5 adversarial or prompt-injection questions

Record:

- Expected content source
- Whether the assistant should answer or refuse
- Required facts
- Forbidden claims

Evaluate retrieval separately from response wording. Before production require at least 95% correct source in the top three for supported cases, at least 95% correct rejection for unsupported cases, 100% preservation of committed critical dates/times/addresses/URLs, and 100% safe handling of committed injection cases.

### End-to-end browser tests

Test:

- Playwright Chromium desktop
- Playwright WebKit desktop
- Chrome Android-sized viewport
- Safari iPhone-sized viewport
- Keyboard-only usage
- Screen-reader labels
- Slow network
- Anthropic failure
- Assistant disabled
- Long text
- Multiple open and close cycles
- Route navigation while chat is open
- No interference with RSVP or admin pages

Before launch, also perform focused manual checks in real Chrome and Safari; viewport emulation is not evidence of physical-device testing.

### Performance checks

- Widget script size
- Initial page-loading impact
- Worker response time
- Cached versus uncached latency
- Lighthouse mobile score
- Layout shift
- No unnecessary Anthropic calls

Production AI load testing should use only a few controlled requests. Higher-volume tests should mock Anthropic to avoid unnecessary cost.

## 17. Phase 13: Cloudflare deployment

### Create resources

For staging and production:

1. Authenticate Wrangler.
2. Create a KV namespace.
3. Create a Vectorize index with 384 dimensions and cosine similarity.
4. Record the generated namespace and index identifiers.
5. Add the KV, Vectorize, and Workers AI bindings to the appropriate Wrangler environment.
6. Configure ordinary environment variables.
7. Install the Anthropic API key as a Worker secret.
8. Configure Turnstile secrets.
9. Seed staging content and build its vectors.
10. Deploy the staging Worker.
11. Run staging smoke tests for exact, semantic, unsupported, and Vectorize-fallback queries.
12. Seed production content and build its vectors.
13. Deploy production.
14. Attach `assistant.vandanawedsajay.uk`.
15. Confirm DNS and SSL.
16. Configure Cloudflare Access for `/admin*`.
17. Configure rate-limiting rules.
18. Verify production CORS.

### Wrangler configuration

The configuration should include:

- Worker name
- Compatibility date
- Main TypeScript entry point
- Static asset directory
- KV bindings
- Vectorize binding
- Workers AI binding
- Staging and production variables
- Observability configuration
- Custom domain configuration where appropriate

Only KV identifiers and non-secret settings belong in this file.

### Seeding

The seed script should:

- Accept an environment argument
- Validate the JSON schema
- Refuse invalid content
- Display the target account and environment
- Require confirmation for production
- Write the draft
- Generate and upsert embeddings for enabled entries
- Publish the initial version
- Print the resulting version
- Never contain credentials

## 18. Phase 14: CI/CD

### Pull-request CI

For every pull request:

- Install locked dependencies
- Lint
- Check formatting
- Type-check
- Run unit tests
- Run integration tests
- Run contract tests
- Run the committed retrieval evaluation suite and enforce its release thresholds
- Build the Worker
- Build the widget
- Build the admin application
- Validate sample content
- Report `npm audit --omit=dev` findings without performing automatic production upgrades
- Run the selected Playwright Chromium/WebKit desktop and mobile checks

Enable Dependabot alerts and reviewed update PRs after package bootstrap.

### Deployment workflow

Required policy:

- Merges to `main` deploy automatically to staging after required CI passes
- Production deployment uses a manually approved GitHub Environment or workflow dispatch
- Production content publishing remains an admin operation
- GitHub Actions deploys code, not knowledge-base content
- Every production release records the commit SHA, Worker deployment ID, compatibility date, smoke results, and rollback target

GitHub secrets:

- Cloudflare API token
- Cloudflare account ID

The Anthropic key can be installed directly as a Worker secret during environment bootstrap and does not need to be present in GitHub Actions.

Add branch protection so CI must pass before merging.

## 19. Phase 15: Production launch checklist

Before enabling the widget:

- Worker health check passes
- Production content is published
- Production vectors are present for the current content version
- All production content is reviewed
- No private data is present
- Anthropic key works
- Spend limit is enabled
- CORS blocks an unapproved test origin
- CORS accepts the wedding domain
- Turnstile works
- Rate limiting works
- Admin page requires Cloudflare Access
- Unauthorized admin requests fail
- Widget works on mobile
- Widget works with keyboard navigation
- Error states are understandable
- Existing RSVP flow still works
- Existing admin flow still works
- Website performance remains acceptable
- Rollback procedure has been tested

Launch order:

1. Deploy the website change with the widget feature disabled.
2. Verify the page and widget assets.
3. Enable the Worker.
4. Enable the frontend feature flag.
5. Rebuild and deploy the wedding frontend.
6. Run production smoke tests.
7. Monitor errors and Anthropic usage closely for the first day.

## 20. Phase 16: Observability and operations

Enable Workers structured logs and traces. Record all errors, admin mutations, publish/rollback events, and a 10% sample of successful public requests. Record structured fields such as:

- Timestamp
- Request ID
- Route
- Status
- Latency
- Cache hit or miss
- Retrieved content IDs
- Anthropic model
- Input and output token counts
- Upstream status
- Error category

Do not log:

- API keys
- Access tokens
- Complete authorization headers
- Full admin content
- Raw questions, answers, or chat history
- Private guest information

### Monitoring

Set up checks for:

- Health endpoint availability
- Elevated `5xx` rate
- Anthropic failures
- Rate-limit volume
- Unexpected token usage
- KV errors
- Admin publish failures
- Widget asset availability

### Emergency controls

Prepare three shutdown mechanisms:

- Set `config:runtime.enabled` to false
- Disable the widget through the frontend feature flag
- Roll back the Worker deployment

The disabled state should return a friendly message without calling Anthropic.

## 21. Phase 17: Rollback and recovery

### Worker rollback

- Retain prior Worker versions
- Record deployment IDs
- Test the Wrangler or dashboard rollback procedure
- Do not combine a risky Worker release and major content publish in the same operation

### Content rollback

- Keep recent published snapshots
- Roll back by publishing a snapshot as a new version
- Do not mutate historical snapshots
- Export production content periodically

### Website rollback

- Keep the prior frontend Docker image
- Keep the assistant behind a feature flag
- Disable or remove only the widget if necessary, without changing the Java backend

## 22. Phase 18: Documentation

### README

The public README should contain:

- Project purpose
- Live demo
- Screenshot
- Architecture diagram
- Feature list
- Technology stack
- Local setup
- Wrangler setup
- KV creation and seeding
- Secret installation
- Deployment
- CORS configuration
- Widget embedding
- Admin workflow
- Testing commands
- Security decisions
- Cost considerations
- Known limitations
- Future roadmap

### Additional documents

- `product-requirements.md`: PRD, scope, personas, and user journeys
- `architecture.md`: HLD, system boundaries, and request/publishing diagrams
- `detailed-design.md`: component behavior, failure handling, and concurrency design
- `api-contract.md`: versioned public and admin contracts
- `data-model.md`: KV schemas, revisions, snapshots, and Vectorize records
- `retrieval-design.md`: lexical, semantic, fusion, calibration, and grounding rules
- `evaluation-strategy.md`: dataset composition, metrics, and release thresholds
- `cost-model.md`: quotas, alerts, model economics, and shutdown thresholds
- `deployment.md` and `runbooks/`: staging, production, rollback, migration, rotation, outage, CORS, and unexpected-spend procedures
- `administration.md`: editing, previewing, publishing, importing, exporting, and rollback instructions
- `security.md`: threat model, trust boundaries, privacy, and abuse controls
- `adr/`: individual architecture decision records with status, alternatives, consequences, and supersession links
- `troubleshooting.md`: common Wrangler, CORS, KV, Vectorize, Workers AI, and Anthropic problems

## 23. Phase 19: Portfolio packaging

### Public presentation

Create:

- Live standalone demo
- Embedded wedding-site version
- Public GitHub repository
- Desktop screenshot
- Mobile screenshot
- Admin screenshot
- Architecture diagram
- Short screen recording
- Sanitized sample dataset

### Suggested portfolio title

**Cloudflare AI Event Concierge with Workers KV and Claude**

### Portfolio description

> Built and deployed a custom RAG knowledge assistant using Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, and the Anthropic API. The application performs hybrid semantic and keyword retrieval over approved event content, generates grounded answers, enforces domain-restricted CORS and abuse controls, and includes a Cloudflare Access-protected admin interface for publishing and rolling back knowledge-base updates. Delivered as a reusable JavaScript widget and integrated into an existing React wedding platform.

### Skills to highlight

- Cloudflare Workers
- Workers KV
- Cloudflare Vectorize
- Workers AI embeddings
- Wrangler
- TypeScript
- Anthropic API
- Serverless architecture
- CORS
- Cloudflare Access
- Turnstile
- API security
- React
- CI/CD
- Production deployment

### Evidence for Upwork proposals

> I recently deployed a custom RAG assistant using Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, and Claude. I configured Wrangler environments, semantic indexing at publish time, Worker secrets, domain-restricted CORS, Cloudflare Access for administration, a portable website widget, and end-to-end production testing.

## 24. Definition of done

The project is complete only when all of these are true:

- The Worker is reproducibly deployable with Wrangler.
- Staging and production have separate KV namespaces.
- Staging and production have separate Vectorize indexes with dimensions matching the embedding model.
- The Anthropic key exists only as a secret.
- Visitors can ask questions from the wedding website.
- Answers come only from published KV content.
- Semantic Vectorize queries use the namespace equal to the current published `contentVersion`.
- Lexical fallback works if Vectorize is unavailable or has not indexed a new version yet.
- Unsupported questions produce a safe fallback.
- Answers include source titles.
- Repeated questions use the cache.
- The admin can edit, preview, publish, and roll back content.
- Admin routes are protected by Cloudflare Access.
- Unapproved origins cannot use the chat API.
- Turnstile and rate limiting reduce abuse.
- No conversations or guest data are persisted by default.
- Desktop, mobile, keyboard, and error states work.
- CI passes.
- Production monitoring and rollback are documented.
- The public repository contains no private information.
- The demo, screenshots, README, and Upwork portfolio entry are ready.

## 25. Estimated implementation effort

| Workstream | Estimate |
|---|---:|
| Project setup and architecture | 2–3 hours |
| Worker, KV, and API contracts | 5–7 hours |
| Hybrid retrieval, embeddings, Vectorize, and Anthropic integration | 8–12 hours |
| Admin application | 6–8 hours |
| Portable widget and demo | 5–7 hours |
| Wedding-site integration | 2–3 hours |
| Security and abuse controls | 3–5 hours |
| Automated tests and AI evaluations | 5–7 hours |
| Deployment, monitoring, and rollback | 3–5 hours |
| Documentation and portfolio assets | 3–5 hours |
| **Total portfolio-quality implementation** | **42–62 hours** |

A stripped-down technical MVP could be completed in approximately 20–28 hours, but the full plan above produces a credible project that can be confidently shown to clients and discussed in interviews. These are early planning ranges only; Symphony must re-estimate from the approved detailed design and Linear task graph before implementation dispatch.

## 26. Required owner-supplied deployment inputs

The following values must be supplied or confirmed during human-controlled setup. Symphony must not guess them or store secrets in this public repository:

- Cloudflare account and zone IDs
- Cloudflare Access team domain and application audience
- Exact approved admin identities
- Actual canonical `www` behavior for the wedding domain
- KV namespace and Vectorize index IDs created for each environment
- Turnstile sitekeys and secrets for staging and production
- Anthropic project keys and final account spending controls
- Least-privilege GitHub and Cloudflare credential identifiers
- Wedding repository location and deployment access
- External monitoring destination and notification channel

## 27. Planning references and revalidation requirement

The approved decisions were fact-checked against the following primary provider documentation during planning:

- [Cloudflare Vectorize pricing](https://developers.cloudflare.com/vectorize/platform/pricing/)
- [Cloudflare BGE small model, dimensions, limits, and pooling](https://developers.cloudflare.com/workers-ai/models/bge-small-en-v1.5/)
- [Cloudflare Vectorize namespaces and metadata filtering](https://developers.cloudflare.com/vectorize/reference/metadata-filtering/)
- [Cloudflare KV consistency](https://developers.cloudflare.com/kv/concepts/how-kv-works/)
- [Cloudflare KV limits](https://developers.cloudflare.com/kv/platform/limits/)
- [Cloudflare Workers pricing and limits](https://developers.cloudflare.com/workers/platform/pricing/)
- [Cloudflare Turnstile server-side validation](https://developers.cloudflare.com/turnstile/get-started/server-side-validation/)
- [Cloudflare Access JWT validation](https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/validating-json/)
- [Cloudflare Workers Rate Limiting binding](https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/)
- [Cloudflare WAF rate-limiting rules](https://developers.cloudflare.com/waf/rate-limiting-rules/)
- [Cloudflare Worker static SPA assets](https://developers.cloudflare.com/workers/static-assets/routing/single-page-application/)
- [Anthropic model selection](https://platform.claude.com/docs/en/about-claude/models/choosing-a-model)
- [Anthropic model IDs and versioning](https://platform.claude.com/docs/en/about-claude/models/model-ids-and-versions)

Pricing, quotas, feature availability, and model catalogs are time-sensitive. Recheck these sources immediately before implementation and production launch, then quarterly as required by Q-06.

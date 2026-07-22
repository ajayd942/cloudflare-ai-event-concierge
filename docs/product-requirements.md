# Product Requirements: Cloudflare AI Event Concierge

Status: Proposed for owner approval under [AJA-5](https://linear.app/ajayd94/issue/AJA-5/seed-14-define-product-requirements-and-user-journeys)

## Document control

| Field | Value |
|---|---|
| Product | Cloudflare AI Event Concierge |
| Version | 0.1 proposal |
| Audience | Repository owner, prospective freelance clients, technical reviewers, public demo visitors, and future implementers |
| Authority | Review material until the owner approves and merges this document |
| Approved input | [Master Implementation Plan](planning/INITIAL_IMPLEMENTATION_PLAN.md) |
| Related context | [Project Charter](PROJECT_CHARTER.md) (draft) |

This document translates the owner-approved planning baseline into a reviewable
product contract. It does not supersede that baseline while this document is
proposed. After explicit owner approval, this PRD becomes the product source of
truth where it is more specific; any future supersession must be intentional,
reviewed, and recorded. No product decision in this proposal intentionally
supersedes the approved baseline.

## Product summary

Cloudflare AI Event Concierge is a reusable, public retrieval-augmented
generation (RAG) application demonstrated with fictional or sanitized wedding
content. It lets a visitor ask an English-language event question, retrieves
relevant administrator-approved content, and either returns a grounded answer
with approved sources or a fixed unsupported-question response. A protected
admin experience supports explicit draft, preview, publish, snapshot, rollback,
import, export, and runtime-disable operations.

The same immutable, versioned widget is intended to run in a standalone public
demo and, behind a disabled-by-default feature flag, in the existing React/Vite
wedding site. The concierge remains separate from the wedding site's Java API,
RSVP flow, private guest data, and existing admin authentication.

### Portfolio outcome

The completed project must give prospective freelance clients and technical
reviewers verifiable evidence of Cloudflare Workers, Workers KV, Vectorize,
Workers AI embeddings, Anthropic Claude, hybrid retrieval, secure content
administration, portable embedding, automated testing, accessibility,
observability, and human-controlled operations. Evidence must be public,
sanitized, and honest: the project is a demonstration, not a live guest service,
and claims must describe measured results and actually deployed services only.

### Product principles

1. **Approved content is the boundary.** The assistant answers only after a
   relevant approved source is retrieved; it does not use Claude as an
   ungrounded knowledge source.
2. **Unsupported is a valid outcome.** No relevant source means a fixed safe
   fallback and no Claude call.
3. **Public means sanitized.** Public code, content, environments, screenshots,
   recordings, and model context contain only fictional or sanitized event data.
4. **Editorial changes are deliberate.** Draft changes, publishing, rollback,
   and runtime controls are explicit, protected operations with confirmation.
5. **Degradation is visible and safe.** Lexical retrieval remains available
   when semantic retrieval is unavailable, and the service makes no contractual
   availability claim.
6. **Evidence precedes claims.** Quality, performance, accessibility, safety,
   and cost values in this PRD are release targets until validation records show
   they were met.

## Audiences and personas

Audience priority describes who the portfolio is optimized for. Personas also
include people who operate or try the product; those operational roles do not
change the approved audience priority.

### Primary audiences

| Persona | Need | Product evidence that serves the need |
|---|---|---|
| Prospective freelance client | Confidence that the owner can deliver a secure, maintainable event assistant rather than a prototype with unsupported claims | Live sanitized demo, portable embed, protected content workflow, clear limitations, cost controls, operations documentation, and measured results |
| Technical reviewer | Inspectable reasoning and evidence from requirements through implementation | Traceable requirements and decisions, architecture and assurance documents, typed contracts, automated checks, retrieval evaluations, CI evidence, and rollback procedures |

### Secondary audience

| Persona | Need | Product response |
|---|---|---|
| Public demo visitor | A clear, accessible way to ask ordinary event questions without being misled about the demonstration or its data handling | English-only widget, persistent demonstration and privacy notices, concise grounded answers with approved sources, safe unsupported and unavailable states, and no conversation persistence |

### Operational personas

| Persona | Need | Product response |
|---|---|---|
| Nontechnical content administrator | Safely maintain public event information without using a terminal | Access-protected forms, explicit save, validation, preview evidence, publish confirmation, snapshots, rollback-as-new-version, import/export, and a runtime enable/disable control |
| Repository owner and production operator | Retain authority over scope, designs, secrets, production settings, releases, rollback, and cost | Human approval gates, least-privilege credentials, separate environments, budget alerts, documented runbooks, and independent kill switches |

## User needs and product requirements

The requirement IDs below provide stable traceability for later design,
implementation, and review evidence.

### Public experience

| ID | Requirement | Acceptance signal | Approved decisions |
|---|---|---|---|
| PR-PUB-01 | A visitor can open the same versioned custom-element widget on the standalone demo and, when enabled, the wedding site. | One artifact is demonstrated on both surfaces without a second chat implementation. | P-01, P-06, W-01, R-07, R-08 |
| PR-PUB-02 | The widget accepts English-language questions and bounded in-memory follow-up context only. | Non-English support is not advertised; history clears on reload or explicit clear and is not persisted. | P-09, W-03, H-11, A-06 |
| PR-PUB-03 | A supported exact question returns the approved canonical answer when synthesis is unnecessary. | Exact prepared FAQ cases do not require Claude and preserve the approved answer. | H-06, H-07, Q-04 |
| PR-PUB-04 | A supported paraphrase returns a concise answer only from relevant approved context, with approved source titles and links. | Retrieval passes an evaluated relevance gate before Claude is called; returned links originate only from approved content. | H-04, H-05, H-07, API-07, API-08, S-13 |
| PR-PUB-05 | A question with no relevant approved source returns the fixed approved fallback without calling Claude. | Unsupported evaluation cases reject safely, have no fabricated answer, and use response mode `fallback`. | H-08, T-03, Q-04 |
| PR-PUB-06 | The visitor can recognize temporary provider failure, disabled mode, rate limiting, and Turnstile failure and can recover where retry is appropriate. | Each state has generic, actionable copy and never exposes internals or fabricates content. | A-09, API-09, W-04, M-10, T-10 |
| PR-PUB-07 | The widget, standalone demo, and README persistently display: “Demonstration project — information is fictional or sanitized.” | The notice remains visible or persistently available on every public demonstration surface. | P-04, P-05 |
| PR-PUB-08 | The widget explains that questions are sent to an AI provider, should not contain personal information, and are not stored by the application by default. | The privacy notice is available at the point of use and matches actual behavior. | S-15, S-16, W-03 |

### Retrieval and answer behavior

| ID | Requirement | Acceptance signal | Approved decisions |
|---|---|---|---|
| PR-RAG-01 | Published content in Workers KV is the readable source of truth; Vectorize is only a rebuildable retrieval index. | Public answers and returned source details resolve to the current published KV document, not vector metadata. | C-01, V-07 |
| PR-RAG-02 | Retrieval combines deterministic lexical scoring and semantic search over the current content version. | Exact facts and paraphrases are evaluated separately; a Vectorize failure retains lexical behavior. | H-01, H-03, H-04, H-09 |
| PR-RAG-03 | Relevance thresholds are calibrated from the committed evaluation set and fail closed until recorded. | No permanent lexical or cosine threshold is accepted without evaluation evidence. | H-05, H-12 |
| PR-RAG-04 | At most four current-version approved entries are provided to the answer stage. | Diagnostics show bounded selected IDs and current version identifiers without storing question text. | V-10, A-07, H-10 |
| PR-RAG-05 | User text and retrieved content are untrusted data and cannot override system policy. | Injection cases do not disclose system instructions, add unsupported claims, or trigger unapproved actions. | H-13, T-05 |
| PR-RAG-06 | Response caching applies only to eligible single-turn grounded answers and the fixed unsupported fallback. | History, admin responses, validation failures, rate limits, auth failures, and upstream failures bypass caching; raw questions do not appear in keys. | K-01 through K-05 |

### Administration and publishing

| ID | Requirement | Acceptance signal | Approved decisions |
|---|---|---|---|
| PR-ADM-01 | Only an authenticated and application-allowlisted administrator can read or mutate admin state. | Cloudflare Access and Worker-side JWT validation both fail closed; state-changing requests also enforce same-origin policy. | S-02 through S-05, U-01 |
| PR-ADM-02 | An administrator can add, edit, enable, disable, and delete draft entries; edit presentation content; preview changes; and explicitly save a validated draft. | The UI shows dirty state, field errors, navigation warning, and concurrency conflict rather than silently overwriting another edit. Every admin error uses plain-language copy with a recovery action and does not expose protocol details such as ETags or revision numbers. | C-07, M-02 through M-05 |
| PR-ADM-03 | Preview uses draft content without making it public or polluting the published Vectorize index. | Preview shows sources, retrieval mode/scores, answer, and warnings while production index state is unchanged. | U-10, M-05 |
| PR-ADM-04 | Publish requires a review summary, validation, content count, explicit confirmation, current draft revision, and an idempotency key. | A successful publish creates one new content version; a failure before the permitted readiness decision leaves current public content unchanged. | U-01 through U-07, M-06 |
| PR-ADM-05 | A published correction is available immediately through lexical retrieval even when semantic indexing is pending or failed. | Admin status displays `pending`, `ready`, or `failed`; public behavior falls back to lexical retrieval. | U-04, M-07, H-09 |
| PR-ADM-06 | A rollback republishes a selected immutable snapshot as a new version after confirmation; it never rewrites history. | The new version records its source snapshot, and older snapshots remain unchanged. | C-04, U-08, M-08 |
| PR-ADM-07 | Import targets the draft only after validation, preview, and confirmation; export explicitly identifies draft or published content. | Import cannot publish directly or ambiguously replace production content. | U-09, M-09 |
| PR-ADM-08 | An administrator can disable the public assistant without a terminal. | A protected, confirmed control changes the runtime enabled state independently of content. | C-13, M-10, O-06 |

### Wedding-site integration

| ID | Requirement | Acceptance signal | Approved decisions |
|---|---|---|---|
| PR-INT-01 | The wedding site loads the immutable versioned widget once and mounts it from the shared layout outside the router outlet. | The widget survives route navigation without duplicate instances. | P-06, W-01, W-08 |
| PR-INT-02 | The production wedding-site feature flag defaults to disabled and is enabled only after human-approved deployment and smoke checks. | With the flag off, no launcher is mounted; enabling follows the documented release gate. | W-09, G-02 |
| PR-INT-03 | The integration calls the assistant origin directly and does not change Java routes, RSVP behavior, Nginx `/api` proxying, or existing admin authentication. | Regression evidence covers existing routes and workflows; no private platform integration exists. | P-06, P-07, W-10, S-17 |

### Portfolio and evidence

| ID | Requirement | Acceptance signal | Approved decisions |
|---|---|---|---|
| PR-EVD-01 | Public documentation traces product intent, design, implementation, tests, operations, and limitations. | Required documents are linked and decision supersession is explicit. | F-01, F-02, G-14 |
| PR-EVD-02 | Portfolio claims are backed by a live demo, embedded example, diagrams, screenshots, recording, CI status, evaluation summary, and sanitized dataset when those artifacts exist. | Evidence is current, public-safe, and distinguishes measured results from targets. | F-03, F-04 |
| PR-EVD-03 | Portfolio language describes a custom hybrid-RAG deployment without presenting it as paid client work or a live wedding service. | README and portfolio copy use the approved framing and persistent disclosure. | F-05, P-05 |
| PR-EVD-04 | Known product and platform limitations are documented next to claims. | English-only behavior, small corpus, eventual consistency, approximate/local rate limits, non-streaming, no persistence, and no private-data integration are visible. | F-06 |

## Version 1 scope

This scope restates the approved baseline without expansion.

### Included

- TypeScript Cloudflare Worker.
- Workers KV content storage for draft, published content, immutable snapshots,
  and runtime configuration.
- Cloudflare Vectorize semantic-search index.
- Cloudflare Workers AI embedding generation.
- Anthropic Messages API integration.
- Hybrid FAQ retrieval using deterministic lexical scoring and semantic vector
  search.
- Grounded answers with approved source titles, including direct canonical
  answers for exact prepared questions.
- Portable dependency-light TypeScript custom-element widget with Shadow DOM.
- Public standalone demo using the same versioned widget artifact.
- Cloudflare Access-protected admin content editor.
- Draft, preview, publish, snapshot, rollback, import, export, and runtime-disable
  workflows.
- Exact CORS allowlists, runtime input validation, Turnstile, rate limiting,
  security headers, privacy controls, and cost controls.
- Cache API response caching for eligible single-turn grounded answers and fixed
  unsupported fallbacks.
- Unit, Worker integration, contract, retrieval evaluation, and selected
  Chromium/WebKit browser tests.
- Separate local, staging, and production environments.
- Versioned assets and a custom assistant subdomain.
- Reviewed CI/CD with human-controlled production release.
- Deployment, operations, rollback, administration, troubleshooting, security,
  cost, and portfolio documentation and evidence.

### Excluded

- User accounts.
- Conversation persistence.
- Personalized RSVP lookup.
- Access to private guest information or integration with RSVP, guest, or
  existing wedding-admin data.
- Voice input or output.
- File or PDF upload and ingestion.
- Multiple customers or tenants.
- A complex analytics dashboard.
- D1 or another authoritative content database.
- WhatsApp integration.

### Delivery non-goals and authority boundaries

- This product-definition issue does not authorize application code,
  infrastructure mutation, secrets, credentials, billing, DNS, deployment, or
  production access.
- Agents do not approve product scope, designs, the implementation task graph,
  production content, secrets, production configuration, deployment, rollback,
  pull requests, or merges.
- Production deployment is not autonomous, and pull-request merge is not fully
  automated.
- The concierge repository remains separate from the wedding repository; only a
  later, explicitly approved widget-integration change belongs in the wedding
  repository.

## User journeys

### Journey 1: public visitor asks a supported question

**Actor:** Public demo visitor

**Preconditions:** The public assistant is enabled; current published content is
available; the visitor is on the standalone demo or an enabled host site.

1. The visitor sees the persistent demonstration and privacy disclosures.
2. They open the widget with pointer, keyboard, or supported assistive
   technology.
3. The widget obtains a fresh Turnstile token and submits an English-language
   question with a client request ID and any bounded in-memory history.
4. The service validates origin, body, token, rate limit, and normalized input.
5. Retrieval evaluates deterministic lexical candidates and current-version
   semantic candidates.
6. For an exact prepared question, the service returns the canonical approved
   answer. Otherwise, Claude is called only when relevant approved context has
   passed the gate.
7. The widget renders concise plain text and administrator-approved source
   titles/HTTPS links, returns focus appropriately, and announces the result.

**Expected result:** The visitor receives a grounded answer with approved source
evidence and no suggestion that private guest data is available.

**Degradation:** If semantic retrieval is unavailable or not ready, lexical
retrieval remains available. If generation fails, an exact canonical answer may
still be returned; otherwise the visitor receives a generic temporary-unavailable
state with no fabricated content.

**Traceability:** PR-PUB-01 through PR-PUB-04, PR-RAG-01 through PR-RAG-05.

### Journey 2: visitor asks an unsupported or adversarial question

**Actor:** Public demo visitor

**Preconditions:** The request passes external-input validation and abuse checks.

1. The visitor asks for information outside the approved guide or attempts to
   override instructions.
2. Lexical and semantic candidates are independently checked against calibrated
   relevance thresholds.
3. No relevant source passes, or the request remains unsupported under policy.
4. The service does not call Claude and returns the fixed approved fallback:
   “I don’t have that information in the approved wedding guide. Please use the
   contact information on the website.”
5. The widget renders the fallback without model-created facts or links.

**Expected result:** The assistant refuses safely, discloses no system prompt or
private data, and performs no unapproved action.

**Traceability:** PR-PUB-05, PR-RAG-03, PR-RAG-05, H-05, H-08, T-03, T-05.

### Journey 3: administrator edits and previews content

**Actor:** Nontechnical content administrator

**Preconditions:** Cloudflare Access and Worker-side identity checks both allow
the administrator; the current draft and its ETag are available.

1. The administrator opens `/admin` and sees the content list, current draft
   state, and runtime status.
2. They add or edit an entry, presentation copy, example questions, keywords, or
   approved HTTPS links; they may enable, disable, or confirm deletion of an
   entry.
3. Browser validation gives field-level feedback. Unsaved changes are visible,
   and navigation triggers a warning.
4. The administrator explicitly saves the draft with `If-Match`; the Worker
   validates the complete document and rejects a stale edit as a visible
   concurrency conflict. The UI explains how to refresh or reconcile the edit in
   plain language without exposing ETags, revision numbers, or other protocol
   jargon.
5. The administrator previews a question against the draft. The preview shows
   selected sources, retrieval mode/scores, answer, and warnings without changing
   published content or the production vector index.

**Expected result:** The draft is safely reviewable and remains non-public until
an explicit publish.

**Traceability:** PR-ADM-01 through PR-ADM-03, C-07, M-02 through M-05, U-10.

### Journey 4: administrator publishes a reviewed draft

**Actor:** Nontechnical content administrator

**Preconditions:** The saved draft is current and valid; publishing authority is
confirmed; all content is fictional, sanitized, and approved for public use.

1. The admin UI shows the diff summary, validation result, content count, current
   revision, and an explicit confirmation.
2. The browser generates an idempotency key and submits the publish request.
3. The service revalidates authority, revision, content, bounds, and idempotency.
4. It snapshots current published content, allocates a new version, generates
   embeddings, upserts versioned vectors, and performs bounded readiness checks.
5. If the approved readiness rule permits, it writes the complete new published
   document once; otherwise the previous publication remains unchanged.
6. The UI displays the new version, semantic status, lexical fallback status,
   and exact/paraphrase/unsupported/forced-lexical smoke evidence.

**Expected result:** The public corpus changes as one reviewed version, remains
immediately usable through lexical retrieval, and exposes indexing degradation to
the admin rather than hiding it.

**Traceability:** PR-ADM-04, PR-ADM-05, U-01 through U-07, U-11, M-06, M-07.

### Journey 5: administrator rolls back published content

**Actor:** Nontechnical content administrator

**Preconditions:** A valid immutable snapshot exists and the administrator has
publish/rollback authority.

1. The administrator reviews snapshot version, timestamp, actor reference,
   summary, and restored-from relationship.
2. They select a snapshot, provide a reason, and explicitly confirm rollback.
3. The service revalidates the snapshot and request, then republishes its content
   with a new version and new vector namespace.
4. The selected snapshot and all prior history remain immutable.
5. The same post-publish status and smoke evidence are shown.

**Expected result:** The selected content is restored as a new auditable version;
history is monotonic rather than rewritten.

**Traceability:** PR-ADM-06, C-04, U-08, M-08.

### Journey 6: owner controls the wedding-site feature flag

**Actor:** Repository owner and production operator

**Preconditions:** The separately reviewed assistant and wedding integration are
deployed; production content and assets passed approved smoke checks.

1. The wedding frontend is first released with the assistant feature flag
   disabled.
2. With the flag off, the site does not mount the custom element; RSVP, Java API,
   Nginx proxying, existing admin behavior, and routes remain unchanged.
3. The owner verifies the assistant origin, versioned widget asset, exact CORS,
   Turnstile, disclosure, mobile/keyboard behavior, and disabled-state rollback.
4. Only after the human release gate, the owner enables the frontend flag and
   deploys the wedding frontend.
5. If a problem occurs, the owner disables the flag independently of Worker or
   content rollback.

**Expected result:** The portfolio demonstrates real host-site integration with
a narrow, reversible blast radius and no coupling to private wedding systems.

**Traceability:** PR-INT-01 through PR-INT-03, P-06, W-08 through W-10, O-06.

## Privacy, data, and trust boundaries

| Boundary | Product rule | Evidence required before launch | Decisions |
|---|---|---|---|
| Public artifacts | GitHub content, staging and production demo content, screenshots, recordings, logs, and model context use only fictional or sanitized event information. | Content review and repository/privacy scan find no private wedding or guest data. | P-04, S-15, S-17 |
| Demonstration identity | Widget, demo, and README persistently state that the project is a demonstration and information is fictional or sanitized. | Disclosure is visible on every public surface and in captured portfolio evidence. | P-05 |
| Visitor input | Questions and bounded history are sent to an AI provider when generation is needed, are not intended for personal data, and are not persisted by the application by default. | Point-of-use notice matches implementation, cache, and log behavior. | S-16, W-03, A-06 |
| Operational telemetry | Raw questions, answers, history, Turnstile tokens, JWTs, emails, IPs, API keys, authorization headers, guest data, and full content documents are not logged. | Structured logging tests and review show only approved metadata. | S-15, O-01 through O-03 |
| Published knowledge | KV is authoritative for readable content; only enabled, approved current-version entries can ground public answers. | Retrieval and contract tests resolve selected IDs back to published KV. | C-01, H-07, V-07 |
| Private wedding systems | The concierge cannot read RSVP, guest, existing admin, or other private wedding data. | No binding, API route, credential, data model, or UI claims such access. | S-17, W-10 |
| Admin identity | Cloudflare Access blocks unauthenticated traffic; the Worker validates the assertion and an application allowlist before admin access. | Negative auth, issuer, audience, expiry, subject, and origin tests fail closed. | S-02 through S-05 |
| Secrets and production authority | Secrets stay outside Git and browser assets; only the owner supplies production values and authorizes release actions. | Secret scan, least-privilege review, and human approval records. | S-14, G-02, G-10 through G-13 |

## Success measures and release gates

All values in this section are **targets**, not claims of current or achieved
performance. Results may be reported only after the named evaluation or
measurement is run against the approved build and environment. Technical rows
are pre-production release gates; the two portfolio rows are explicitly timed
post-launch outcome proxies.

| Dimension | Target or review cadence | Measurement boundary | Decisions |
|---|---|---|---|
| Evaluation corpus | At least 50 sanitized cases: 15 direct, 15 paraphrases, 5 misspellings, 5 ambiguous/follow-up, 5 unsupported, and 5 injection/adversarial. | Committed, reviewable dataset with expected sources, required facts, and forbidden claims. | T-02 |
| Supported retrieval | At least 95% of supported cases select the correct approved source in the top three. | Retrieval selection is scored independently from generated wording. | T-03, H-12 |
| Unsupported safety | At least 95% of unsupported cases correctly reject rather than invent an answer. | Verify threshold outcome, fallback mode, and absence of Claude calls. | T-03, H-08 |
| Critical facts | 100% preservation of required dates, times, addresses, and approved URLs in committed cases. | Compare output with explicit expected facts. | T-04 |
| Injection safety | 100% of committed injection cases avoid system-prompt disclosure, unsupported claims, and unapproved actions. | Run the committed adversarial set and inspect forbidden-claim results. | T-05, H-13 |
| Public-data safety | Zero secrets or private guest data in public repository artifacts, demo content, screenshots, recordings, logs, or model context. | Automated secret checks plus human public/private-data review. | P-04, S-14, S-15, S-17 |
| Accessibility | Target WCAG 2.2 AA, including full keyboard operation, focus trap and return, Escape close, labels, live regions, contrast, reduced motion, and touch targets of at least 44 px. | Automated and manual browser checks; viewport emulation is not claimed as physical-device testing. | W-06, T-07 |
| Cached/canonical API latency | Staging p95 below 500 ms. | Approved staging measurement with cache/canonical response mode identified. | T-08 |
| Generated-answer latency | Staging p95 below 8 seconds, with provider-dependent variance documented. | Approved staging measurement with generated response mode identified. | T-08 |
| Widget asset size | JavaScript at or below 50 KiB gzip and CSS at or below 15 KiB gzip, excluding the Turnstile script. | Production build artifact measurement. | W-07 |
| Host-site impact | No material layout shift from the closed widget and no more than a 5-point Lighthouse mobile performance regression. | Before/after wedding-site comparison using the approved build. | T-09 |
| Domain-module coverage | At least 80% line and 75% branch coverage on Worker domain modules. | CI coverage report; generated UI glue is excluded from the target. | T-06 |
| Monthly operating cost | Normal operation at or below $5/month excluding the already-owned domain; Cloudflare Workers, KV, Vectorize, Workers AI, Access, Turnstile, and eligible static usage stay within Free-plan allowances. | Provider usage and pricing review before implementation, launch, and quarterly; measured invoices/usage after launch. | D-09, Q-01, Q-06 |
| Anthropic exposure | Initial project limit/alert of $5/month, with provider alerts at 50%, 80%, and 100% where supported. | Human-confirmed provider settings and documented response to thresholds. | Q-02, Q-03 |
| Availability | Best-effort portfolio service with graceful degradation and recovery; no contractual uptime or strict rate-accuracy SLA. | Failure-mode tests, hourly no-AI health monitoring, and documented runbooks rather than an invented uptime percentage. | P-10, T-10, O-05 |
| Portfolio discoverability | Within 14 calendar days of production enablement, the live demo and public repository are linked from at least one owner-selected public portfolio or freelance profile, and the repository links back to the live demo. | Owner-reviewed link record and reachability check at launch, after 14 days, and quarterly while the demo remains public. | P-02, F-03, F-05 |
| Portfolio engagement review | Complete an initial outcome review 90 days after public launch and quarterly thereafter using the existing privacy-safe aggregate demo request-volume metric and a count of voluntarily initiated, demo-attributable freelance inquiries or technical-review conversations maintained outside the public repository. | Dated owner review records the observed values, limitations, and whether to continue, reposition, pause, or decommission. This adds no visitor identity, cookies, contact-click instrumentation, or analytics dashboard and does not claim that traffic caused an inquiry. | O-04, F-03 through F-05, S-15 |

## Portfolio outcome review and lifecycle controls

The owner controls every pause, continuation, and decommission decision. These
criteria are review triggers, not autonomous authority for an agent or runtime
process. A pause keeps the public assistant unavailable while the owner reviews
evidence and an approved corrective change; it does not silently relax a safety,
privacy, quality, cost, or Free-plan requirement.

### Pause criteria

The owner pauses the public assistant and keeps the wedding-site feature flag
off when any of the following is observed:

- suspected secret or private-data exposure, a committed injection-safety or
  critical-fact regression, unsupported-answer performance below its release
  gate, or a failed abuse or admin-authorization boundary;
- actual or forecast normal monthly operations above the $5 target, loss of an
  applicable Cloudflare Free-plan allowance, or provider changes that make the
  approved cost controls unreliable;
- a required kill switch, lexical fallback, safe unavailable state, or current
  rollback path is not demonstrably usable; or
- a provider, platform, or model change makes the approved security, privacy,
  quality, or best-effort behavior infeasible within V1 scope.

The owner may also pause for portfolio relevance after the 90-day outcome review.
If both privacy-safe demo usage and attributable inquiry/review evidence remain
absent across two consecutive quarterly reviews, the owner records whether to
reposition the public presentation, continue with an explicit rationale, or
decommission. Absence of engagement is a decision trigger, not permission for an
agent to alter production state.

### Decommission criteria and outcome

The owner may decommission V1 when the portfolio objective has been met or
abandoned, when two consecutive monthly cost reviews cannot restore the approved
cost boundary without scope expansion, or when a paused safety, privacy, or
platform-viability condition has no approved remediation.

Decommissioning means the human owner takes the live demo and public assistant
offline, keeps the wedding-site feature flag disabled, retires production
resources and secrets through an approved runbook, and updates public status
claims. The sanitized public repository and non-sensitive, clearly historical
portfolio evidence remain available for review. Decommissioning never authorizes
an agent to deploy, delete resources, revoke secrets, or change DNS; those actions
remain human-controlled. The detailed operations and evidence-retention steps
belong in the later approved design and runbook package.

**Traceability:** G-02, G-07, D-09, O-06, Q-01 through Q-06, F-03, F-04.

## Consolidated product risks

This summary helps product reviewers find the most material risks. It does not
replace the threat model, architecture risk analysis, or operational runbooks
that later seed issues must propose and the owner must approve.

| Product risk | Product mitigation and evidence pointer | Detailed follow-up |
|---|---|---|
| The portfolio exists but is not discoverable or does not produce useful review or inquiry signals. | Use the discoverability and quarterly engagement proxies above; report observed evidence without claiming causality or exposing visitor identity. | Seed 2 portfolio topology and later launch/runbook review |
| The assistant returns unsupported, altered, or instruction-injected event information. | Fail-closed calibrated retrieval, canonical exact answers, fixed unsupported fallback, critical-fact and injection release gates. | Retrieval design, prompt contract, threat model, and evaluation strategy |
| Public artifacts or telemetry expose private wedding, guest, conversation, identity, or secret data. | Fictional/sanitized content, persistent disclosure, no private-system integration, restricted logging, public/private-data review, and secret scans. | Threat model, data model, logging policy, and content-approval runbook |
| Vectorize, Workers AI, Claude, KV, or the host integration degrades or becomes unavailable. | KV remains authoritative; lexical retrieval, canonical answers, safe unavailable states, best-effort expectations, independent kill switches, and rollback remain required. | HLD failure flows, LLD, test strategy, and outage/rollback runbooks |
| Usage, pricing, quotas, or platform changes exceed the portfolio's cost boundary. | Free-plan constraint, bounded provider use, alerts, human review, runtime disable, and the pause/decommission criteria above. | Cost model, quota revalidation, unexpected-spend runbook, and owner approval |

## Known limitations

- V1 content and retrieval are English-only.
- The knowledge base is a small curated corpus, initially targeted at 20–30
  entries and limited to 100 enabled entries.
- Workers KV is eventually consistent; the publication and fallback design
  reduces impact but does not claim globally instantaneous propagation.
- Workers rate limiting is approximate and local to Cloudflare enforcement
  behavior; it is not strict global accounting.
- Claude responses are non-streaming and provider latency or availability can
  produce a temporary-unavailable response.
- Conversation state exists in browser memory only and is cleared by reload or
  explicit clear; there is no server-side conversation persistence.
- The assistant has no private-data, RSVP, guest, or existing-admin integration
  and cannot answer personalized questions.
- It is a best-effort portfolio demonstration, not a contractual high-availability
  service or an active wedding guest service.
- The initial corpus and committed evaluation set cannot prove correctness for
  every possible phrasing; measured claims are limited to the approved cases and
  environments tested.

## Assumptions, dependencies, and owner inputs

### Product and design assumptions already decided

- The product remains a reusable event concierge demonstrated with sanitized
  wedding content, not a wedding-specific private service.
- Prospective freelance clients and technical reviewers remain the primary
  audiences; public visitors are secondary users.
- English-only retrieval, best-effort availability, bounded non-streaming Claude
  use, and the approved V1 inclusions/exclusions remain fixed unless the owner
  approves an explicit superseding decision.
- Workers KV remains authoritative, Vectorize remains rebuildable, and lexical
  retrieval remains available as fallback.
- The existing domain is already owned and excluded from the monthly operations
  target.
- External pricing, quotas, model availability, and plan features are
  time-sensitive and must be revalidated before implementation and launch.

### Owner-supplied deployment inputs, not open product decisions

These values and approvals are deliberately unresolved until human-controlled
environment setup. Their absence does not change the product requirements and
must not be filled with guessed or repository-stored secret values.

| Owner input | Why it is needed later | Boundary |
|---|---|---|
| Cloudflare account and zone IDs | Bind resources to the intended account and domain. | Human supplies; non-secret identifiers may be documented only after approval. |
| Cloudflare Access team domain and application audience | Configure and verify admin JWT trust. | Human configures and confirms. |
| Exact approved admin identities | Define Access and application allowlists. | Personal identifiers must not be invented or exposed unnecessarily. |
| Actual canonical `www` behavior for the wedding domain | Determine whether the `www` origin belongs in production CORS. | Add only after human verification; no speculative allowlist entry. |
| KV namespace and Vectorize index IDs for each environment | Bind isolated staging and production data resources. | Created and supplied during human-controlled setup. |
| Turnstile sitekeys and secrets for staging and production | Protect each public environment. | Sitekeys may be public configuration; secrets never enter Git. |
| Anthropic project keys and final account spending controls | Enable bounded answer generation. | Keys are production secrets; budget controls require human confirmation. |
| Least-privilege GitHub and Cloudflare credential identifiers | Run approved automation with narrow authority. | Credential material is never recorded here. |
| Wedding repository location and deployment access | Implement the later separately approved feature-flag integration. | Outside this repository and this issue's authorization. |
| External monitoring destination and notification channel | Route health and spend alerts to the owner. | Human chooses and configures the destination. |

### Human approvals still required

- Approve and merge this PRD before it becomes authoritative and before Seed 2
  is released.
- Approve the future HLD, ADRs, detailed design and assurance package, and
  implementation task graph.
- Approve all production content, secrets, environment settings, spend controls,
  deployment, feature-flag enablement, rollback, and pull-request merges.
- Confirm measured evidence before converting any target in this document into a
  public result claim.

No unresolved product-scope choice was discovered while producing this proposal.
If review introduces a choice that materially changes the approved boundary, it
must be recorded as an explicit owner decision rather than inferred from silence.

## Acceptance-criteria traceability

| AJA-5 acceptance criterion | Evidence in this document | Decision coverage |
|---|---|---|
| Primary and secondary audiences and the portfolio outcome are explicit. | [Product summary](#product-summary), [Portfolio outcome](#portfolio-outcome), and [Audiences and personas](#audiences-and-personas) | P-01, P-02, F-03 through F-05 |
| Public visitor, unsupported-question, admin editing, publishing, rollback, and wedding-site feature-flag journeys are documented. | [User journeys](#user-journeys), Journeys 1–6 | P-06, H-08, U-01 through U-11, M-01 through M-10, W-08 through W-10 |
| Every V1 inclusion and exclusion matches the approved baseline. | [Version 1 scope](#version-1-scope) | P-03 and the baseline's Phase 0 scope |
| English-only behavior, best-effort availability, fictional/sanitized data, persistent demo disclosure, and no private RSVP/guest integration are explicit. | PR-PUB-02, PR-PUB-07, [Privacy, data, and trust boundaries](#privacy-data-and-trust-boundaries), and [Known limitations](#known-limitations) | P-04, P-05, P-09, P-10, S-17 |
| Quantified retrieval, safety, accessibility, performance, and monthly-cost success measures are included without claiming unmeasured results. | [Success measures and release gates](#success-measures-and-release-gates) | T-02 through T-09, W-06, W-07, Q-01 through Q-03 |
| Owner-supplied deployment inputs are separated from product/design decisions. | [Assumptions, dependencies, and owner inputs](#assumptions-dependencies-and-owner-inputs) | G-02, G-14 and baseline Section 26 |
| No application code, infrastructure, secret, deployment, or production change is made. | [Delivery non-goals and authority boundaries](#delivery-non-goals-and-authority-boundaries) and the single-file PR diff | G-02, G-05, G-07, G-10 |
| The PR maps every acceptance criterion and relevant decision ID to review evidence. | This table, [Approved baseline decision coverage](#approved-baseline-decision-coverage), and the completed PR review packet | G-13, G-14, F-01 |

## Approved baseline decision coverage

This matrix explicitly accounts for every product (`P`), governance (`G`), and
portfolio/documentation (`F`) decision named as a required input to AJA-5. More
detailed technical decisions are traced beside the requirements and measures
they constrain.

| Decision | Product interpretation in this PRD | Evidence |
|---|---|---|
| P-01 | Deliver a reusable public event-concierge RAG application demonstrated with sanitized wedding content. | [Product summary](#product-summary) |
| P-02 | Optimize first for prospective clients and technical reviewers; treat public visitors as secondary users. | [Audiences and personas](#audiences-and-personas) |
| P-03 | Preserve the approved V1 inclusions and exclusions without platform expansion. | [Version 1 scope](#version-1-scope) |
| P-04 | Use only fictional or sanitized event content in every public artifact and environment. | [Privacy, data, and trust boundaries](#privacy-data-and-trust-boundaries) |
| P-05 | Persistently disclose the demonstration and sanitized/fictional data in the widget, demo, and README. | PR-PUB-07 and Journey 1 |
| P-06 | Embed the same versioned widget in the React/Vite wedding site behind a feature flag. | [Wedding-site integration](#wedding-site-integration) and Journey 6 |
| P-07 | Keep the concierge in this public repository and limit the wedding repository to the later widget integration. | [Delivery non-goals and authority boundaries](#delivery-non-goals-and-authority-boundaries) |
| P-08 | Use the MIT license unless a reviewed dependency or asset requires another compatible license. | Repository [LICENSE](../LICENSE) and delivery boundary |
| P-09 | Support English content and retrieval only in V1. | PR-PUB-02 and [Known limitations](#known-limitations) |
| P-10 | Provide best-effort service and graceful degradation without inventing an SLA. | [Success measures and release gates](#success-measures-and-release-gates) and [Known limitations](#known-limitations) |
| G-01 | Symphony may produce planned artifacts, code, tests, and evidence only after the relevant approved gates. | [Human approvals still required](#human-approvals-still-required) |
| G-02 | Scope/design approval, secrets, production settings, merge, deployment, and rollback remain human-owned. | [Delivery non-goals and authority boundaries](#delivery-non-goals-and-authority-boundaries) |
| G-03 | Bootstrap uses only four seed issues; this PRD is Seed 1. | [Document control](#document-control) |
| G-04 | Each later seed waits for explicit human approval of its predecessor. | [Human approvals still required](#human-approvals-still-required) |
| G-05 | The `design-only` exception permits this documentation and no application or infrastructure change. | [Delivery non-goals and authority boundaries](#delivery-non-goals-and-authority-boundaries) |
| G-06 | Future implementation dispatch requires approved designs, explicit criteria, completed dependencies, and no blocker label. | [Human approvals still required](#human-approvals-still-required) |
| G-07 | Successful agent work stops at Human Review and never merges, deploys, or marks work Done. | [Delivery non-goals and authority boundaries](#delivery-non-goals-and-authority-boundaries) |
| G-08 | The official runner begins locally on the owner's trusted Mac. | [Owner-supplied deployment inputs, not open product decisions](#owner-supplied-deployment-inputs-not-open-product-decisions) |
| G-09 | Initial Symphony concurrency remains one until the approved canary gate changes. | Delivery authority boundary; not a product behavior |
| G-10 | Agent work uses workspace-write isolation and receives no Cloudflare or Anthropic production credential. | [Privacy, data, and trust boundaries](#privacy-data-and-trust-boundaries) |
| G-11 | GitHub automation uses a dedicated repository-scoped fine-grained credential. | Owner-input table and secret boundary |
| G-12 | Linear operations use a team-scoped key exposed through the runner, not prompts or workspaces. | Delivery authority boundary; no Linear secret is part of the product |
| G-13 | Approval requires an explicit Linear transition/comment and human merge; silence is not approval. | [Human approvals still required](#human-approvals-still-required) |
| G-14 | Approved downstream artifacts and acceptance criteria may intentionally supersede the baseline and must record that change. | [Document control](#document-control) |
| F-01 | The complete named product, design, assurance, operations, and user-documentation package is required. | PR-EVD-01 and [Human approvals still required](#human-approvals-still-required) |
| F-02 | Architecture decisions use individual, linkable ADR files. | PR-EVD-01 |
| F-03 | Public evidence includes a demo, embed, diagram, screenshots, recording, CI badge, evaluation summary, and sanitized dataset. | PR-EVD-02 |
| F-04 | README claims only measured results and actually deployed services; it does not claim production scale, strict rate accuracy, or zero hallucinations. | PR-EVD-02 and [Success measures and release gates](#success-measures-and-release-gates) |
| F-05 | Portfolio framing describes the custom hybrid-RAG capabilities without representing the work as client delivery. | PR-EVD-03 and [Portfolio outcome](#portfolio-outcome) |
| F-06 | English-only retrieval, small corpus, eventual consistency, approximate/local rate limits, non-streaming, no persistence, and no private-data integration remain explicit limitations. | [Known limitations](#known-limitations) |

## Approval request

The owner is asked to approve this proposed PRD as the product baseline for the
next seed design task. Approval confirms that the stated audiences, V1 boundary,
journeys, privacy rules, targets, limitations, and owner-input separation match
the approved planning baseline. Approval does not authorize application code,
infrastructure changes, secrets, deployment, production content, or release.

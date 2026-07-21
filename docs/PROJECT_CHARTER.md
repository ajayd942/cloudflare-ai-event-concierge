# Project Charter

Status: Draft

## Objective

Build and publicly demonstrate a reusable, secure event-concierge RAG application using fictional or sanitized wedding content, including the same versioned widget embedded behind a feature flag in the existing wedding website.

## Portfolio outcome

The completed project must give prospective freelance clients and technical reviewers verifiable evidence of Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, Anthropic Claude integration, hybrid retrieval, secure administration, portable website embedding, automated testing, CI/CD, observability, and production operations without presenting the demo as a live guest service.

## Version 1 scope

- TypeScript Cloudflare Worker
- KV-backed draft, published content, immutable snapshots, and runtime configuration
- Cache API response caching for eligible single-turn grounded answers
- Workers AI text embeddings
- Vectorize semantic retrieval
- Deterministic lexical retrieval and hybrid ranking
- Canonical direct answers for exact prepared FAQs and concise Claude-generated answers only after approved context passes retrieval thresholds
- English-only portable TypeScript custom-element widget with Shadow DOM and a standalone demo using the same versioned artifact
- Cloudflare Access-protected admin application
- Turnstile, CORS, validation, rate limiting, and cost controls
- Staging and production environments
- Automated tests, RAG evaluations, deployment documentation, and rollback
- Cloudflare Workers, KV, Vectorize, Workers AI, Access, Turnstile, and eligible static usage remain within Free-plan allowances for development, staging, and production; only bounded Anthropic usage may incur normal operating cost, and quota pressure is handled by reducing traffic or disabling the assistant rather than upgrading Workers

## Non-goals

- Personalized RSVP or guest-data lookup
- Conversation persistence
- User accounts or multi-tenancy
- D1 or other authoritative content databases
- PDF/file ingestion
- Voice or WhatsApp integration
- Autonomous production deployment
- Fully automated pull-request merge
- Private wedding data in the repository, demo, screenshots, recordings, or model context

## Success criteria

- At least 95% of committed supported evaluation cases retrieve the correct approved source in the top three and produce grounded answers.
- At least 95% of committed unsupported cases are rejected with a safe fallback instead of invented information.
- Exact factual queries and natural-language paraphrases are both handled reliably.
- Committed critical dates, times, addresses, and approved URLs are preserved exactly, and all committed injection cases avoid prompt disclosure, unsupported claims, and unapproved actions.
- No secrets or private guest data are exposed or stored in public project artifacts.
- The widget, demo, and README persistently disclose that public information is fictional or sanitized.
- The widget works on the live React website and on mobile.
- Nontechnical administrators can safely draft, publish, and roll back content.
- A fresh environment can be reproduced using repository documentation.
- Every production-impacting action has a documented human approval and rollback path.
- Normal monthly operation targets no more than $5 excluding the already-owned domain, with Cloudflare services remaining on Free allowances.

## Authority

Symphony produces the formal documents, implementation task graph, code, tests, and review evidence. The repository owner approves scope, design, the task graph, secrets, production configuration, PR merge, deployment, rollback, and changes to trust policy. Agents may propose changes but cannot grant themselves additional authority.

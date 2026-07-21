# Project Charter

Status: Draft

## Objective

Build and publicly demonstrate a reusable, secure event-concierge RAG application embedded in the existing wedding website.

## Portfolio outcome

The completed project must demonstrate Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, Anthropic Claude integration, hybrid retrieval, secure administration, portable website embedding, automated testing, CI/CD, observability, and production operations.

## Version 1 scope

- TypeScript Cloudflare Worker
- KV-backed draft, published content, snapshots, configuration, and response cache
- Workers AI text embeddings
- Vectorize semantic retrieval
- Deterministic lexical retrieval and hybrid ranking
- Claude-generated answers grounded only in approved retrieved content
- Portable chat widget and standalone demo
- Cloudflare Access-protected admin application
- Turnstile, CORS, validation, rate limiting, and cost controls
- Staging and production environments
- Automated tests, RAG evaluations, deployment documentation, and rollback

## Non-goals

- Personalized RSVP or guest-data lookup
- Conversation persistence
- User accounts or multi-tenancy
- PDF/file ingestion
- Voice or WhatsApp integration
- Autonomous production deployment
- Fully automated pull-request merge

## Success criteria

- Supported questions retrieve the correct approved sources and produce grounded answers.
- Unsupported questions return a safe fallback instead of invented information.
- Exact factual queries and natural-language paraphrases are both handled reliably.
- No secrets or private guest data are exposed or stored in public project artifacts.
- The widget works on the live React website and on mobile.
- Nontechnical administrators can safely draft, publish, and roll back content.
- A fresh environment can be reproduced using repository documentation.
- Every production-impacting action has a documented human approval and rollback path.

## Authority

The repository owner approves scope, architecture, task decomposition, production configuration, PR merge, and release. Agents may propose changes but cannot grant themselves additional authority.


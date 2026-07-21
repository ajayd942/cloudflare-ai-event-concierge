# Agent Repository Guidance

Status: Draft — requires human approval before implementation work starts.

## Mission

Build a secure, portfolio-quality event concierge using Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, and Anthropic Claude.

## Source of truth

Agents must use approved documents in `docs/` as the source of truth. The owner-approved initial plan is the baseline until a reviewed PRD, HLD, LLD, ADR, or Linear acceptance criterion intentionally supersedes it. A document marked `Draft` is review material, not implementation authority. If required design information is missing, contradictory, or still draft, stop and move the Linear issue to `Needs Human Decision`.

The sole exception is an owner-approved seed issue labeled `design-only`: it may create its explicitly scoped documentation from the approved baseline even though downstream design documents do not exist yet. That exception never authorizes application code, infrastructure mutation, secrets, deployment, or production access.

## Working rules

- Work only on an approved Linear issue in `Ready for Agent`.
- Stay within the issue's stated scope and non-goals.
- Use an isolated branch/worktree for every issue.
- Never commit directly to `main`.
- Never merge a pull request.
- Never create, rotate, reveal, or use production secrets.
- Never perform production deployments, DNS changes, billing changes, or destructive cloud operations.
- Do not add unrelated refactors to a scoped change.
- Create a follow-up Linear proposal for worthwhile out-of-scope work.
- Do not log raw questions, answers, history, Turnstile tokens, JWTs, emails, IPs, API keys, authorization headers, guest data, or full content documents.

## Required engineering behavior

- Validate all external input at runtime.
- Keep KV as the readable source of truth for published content.
- Treat Vectorize as a retrieval index, not authoritative storage.
- Use Cache API rather than high-cardinality KV keys for response caching.
- Keep lexical retrieval available as a fallback for semantic retrieval.
- Call Claude only after a relevant approved context has been retrieved.
- Prefer small modules with explicit contracts and typed boundaries.
- Add or update tests with every behavior change.
- Update relevant documentation whenever an interface, data model, operational procedure, or architectural decision changes.

## Verification

The definitive commands will be added after the TypeScript project is bootstrapped. Until then, do not invent verification commands. Every implementation PR will eventually be required to pass lockfile installation, formatting, linting, type checking, unit tests, Worker integration tests, contract tests, retrieval evaluations, selected Chromium/WebKit browser tests, content validation, dependency-audit reporting, and all applicable production builds.

## Human handoff

Before moving an issue to `Human Review`, attach:

- Pull request link
- Summary of the change and rationale
- Acceptance-criteria mapping
- Tests and exact results
- Screenshots or video for user-interface work
- Security, privacy, cost, and operational impact
- Known limitations
- Rollback instructions
- Any decisions still requiring a human

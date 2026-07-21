# Agent Repository Guidance

Status: Draft — requires human approval before implementation work starts.

## Mission

Build a secure, portfolio-quality event concierge using Cloudflare Workers, Workers KV, Vectorize, Workers AI embeddings, and Anthropic Claude.

## Source of truth

Agents must use approved documents in `docs/` as the source of truth. A document marked `Draft` is review material, not implementation authority. If required design information is missing, contradictory, or still draft, stop and move the Linear issue to `Needs Human Decision`.

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
- Do not log API keys, authorization headers, guest data, or complete chat histories.

## Required engineering behavior

- Validate all external input at runtime.
- Keep KV as the readable source of truth for published content.
- Treat Vectorize as a retrieval index, not authoritative storage.
- Keep lexical retrieval available as a fallback for semantic retrieval.
- Call Claude only after a relevant approved context has been retrieved.
- Prefer small modules with explicit contracts and typed boundaries.
- Add or update tests with every behavior change.
- Update relevant documentation whenever an interface, data model, operational procedure, or architectural decision changes.

## Verification

The definitive commands will be added after the TypeScript project is bootstrapped. Until then, do not invent verification commands. Every implementation PR will eventually be required to pass formatting, linting, type checking, unit tests, integration tests, relevant browser tests, content validation, and a production build.

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


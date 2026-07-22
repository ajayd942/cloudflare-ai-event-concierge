# ADR-0001: Run local Symphony agents with danger-full-access

Status: Accepted

Date: 2026-07-23

Planning decision IDs: G-08, G-09, G-10, G-11, G-12

Supersedes: G-10's `workspace-write` requirement for the local Symphony runner only

Superseded by: None

## Context

The first documentation seed completed, but AJA-6 stopped before creating a branch because `git fetch origin --prune` could not write `.git/FETCH_HEAD`. The installed Codex `workspace-write` sandbox deliberately protects `.git` and the resolved Git directory as read-only. With `approval_policy: never`, an unattended Symphony run cannot request a one-off sandbox escalation.

Symphony must fetch, create an issue branch, commit, push, and update a pull request. A runner that can edit working-tree files but cannot write Git metadata cannot satisfy that lifecycle reliably.

## Options considered

### Keep workspace-write and repair or recreate AJA-6

Rejected. Filesystem ownership and modes were correct, and the AJA-6 checkout was clean. Recreating it with the same policy would reproduce the protected-Git-metadata failure.

### Add experimental command execution rules

Deferred. Narrow Git command rules could permit selected commands outside the sandbox, but they add another experimental policy layer that must be designed and tested against every required Git path, shell form, hook, and Symphony continuation. This remains the preferred future hardening direction.

### Use interactive approvals

Rejected for this runner. Symphony is intentionally unattended, and approval requests must not leave a run stalled. The current app-server compatibility configuration also requires the explicit non-interactive `never` policy.

### Use danger-full-access on the trusted host

Accepted by the repository owner as the immediate operating model. It restores Git metadata writes and keeps the runner simple enough for the portfolio project's four documentation seeds and subsequent reviewed work.

## Decision

Configure both the Codex thread and every turn for `danger-full-access`, while retaining:

- one foreground agent on the owner's trusted Mac;
- the exact project, required `design-only` label, active-state filter, and bootstrap issue allowlist;
- a dedicated GitHub token limited to this repository;
- the Linear token in the Symphony host process and outside the agent shell environment;
- explicit removal of Cloudflare, Anthropic, production, billing, DNS, and deployment credentials;
- a strict agent subprocess environment allowlist;
- human-only trust-policy changes, review, merge, deployment, release, and `Done` transitions;
- mandatory issue-workspace scope in the agent prompt and a doctor that fails closed on policy drift.

This permission change does not authorize the agent to inspect or modify unrelated host paths. That boundary is policy and review enforcement rather than a Codex filesystem sandbox.

## Consequences

Positive consequences:

- Agents can use the normal Git branch, commit, merge, and push lifecycle.
- AJA-6 can resume without a nested recovery clone or an interactive approval channel.
- The runtime policy is explicit, versioned, probed against the installed app-server, and checked before startup.

Negative consequences:

- A compromised or misdirected agent process can technically read or modify files outside its issue workspace.
- Prompt injection, malicious repository content, or an unsafe tool command has a larger potential blast radius.
- Prompt restrictions, token scoping, environment filtering, foreground operation, and human review reduce but do not eliminate that host risk.

Operational consequences:

- Run Symphony only while an approved issue is active and stop it at human handoff.
- Do not make untrusted Linear issues eligible or expose additional host credentials.
- Treat a move back to `workspace-write`, a dedicated OS user/container, or narrowly allowlisted Git execution as a future reviewed hardening change.
- After this ADR is merged, recreate the clean AJA-6 workspace before resuming the issue so it starts from the reviewed `main` configuration.

## Approval

- Approver: Ajay Dubey
- Decision date: 2026-07-23
- Related Linear issue: [AJA-6](https://linear.app/ajayd94/issue/AJA-6/seed-24-produce-hld-and-architecture-decision-proposals)
- Related PR: This pull request
- Evidence reviewed: AJA-6 Codex Workpad; clean workspace and host permission inspection; installed Codex app-server schema; no-turn compatibility probe returning `dangerFullAccess`; OpenAI Symphony specification and reference implementation documentation

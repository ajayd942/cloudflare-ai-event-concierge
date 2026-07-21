---
name: push
description: Push the validated issue branch and create or update its review-ready GitHub pull request without merging it.
---

# Push and open a PR

1. Read `AGENTS.md`, the Linear issue, and `.github/PULL_REQUEST_TEMPLATE.md`.
2. Confirm the current branch is an issue branch, never `main`, and the diff contains only approved scope.
3. Run all acceptance-criteria validation and `git diff --check` immediately before pushing.
4. Push normally with upstream tracking. Use `--force-with-lease` only after an intentional history rewrite; never use `--force`.
5. Derive a plain-language title from the reviewer-visible outcome, not the implementation activity or issue identifier. Keep it under 72 characters and omit conventional-commit prefixes unless the prefix adds information a reviewer needs.
6. Use `gh` with the injected fine-grained token. Create a draft PR if none exists; update the existing open PR otherwise. Never reuse a branch whose PR is closed or merged.
7. Fill the PR template for a reviewer who has not followed the implementation conversation. Lead with why, outcome, out-of-scope, and the exact decision requested; then provide a change map, risk-first review order, acceptance-to-evidence mapping, verification, impact, limitations, and rollback. Do not leave placeholders.
8. Explain decision IDs in plain language and link them to their source. Remove repeated detail and stale prerequisites whenever the branch, checks, credentials, or issue state changes.
9. Re-read the rendered title and body, top-level comments, inline comments, review summaries, and check results. Address every actionable item or post a justified response, then rerun validation and push.
10. Mark the PR ready only after the branch is current with `origin/main`, checks pass, and the review packet is complete.
11. Attach the PR to Linear and atomically move the issue to `Human Review` with the owner assigned.
12. Stop. Never approve, merge, deploy, or mark the issue `Done`.

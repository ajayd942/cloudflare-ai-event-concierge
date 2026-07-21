---
name: push
description: Push the validated issue branch and create or update its review-ready GitHub pull request without merging it.
---

# Push and open a PR

1. Read `AGENTS.md`, the Linear issue, and `.github/PULL_REQUEST_TEMPLATE.md`.
2. Confirm the current branch is an issue branch, never `main`, and the diff contains only approved scope.
3. Run all acceptance-criteria validation and `git diff --check` immediately before pushing.
4. Push normally with upstream tracking. Use `--force-with-lease` only after an intentional history rewrite; never use `--force`.
5. Use `gh` with the injected fine-grained token. Create a draft PR if none exists; update the existing open PR otherwise. Never reuse a branch whose PR is closed or merged.
6. Fill every PR-template section with decision IDs, acceptance-criteria mapping, exact evidence, impact, limitations, rollback, and human decisions. Do not leave placeholders.
7. Re-read top-level comments, inline comments, review summaries, and check results. Address every actionable item or post a justified response, then rerun validation and push.
8. Mark the PR ready only after the branch is current with `origin/main`, checks pass, and the review packet is complete.
9. Attach the PR to Linear and atomically move the issue to `Human Review` with the owner assigned.
10. Stop. Never approve, merge, deploy, or mark the issue `Done`.

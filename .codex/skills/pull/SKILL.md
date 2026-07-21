---
name: pull
description: Synchronize the issue branch with origin/main using a reviewable merge and rerun affected checks.
---

# Pull

1. Require a clean worktree or an intentional commit before synchronization.
2. Enable local `rerere.enabled` and `rerere.autoupdate`.
3. Fetch `origin`, fast-forward the remote feature branch if one exists, then merge `origin/main` with `zdiff3` conflict style.
4. Do not rebase published work and never use an unconditional force push.
5. Resolve conflicts by preserving the approved issue outcome and current contracts; stop for a material product/design ambiguity.
6. Run `git diff --check`, all issue-required validation, and record merge evidence in the Linear workpad.

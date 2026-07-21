---
name: commit
description: Create an intentional commit containing only the current Linear issue's validated scope.
---

# Commit

1. Inspect `git status`, unstaged diff, staged diff, and untracked files.
2. Confirm every file belongs to the current issue and no generated artifact, log, secret, or unrelated change is included.
3. Run the issue-required validation before staging.
4. Stage explicit paths; use `git add -A` only when the entire worktree is confirmed in scope.
5. Use an imperative conventional subject no longer than 72 characters and a body summarizing rationale and validation.
6. Include `Co-authored-by: Codex <codex@openai.com>`.
7. Re-read the committed diff and record the SHA and validation evidence in the Linear workpad.

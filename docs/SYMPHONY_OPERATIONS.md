# Local Symphony Operations

Status: Bootstrap configuration awaiting owner review

## Installed runtime

The Mac uses OpenAI Symphony's experimental reference implementation:

- Version: `v0.0.1`
- Platform: `macos_arm64`
- Binary: `/opt/homebrew/bin/symphony`
- Versioned target: `~/.local/share/openai-symphony/v0.0.1/symphony-v0.0.1-macos_arm64`
- Verified SHA-256: `e75cb8badada6dd8ed1f65fba808773ddbd8461d357b2fd2943f96df35d92eb9`

Symphony is an engineering preview intended for trusted environments. This setup follows the [official README](https://github.com/openai/symphony/blob/main/README.md), [reference implementation guide](https://github.com/openai/symphony/blob/main/elixir/README.md), and [service specification](https://github.com/openai/symphony/blob/main/SPEC.md).

The `v0.0.1` binary also requires the explicit CLI acknowledgment `--i-understand-that-this-will-be-running-without-the-usual-guardrails`. The checked-in start script includes it so the warning is visible and reviewable; running that script is a deliberate owner action, not an unattended login service.

## Trust boundaries

- Run Symphony only on the owner's trusted Mac.
- Start with one agent and the `design-only` required label.
- Each issue gets an isolated workspace under `~/.local/share/symphony/workspaces/cloudflare-ai-event-concierge`.
- Codex receives workspace-write access and network access required for GitHub and package/test commands.
- Symphony keeps the Linear token host-side and exposes the scoped `linear_graphql` tool to Codex.
- Codex receives only a dedicated fine-grained GitHub token limited to this repository's Contents and Pull requests permissions.
- Cloudflare, Anthropic, production, billing, DNS, and deployment credentials are explicitly removed before launch.
- Agents may create branches and PRs but may not merge, deploy, roll back, mark issues `Done`, or change trust policy.

## Required Keychain entries

| Purpose | Keychain service | Required scope |
|---|---|---|
| Linear tracker | `symphony-linear-api-key` | Existing team-scoped Linear personal key |
| GitHub branches and PRs | `symphony-github-cloudflare-ai-event-concierge` | Fine-grained token for only `ajayd942/cloudflare-ai-event-concierge`; Metadata read, Contents read/write, Pull requests read/write |

Do not reuse the current broad GitHub CLI credential. Creating the fine-grained token and saving it to Keychain is a human-only bootstrap action.

## Validate and start

From the repository root on `main` after the Symphony configuration PR is merged:

```bash
./scripts/symphony/doctor.sh
./scripts/symphony/start-local.sh
```

The dashboard is available at `http://127.0.0.1:4040`. To stop the foreground release build, press `Ctrl-C`, then type `a` at the Erlang `BREAK` menu. Logs are written under `~/.local/state/symphony/cloudflare-ai-event-concierge/logs`; no application questions, model answers, or production secrets belong there.

The start script deliberately fails if either Keychain credential is missing. It also refuses to launch from a dirty checkout or from a branch other than `main`.

## Seed execution sequence

1. Keep all four seed issues outside `Ready for Agent` while setup is being reviewed.
2. After this configuration PR is merged and `doctor.sh` passes, the owner moves only Seed 1 to `Ready for Agent`.
3. Symphony claims Seed 1, creates a workspace, produces a documentation PR, attaches it to Linear, assigns the owner, and moves the issue to `Human Review`.
4. The owner reviews the PR. For requested changes, move the issue to `In Progress`; Symphony resumes the same workspace and returns it to `Human Review` after validation.
5. The owner merges an approved PR and marks the seed issue `Done`.
6. The owner moves the next now-unblocked seed issue to `Ready for Agent`.
7. Repeat through the implementation-task-graph seed. Generated implementation issues remain in `Plan Review` until the owner approves the graph.

## Pull-request boundary

Symphony may push a feature branch, open/update a PR, read review comments, respond to actionable feedback, and rerun checks. It stops at `Human Review`. GitHub CODEOWNERS and branch protection remain the merge boundary, and the owner is the only actor allowed to approve or merge.

## Upgrades

Treat Symphony upgrades as reviewed infrastructure changes:

1. Read the official release notes and reference implementation changes.
2. Download the Apple-silicon asset and its checksum from the official GitHub release.
3. Verify both the release-provided checksum and GitHub asset digest.
4. Install to a new versioned directory and update the symlink only after validation.
5. Run a documentation-only canary before accepting the new version.

Never follow the moving `main` branch automatically for this runner.

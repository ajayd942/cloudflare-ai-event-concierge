#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
linear_service="symphony-linear-api-key"
github_service="symphony-github-cloudflare-ai-event-concierge"

"$repo_root/scripts/symphony/doctor.sh"

export LINEAR_API_KEY="$(security find-generic-password -s "$linear_service" -w)"
export GH_TOKEN="$(security find-generic-password -s "$github_service" -w)"
export GITHUB_TOKEN="$GH_TOKEN"
export SOURCE_REPO_URL="https://github.com/ajayd942/cloudflare-ai-event-concierge.git"
export SYMPHONY_WORKSPACE_ROOT="$HOME/.local/share/symphony/workspaces/cloudflare-ai-event-concierge"
export CODEX_BIN="/Applications/ChatGPT.app/Contents/Resources/codex"

unset ANTHROPIC_API_KEY
unset CLOUDFLARE_API_KEY
unset CLOUDFLARE_API_TOKEN
unset CF_API_KEY
unset CF_API_TOKEN

logs_root="$HOME/.local/state/symphony/cloudflare-ai-event-concierge/logs"
mkdir -p "$SYMPHONY_WORKSPACE_ROOT" "$logs_root"

exec symphony \
  --i-understand-that-this-will-be-running-without-the-usual-guardrails \
  --logs-root "$logs_root" \
  --port "${SYMPHONY_PORT:-4040}" \
  "$repo_root/WORKFLOW.md"

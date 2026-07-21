#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
expected_symphony_sha="e75cb8badada6dd8ed1f65fba808773ddbd8461d357b2fd2943f96df35d92eb9"
linear_service="symphony-linear-api-key"
github_service="symphony-github-cloudflare-ai-event-concierge"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

for command_name in symphony git gh curl jq security shasum; do
  command -v "$command_name" >/dev/null 2>&1 || fail "missing command: $command_name"
done

codex_path="/Applications/ChatGPT.app/Contents/Resources/codex"
test -x "$codex_path" || fail "missing Codex app-server binary: $codex_path"

machine="$(uname -m)"
test "$machine" = "arm64" || fail "expected Apple silicon, found $machine"

symphony_path="$(command -v symphony)"
symphony_target="$(readlink "$symphony_path" || true)"
test -n "$symphony_target" || symphony_target="$symphony_path"
actual_sha="$(shasum -a 256 "$symphony_target" | cut -d ' ' -f 1)"
test "$actual_sha" = "$expected_symphony_sha" || fail "Symphony checksum mismatch"

linear_token="$(security find-generic-password -s "$linear_service" -w 2>/dev/null || true)"
github_token="$(security find-generic-password -s "$github_service" -w 2>/dev/null || true)"
test -n "$linear_token" || fail "missing Keychain service: $linear_service"
test -n "$github_token" || fail "missing Keychain service: $github_service"

viewer_payload='{"query":"query { viewer { id } }"}'
viewer_id="$(curl --fail --silent --show-error https://api.linear.app/graphql -H "Authorization: $linear_token" -H 'Content-Type: application/json' --data "$viewer_payload" | jq -r '.data.viewer.id // empty')"
test "$viewer_id" = "65c7a930-259a-42c5-b166-424290a77605" || fail "Linear credential resolved to the wrong viewer"

repo_status="$(curl --silent --output /dev/null --write-out '%{http_code}' -H "Authorization: Bearer $github_token" -H 'Accept: application/vnd.github+json' https://api.github.com/repos/ajayd942/cloudflare-ai-event-concierge)"
test "$repo_status" = "200" || fail "GitHub credential cannot read the repository"

broad_credential="$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill 2>/dev/null | sed -n 's/^password=//p' || true)"
if test -n "$broad_credential" && test "$github_token" = "$broad_credential"; then
  fail "dedicated Symphony GitHub token matches the broad interactive Git credential"
fi

test -f "$repo_root/WORKFLOW.md" || fail "WORKFLOW.md is missing"
test -z "$(git -C "$repo_root" status --porcelain)" || fail "repository checkout is dirty"
test "$(git -C "$repo_root" branch --show-current)" = "main" || fail "start Symphony only from main"

printf 'PASS: Symphony binary and checksum\n'
printf 'PASS: Codex, Git, GitHub CLI, and support tools\n'
printf 'PASS: Linear Keychain credential and viewer\n'
printf 'PASS: dedicated GitHub credential can read the repository\n'
printf 'PASS: clean main checkout and repository workflow\n'

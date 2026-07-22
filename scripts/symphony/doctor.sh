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

for command_name in symphony git gh curl jq ruby security shasum; do
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
runtime_policy="$(
  ruby -ryaml -e '
    document = File.read(ARGV.fetch(0))
    front_matter = document.split(/^---\s*$/, 3).fetch(1)
    config = YAML.safe_load(front_matter, permitted_classes: [], permitted_symbols: [], aliases: false)
    command = config.dig("codex", "command").to_s
    values = [
      config.dig("codex", "approval_policy"),
      config.dig("codex", "thread_sandbox"),
      config.dig("codex", "turn_sandbox_policy", "type"),
      command.include?("shell_environment_policy.ignore_default_excludes=true"),
      command.include?("shell_environment_policy.include_only="),
      command.include?("GH_TOKEN"),
      command.include?("GITHUB_TOKEN"),
      command.include?("LINEAR_API_KEY")
    ]
    puts values.join("\t")
  ' "$repo_root/WORKFLOW.md"
)" || fail "WORKFLOW.md front matter is invalid"
IFS=$'\t' read -r approval_policy thread_sandbox turn_sandbox_type explicit_secret_filter environment_allowlist has_gh_token has_github_token leaks_linear_token <<< "$runtime_policy"
test "$approval_policy" = "never" || fail "codex.approval_policy must be never for the installed Codex app-server"
test "$thread_sandbox" = "danger-full-access" || fail "codex.thread_sandbox must be danger-full-access"
test "$turn_sandbox_type" = "dangerFullAccess" || fail "codex.turn_sandbox_policy.type must be dangerFullAccess"
test "$explicit_secret_filter" = "true" || fail "Codex shell policy must explicitly control default secret filtering"
test "$environment_allowlist" = "true" || fail "Codex shell policy must use an environment allowlist"
test "$has_gh_token" = "true" || fail "Codex shell allowlist must include GH_TOKEN"
test "$has_github_token" = "true" || fail "Codex shell allowlist must include GITHUB_TOKEN"
test "$leaks_linear_token" = "false" || fail "Codex shell allowlist must not expose LINEAR_API_KEY"

schema_support="$(
  ruby -rtmpdir -e '
    Dir.mktmpdir("symphony-codex-schema") do |directory|
      generated = system(
        ARGV.fetch(0), "app-server", "generate-json-schema", "--out", directory,
        out: File::NULL, err: File::NULL
      )
      abort "schema generation failed" unless generated
      thread_schema = File.read(File.join(directory, "v2", "ThreadStartParams.json"))
      turn_schema = File.read(File.join(directory, "v2", "TurnStartParams.json"))
      puts [
        thread_schema.include?(%q{"danger-full-access"}),
        turn_schema.include?(%q{"dangerFullAccess"})
      ].join("\t")
    end
  ' "$codex_path"
)" || fail "could not inspect the installed Codex app-server schema"
IFS=$'\t' read -r supports_thread_full_access supports_turn_full_access <<< "$schema_support"
test "$supports_thread_full_access" = "true" || fail "installed Codex app-server does not support danger-full-access threads"
test "$supports_turn_full_access" = "true" || fail "installed Codex app-server does not support dangerFullAccess turns"

test -z "$(git -C "$repo_root" status --porcelain)" || fail "repository checkout is dirty"
test "$(git -C "$repo_root" branch --show-current)" = "main" || fail "start Symphony only from main"

printf 'PASS: Symphony binary and checksum\n'
printf 'PASS: Codex, Git, GitHub CLI, and support tools\n'
printf 'PASS: Linear Keychain credential and viewer\n'
printf 'PASS: dedicated GitHub credential can read the repository\n'
printf 'PASS: Codex approval policy is compatible with the installed app-server\n'
printf 'PASS: Codex danger-full-access thread and turn policies\n'
printf 'PASS: restricted agent shell environment and host-side Linear token\n'
printf 'PASS: clean main checkout and repository workflow\n'

---
tracker:
  kind: linear
  endpoint: https://api.linear.app/graphql
  api_key: $LINEAR_API_KEY
  project_slug: cloudflare-ai-event-concierge-eefcc601d728
  required_labels:
    - design-only
  active_states:
    - Ready for Agent
    - In Progress
    - Agent QA
  terminal_states:
    - Done
    - Rejected
    - Canceled
    - Cancelled
    - Duplicate
polling:
  interval_ms: 10000
workspace:
  root: $SYMPHONY_WORKSPACE_ROOT
hooks:
  after_create: |
    test -n "$SOURCE_REPO_URL"
    test -n "$GH_TOKEN"
    git clone --origin origin --depth 1 "$SOURCE_REPO_URL" .
    git config --local credential.https://github.com.helper '!gh auth git-credential'
    git config --local rerere.enabled true
    git config --local rerere.autoupdate true
    gh auth status
  timeout_ms: 120000
agent:
  max_concurrent_agents: 1
  max_turns: 20
codex:
  command: >-
    "$CODEX_BIN" --config shell_environment_policy.inherit=all
    --config 'model="gpt-5.6-sol"'
    --config model_reasoning_effort=xhigh app-server
  thread_sandbox: workspace-write
  turn_sandbox_policy:
    type: workspaceWrite
    networkAccess: true
---

# Symphony Development Workflow

Status: Configured for owner review and a documentation-only canary. Implementation dispatch remains disabled by the required `design-only` label until a later human-reviewed workflow change.

## Purpose

Linear is the project control plane. Symphony may dispatch agents only for explicitly approved and unblocked work. Successful agent execution ends at `Human Review`, not `Done`. The owner-approved initial plan is the bootstrap baseline; subsequently approved PRD/HLD/LLD/ADRs and issue acceptance criteria take precedence and must record intentional supersession.

## Current issue context

You are running unattended for Linear issue `{{ issue.identifier }}`.

- Title: `{{ issue.title }}`
- State: `{{ issue.state }}`
- Labels: `{{ issue.labels }}`
- URL: `{{ issue.url }}`

Read the complete issue description before acting. Work only inside the provided repository workspace. Use the injected `linear_graphql` tool for Linear reads and writes; never retrieve or print the raw Linear token.

Before editing, fail closed unless the issue belongs to this project, is labeled `design-only`, is in an active state, has no unresolved blocker or human-control label, and is one of the four approved seed tasks. Move a policy-blocked issue to `Needs Human Decision`, assign the repository owner in the same update, record a concise blocker in the single workpad comment, and stop.

For an eligible issue:

1. Move it to `In Progress` and create or update one `## Codex Workpad` comment containing the plan, acceptance criteria, validation, and evidence.
2. Fetch `origin/main`, create a new `symphony/<issue-identifier>-<short-slug>` branch, and read `AGENTS.md`, the issue, the approved baseline, and applicable approved artifacts.
3. Produce only the documentation or Linear control-plane output authorized by the issue. Do not change application code, cloud resources, secrets, credentials, billing, DNS, or production state.
4. Validate every acceptance criterion and all applicable repository checks. Review the complete diff for scope, security, privacy, cost, and unsupported claims.
5. Commit intentionally, push the branch, and create or update a pull request using the repository template. The PR must map acceptance criteria and decision IDs to evidence and must never contain secrets or private wedding data.
6. Attach the PR to the Linear issue. Resolve all actionable PR feedback and rerun validation before handoff.
7. Only when the branch is pushed, checks pass, and the review packet is complete, atomically move the issue to `Human Review` and assign reviewer `65c7a930-259a-42c5-b166-424290a77605`.
8. Stop. Never merge the PR, deploy, roll back production, create or rotate secrets, change trust policy, or mark the issue `Done`.

If a reviewer requests changes, the human returns the issue to `In Progress`; resume the preserved workspace, address the accepted feedback, update the same workpad, push the revision, and return it to `Human Review`. If the PR is merged, only the human marks the issue `Done` and releases the next blocked seed issue.

## Linear states

| State | Owner | Meaning |
|---|---|---|
| `Inbox` | Human | Unreviewed idea or request |
| `Discovery` | Agent + human | Requirements or investigation in progress |
| `Design Review` | Human | Technical documents await approval |
| `Ready for Planning` | Human | Approved design may be decomposed |
| `Plan Review` | Human | Proposed issue graph awaits approval |
| `Ready for Agent` | Symphony | Approved, unblocked, executable work |
| `In Progress` | Agent | Agent is actively working |
| `Agent QA` | Agent | Implementation and evidence are being verified |
| `Human Review` | Human | Review-ready PR or document packet |
| `Ready to Merge` | Human | Review approved; merge is authorized |
| `Done` | Human | Change is merged and required follow-up is complete |
| `Blocked` | Human + agent | An explicit dependency prevents progress |
| `Needs Human Decision` | Human | Work requires judgment or additional authority |
| `Rejected` | Human | Proposal will not proceed |

## Dispatch eligibility

For implementation work, Symphony may dispatch only issues in `Ready for Agent` that:

- Have approved linked design documents
- Have explicit scope and non-goals
- Have testable acceptance criteria
- Have all dependencies completed
- Are not labeled `human-only`, `security-sensitive`, or `production-change`
- Do not require production credentials or external authority

### Design-only bootstrap exception

An issue may omit pre-existing approved design documents only when all of these are true:

- The owner approved it and moved it to `Ready for Agent`.
- It has the `design-only` label and is one of the four seed issues: product definition, HLD/ADRs, detailed design, or implementation task-graph generation.
- Its predecessor approval gate is complete, its documentation scope and non-goals are explicit, and its acceptance criteria are testable.
- It changes only the specified documentation or control-plane artifacts; it does not change application code, infrastructure, secrets, credentials, or deployments.

The exception removes the design bootstrap cycle only. It does not weaken any implementation dispatch condition.

## Agent lifecycle

1. Claim one eligible Linear issue and create an isolated workspace.
2. Move it to `In Progress` and record the working branch.
3. Read the issue, linked approved documents, `AGENTS.md`, and applicable ADRs.
4. Implement only the approved scope.
5. Run required verification and move to `Agent QA`.
6. Open or update a draft pull request with the required review packet.
7. When all automated checks pass, mark the PR ready and move the issue to `Human Review`.
8. Assign the issue to the human reviewer.
9. If review requests changes, return to `In Progress`, address only accepted feedback, rerun verification, and return to `Human Review`.
10. Never merge or mark the issue `Done`; those transitions remain human-owned.

## Runner and canary policy

- Run the official reference implementation locally on the owner's trusted Mac first.
- Use workspace-write isolation and allow network access only where the dispatched issue requires it.
- Give the runner only a repository-scoped GitHub credential and team-scoped Linear access; never expose Cloudflare or Anthropic production credentials to an agent workspace.
- Start with one active agent. Increase to two only after three correctly scoped documentation/code canaries and an explicit owner decision.
- Fail closed if any credential boundary, state transition, reviewer assignment, or authority check cannot be enforced.

## Mandatory stop conditions

Move the issue to `Needs Human Decision` and stop when:

- A design decision is missing or conflicts with an approved document.
- Acceptance criteria are ambiguous or materially incomplete.
- Scope expansion is required.
- A production secret, deployment, DNS, billing, privacy, or data-retention decision is required.
- Tests reveal an architectural or security problem outside the issue scope.
- The agent cannot produce reliable verification evidence.

## Human-only actions

- Approve product scope, HLD, LLD, API contract, threat model, and task graph
- Create and rotate secrets
- Approve production content
- Configure production DNS, access policies, and spending limits
- Approve or execute production deployments and rollback
- Approve pull requests and merge to `main`
- Change the workflow's trust or approval policy

## Human-review handoff enforcement

Linear does not provide a general custom rule that assigns a specific user whenever an issue enters an arbitrary status. Therefore, Symphony must make the handoff with one `issueUpdate` mutation that sets both the `Human Review` state and the repository owner's assignee ID. Assignment causes Linear to subscribe and notify the reviewer.

The transition helper must fail closed: it must not move the issue to `Human Review` if it cannot also assign the reviewer. Agents must use the helper and must not reproduce this mutation ad hoc. The runtime identifiers are recorded in [`docs/LINEAR_CONFIGURATION.md`](docs/LINEAR_CONFIGURATION.md).

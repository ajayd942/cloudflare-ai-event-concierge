# Symphony Development Workflow

Status: Draft — core Linear identifiers are configured; the `design-only` label and Symphony runner configuration still require review and approval.

## Purpose

Linear is the project control plane. Symphony may dispatch agents only for explicitly approved and unblocked work. Successful agent execution ends at `Human Review`, not `Done`. The owner-approved initial plan is the bootstrap baseline; subsequently approved PRD/HLD/LLD/ADRs and issue acceptance criteria take precedence and must record intentional supersession.

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

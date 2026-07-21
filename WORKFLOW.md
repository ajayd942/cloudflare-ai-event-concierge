# Symphony Development Workflow

Status: Draft — runtime-specific configuration will be added after the Linear project identifiers and Symphony runner are configured.

## Purpose

Linear is the project control plane. Symphony may dispatch agents only for explicitly approved and unblocked work. Successful agent execution ends at `Human Review`, not `Done`.

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

Symphony may dispatch only issues in `Ready for Agent` that:

- Have approved linked design documents
- Have explicit scope and non-goals
- Have testable acceptance criteria
- Have all dependencies completed
- Are not labeled `human-only`, `security-sensitive`, or `production-change`
- Do not require production credentials or external authority

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

## Linear automation requirement

Configure an automation so that moving an issue to `Human Review` assigns it to the repository owner and notifies them. Symphony must not depend on an agent remembering this assignment manually.


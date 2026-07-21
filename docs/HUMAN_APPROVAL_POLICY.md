# Human Approval Policy

Status: Draft

## Approval gates

| Gate | Required evidence | Human decision |
|---|---|---|
| Product scope | Charter, use cases, non-goals, success metrics | Approve project scope |
| Architecture | HLD, diagrams, ADRs, cost and risk analysis | Approve technical direction |
| Detailed design | LLD, API contract, data model, threat model, test strategy | Approve implementation authority |
| Task graph | Linear issue tree, dependencies, acceptance criteria | Approve agent dispatch |
| Pull request | Passing CI and complete review packet | Approve code or request changes |
| Staging validation | Automatic post-merge staging deployment, smoke-test, and rollback evidence | Accept the staged build or require follow-up |
| Production release | Security, cost, content, DNS, and rollback checklist | Approve production deployment |

## Control labels

- `human-only`: issue must never be dispatched to an autonomous coding agent.
- `security-sensitive`: requires explicit security review and limited credentials.
- `production-change`: modifies live infrastructure, data, DNS, access, billing, or secrets.
- `needs-human-decision`: agent identified a material ambiguity or authority boundary.
- `design-only`: permits an explicitly approved seed documentation issue to run without pre-existing downstream design documents; never permits application code, infrastructure mutation, secrets, or deployment.

The `design-only` label is an exception to the design-document prerequisite, not to human approval, dependency, state, scope, or acceptance-criteria checks. Scope approval, design approval, task-graph approval, secrets, production settings, PR merge, deployment, rollback, and trust-policy changes remain human-owned.

## Review rule

Silence is not approval. Approval must be represented by the correct Linear state transition or an explicit approved review on the relevant document/PR.

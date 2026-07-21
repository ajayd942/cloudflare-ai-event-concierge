<!--
PR title: describe the reviewer-visible outcome in plain language.

Good: "Add request throttling to protect the public API"
Good: "Define the retrieval architecture and its trade-offs"
Avoid: "chore: updates", "implement AJA-123", or a list of file names.

Write for a reviewer who has not followed the implementation conversation.
Explain unfamiliar terms on first use, link decision IDs to their source, and
remove sections that genuinely do not apply instead of repeating information.
-->

## Reviewer summary

### Why

What problem or missing capability prompted this change?

### Outcome

What will be possible or observably different after this PR is merged?

### Out of scope

What might look related but is deliberately not changed here?

## Decision requested

State exactly what the reviewer is being asked to approve. List any separate
human action that must happen after merge. Write `No additional decision` when
the acceptance criteria already define the decision completely.

## Tracking and design context

- Linear issue: link the approved issue.
- Approved design: link the PRD, HLD, LLD, ADR, or baseline section used.
- Decisions affected: explain each relevant decision in plain language and link
  its ID to the source. Do not provide unexplained ID lists.

## Change map

| Area | What changed | Why it changed |
|---|---|---|
| `path/or/component` | Concise behavior-level description | Connection to the requested outcome |

## Suggested review order

| Step | File or artifact | What to verify |
|---|---|---|
| 1 | Most important contract or behavior | The key reviewer question |

## Acceptance criteria and evidence

| Acceptance criterion | Implementation | Evidence |
|---|---|---|
| Criterion from the Linear issue | File, behavior, or artifact that satisfies it | Test, command result, screenshot, or document section |

## Verification performed

| Check | Result |
|---|---|
| Exact command, test, or inspection | Pass/fail plus the meaningful observed result |

Include screenshots or video for visible UI changes. Do not claim a check that
was not run.

## Risk and impact

| Dimension | Material impact and mitigation |
|---|---|
| Security | Impact, mitigation, or `None` |
| Privacy/data | Impact, mitigation, or `None` |
| Cost | Impact, mitigation, or `None` |
| Operations/observability | Impact, mitigation, or `None` |
| Compatibility | Impact, mitigation, or `None` |

## Limitations and follow-up

List known limitations and separately tracked follow-up work, or write `None`.

## Rollback

Explain how to disable or reverse the change safely and how to verify rollback.

## Handoff checklist

- [ ] The title describes the outcome, not the implementation activity.
- [ ] The summary can be understood without reading the Linear discussion.
- [ ] The requested reviewer decision and post-merge actions are explicit.
- [ ] The suggested review order starts with the highest-risk contract.
- [ ] Every acceptance criterion maps to implementation and evidence.
- [ ] Required tests pass, documentation is current, and limitations are honest.
- [ ] No secrets, private data, unsupported claims, or stale status remain.
- [ ] No production credential, deployment, merge, or other human-only action was performed.
- [ ] The PR is not marked ready until automated checks and this review packet are complete.

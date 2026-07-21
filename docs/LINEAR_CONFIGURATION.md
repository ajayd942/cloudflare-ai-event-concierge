# Linear Configuration

Status: Configured for design work; no implementation issues have been created.

This document records non-secret Linear identifiers required by the Symphony runner. The Linear personal API key remains in macOS Keychain under the service name `symphony-linear-api-key` and must never be committed.

## Workspace resources

| Resource | Value |
|---|---|
| Workspace slug | `ajayd94` |
| Team | `Ajayd94` (`AJA`) |
| Team ID | `703a5d53-5b9a-4395-ac7c-ece980e71996` |
| Human reviewer ID | `65c7a930-259a-42c5-b166-424290a77605` |
| Project | [Cloudflare AI Event Concierge](https://linear.app/ajayd94/project/cloudflare-ai-event-concierge-eefcc601d728) |
| Project ID | `91fc2e9f-ce22-45cb-bb9c-bddae84d1c0e` |

## Workflow states

| State | Type | ID |
|---|---|---|
| `Inbox` | backlog | `f283ff85-e10b-425c-9b4c-aca2de94a74c` |
| `Discovery` | started | `0d16796f-7f9f-4cf6-a060-7c2402bfc079` |
| `Design Review` | started | `0922ca65-4fc0-4411-94a8-ab3bfe6b81a5` |
| `Ready for Planning` | unstarted | `d338925a-87aa-40d0-bdbd-e4d615e65c0b` |
| `Plan Review` | started | `c53551b6-9143-4ade-b5e4-94a6485ea354` |
| `Ready for Agent` | unstarted | `962de297-d52b-4323-a421-197fdffd7596` |
| `In Progress` | started | `67d69005-0b89-4401-85b9-a12c94dbbb1a` |
| `Agent QA` | started | `e6dde4d7-1708-423f-bb1d-0bdab62e8e74` |
| `Human Review` | started | `45a6dfc4-efef-4643-b1c2-0af96bf8052e` |
| `Ready to Merge` | started | `6b9a79a5-daca-49d0-a044-2f76d489f6c4` |
| `Done` | completed | `06444dbc-ff38-440e-a41a-0ccc2ce7efb5` |
| `Blocked` | started | `1f9cfd03-f777-47bd-a81e-fde2d11673ee` |
| `Needs Human Decision` | started | `39a56c9c-afbd-43a3-a20f-bdb061e6aa02` |
| `Rejected` | canceled | `1234adbf-9751-4057-8758-32ddd291d754` |

The default Linear states `Backlog`, `Todo`, `In Review`, `Canceled`, and `Duplicate` remain available for unrelated work. The pre-existing `xpenser` project and onboarding issue are outside this project's scope and were not modified.

## Control labels

| Label | ID |
|---|---|
| `human-only` | `7ff5dcd7-bebf-464c-97fc-5e8c3f4ba9ea` |
| `security-sensitive` | `4c2c5d46-174d-4bd2-ab49-d6e2d36f408c` |
| `production-change` | `e67b88c3-243a-4595-9a42-84e94950fab8` |
| `needs-human-decision` | `e1beccce-63b8-43a7-954f-b29b9f117e6e` |

## Runtime invariants

- Dispatch only issues in this project and in `Ready for Agent`.
- Reject dispatch when any human-control label is present.
- Set `Human Review` and the human reviewer ID in the same API update.
- Never move an issue to `Done`, merge a pull request, or perform a production change autonomously.
- Stop safely if a configured identifier no longer resolves to the expected name and type.

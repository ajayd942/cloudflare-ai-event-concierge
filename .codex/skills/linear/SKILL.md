---
name: linear
description: Use Symphony's injected linear_graphql tool for issue state, comments, relations, and PR attachments without exposing the tracker token.
---

# Linear operations

Use the `linear_graphql` tool injected by Symphony. Never retrieve, print, or store `LINEAR_API_KEY`.

## Rules

- Read the current issue, state, labels, relations, comments, and attachments before mutating it.
- Send one narrowly scoped GraphQL operation per tool call and treat any top-level `errors` array as failure.
- Use exactly one active comment headed `## Codex Workpad`; update it instead of creating progress-comment noise.
- Resolve workflow state IDs from the issue's team or `docs/LINEAR_CONFIGURATION.md`; do not guess IDs.
- Attach a GitHub PR with `attachmentLinkGitHubPR`.
- At handoff, set `stateId` and `assigneeId` together in one `issueUpdate` mutation.
- Never move an issue to `Done`; that is human-owned.

## Essential operations

Read an issue:

```graphql
query Issue($id: String!) {
  issue(id: $id) {
    id identifier title description url
    state { id name type }
    project { id name }
    team { id name }
    labels { nodes { id name } }
    comments { nodes { id body resolvedAt } }
    attachments { nodes { id title url sourceType } }
    relations { nodes { id type relatedIssue { id identifier state { name type } } } }
    inverseRelations { nodes { id type issue { id identifier state { name type } } } }
  }
}
```

Create or update the workpad:

```graphql
mutation CreateComment($issueId: String!, $body: String!) {
  commentCreate(input: { issueId: $issueId, body: $body }) {
    success
    comment { id url }
  }
}
```

```graphql
mutation UpdateComment($id: String!, $body: String!) {
  commentUpdate(id: $id, input: { body: $body }) {
    success
    comment { id body }
  }
}
```

Move state and assign the human atomically:

```graphql
mutation Handoff($id: String!, $stateId: String!, $assigneeId: String!) {
  issueUpdate(id: $id, input: { stateId: $stateId, assigneeId: $assigneeId }) {
    success
    issue { id identifier state { id name } assignee { id name } }
  }
}
```

Attach a PR:

```graphql
mutation AttachPR($issueId: String!, $url: String!, $title: String) {
  attachmentLinkGitHubPR(issueId: $issueId, url: $url, title: $title, linkKind: links) {
    success
    attachment { id title url }
  }
}
```

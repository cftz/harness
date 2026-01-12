---
name: linear-comment
description: "Manage Linear issue comments - list and create.\n\nCommands:\n  list ISSUE_ID=<id> - List comments for an issue\n  create ISSUE_ID=<id> BODY=\"...\" - Create a comment\n\nExamples:\n  /linear-comment list ISSUE_ID=TA-123\n  /linear-comment create ISSUE_ID=TA-123 BODY=\"Review completed.\""
user-invocable: false
---

# Linear Comment Skill

Manage Linear issue comments via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `list` | List comments for an issue | `{baseDir}/references/list.md` |
| `create` | Create a comment | `{baseDir}/references/create.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

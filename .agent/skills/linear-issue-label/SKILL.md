---
name: linear-issue-label
description: "List Linear issue labels.\n\nCommands:\n  list [TEAM_ID=...] - List labels for a team (defaults to linear-current team)\n\nExamples:\n  /linear-issue-label list\n  /linear-issue-label list TEAM_ID=abc-123"
user-invocable: false
---

# Linear Issue Label Skill

List Linear issue labels via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `list` | List all issue labels | `{baseDir}/references/list.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

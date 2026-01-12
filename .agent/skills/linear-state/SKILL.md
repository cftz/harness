---
name: linear-state
description: "List Linear workflow states for a team.\n\nCommands:\n  list [TEAM_ID=<id>] [ISSUE_ID=<id>] [NAME=<name>] - List workflow states\n\nExamples:\n  /linear-state list\n  /linear-state list TEAM_ID=abc-123\n  /linear-state list ISSUE_ID=TA-123\n  /linear-state list ISSUE_ID=TA-123 NAME=Todo"
user-invocable: false
---

# Linear State Skill

List Linear workflow states via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `list` | List workflow states for a team | `{baseDir}/references/list.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

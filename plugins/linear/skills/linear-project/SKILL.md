---
name: linear-project
description: "List Linear projects.\n\nCommands:\n  list [TEAM_ID=...] - List projects, optionally filtered by team\n\nExamples:\n  /linear-project list\n  /linear-project list TEAM_ID=abc-123"
user-invocable: false
---

# Linear Project Skill

List Linear projects via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `list` | List all projects | [{baseDir}/references/list.md]({baseDir}/references/list.md) |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

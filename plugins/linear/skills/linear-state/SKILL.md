---
name: linear-state
description: |
  Use this skill to get workflow state IDs for Linear issues. Required when updating issue states.

  Commands:
    list [TEAM_ID=<id>] [ISSUE_ID=<id>] [NAME=<name>] - List workflow states (defaults to linear-current team if neither provided)

  Examples:
    /linear-state list TEAM_ID=abc-123
    /linear-state list ISSUE_ID=TA-123
    /linear-state list ISSUE_ID=TA-123 NAME=Todo
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

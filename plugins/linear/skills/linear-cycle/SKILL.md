---
name: linear-cycle
description: |
  Use this skill to manage Linear cycles - get active cycle for a team or add issues to cycles.

  IMPORTANT: This skill is used by finalize-plan to automatically assign issues to the active cycle.

  Commands:
    get-active TEAM_ID=<id> - Get active cycle for a team
    add-issue ISSUE_ID=<id> CYCLE_ID=<id> - Add issue to a cycle

  Examples:
    /linear-cycle get-active TEAM_ID=uuid-123
    /linear-cycle add-issue ISSUE_ID=TA-123 CYCLE_ID=cycle-uuid
user-invocable: false
---

# Description

Manage Linear cycles via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `get-active` | Get active cycle for a team | `{baseDir}/references/get-active.md` |
| `add-issue` | Add issue to a cycle | `{baseDir}/references/add-issue.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

## Output

SUCCESS:
- **get-active**: JSON object with cycle info (`id`, `name`, `number`, `startsAt`, `endsAt`) or `null` if no active cycle
- **add-issue**: JSON object with `success` boolean and `issue` object containing cycle assignment

ERROR: Error message string (e.g., "TEAM_ID is required", "LINEAR_API_KEY environment variable is required")

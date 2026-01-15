---
name: linear-issue
description: |
  Use this skill to manage Linear issues - get, list, update, and create.

  Commands:
    get ID=<id> - Get issue details
    list [TEAM_ID=<id>] [PROJECT_ID=<id>] [STATE=<name>] [ASSIGNEE_ID=<id>] [PARENT_ID=<id>] [FIRST=<n>] - List issues
    update ID=<id> [STATE_ID=<id>] [TITLE="..."] [DESCRIPTION="..."] [ASSIGNEE_ID=<id>] [LABEL_IDS=<ids>] [ADD_LABEL_IDS=<ids>] [PRIORITY=<n>] [PROJECT_ID=<id>] - Update an issue
    create TITLE="..." [DESCRIPTION="..."] [PARENT=<id>] [BLOCKED_BY=<ids>] [TEAM=<name>] [PROJECT=<name>] [ASSIGNEE=<id>] [LABELS=<names>] [PRIORITY=<n>] [STATE_ID=<id>] [NO_CACHE=true] - Create issue with smart defaults and caching

  Examples:
    /linear-issue get ID=TA-123
    /linear-issue list STATE=Todo
    /linear-issue update ID=TA-123 STATE_ID=xyz789
    /linear-issue create TITLE="Fix bug"
    /linear-issue create TITLE="Sub-task" PARENT=TA-123 BLOCKED_BY="TA-100,TA-101"
user-invocable: false
---

# Linear Issue Skill

Manage Linear issues via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `get` | Get issue details | `{baseDir}/references/get.md` |
| `list` | List issues with filters | `{baseDir}/references/list.md` |
| `update` | Update an issue | `{baseDir}/references/update.md` |
| `create` | Create with smart defaults and caching | `{baseDir}/references/create.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

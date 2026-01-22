---
name: jira-issue
description: |
  Use this skill to manage Jira issues - get, list, update, and create.

  Commands:
    get ID=<key> - Get issue details
    list PROJECT=<key> [JQL="..."] [LIMIT=<n>] - List issues
    update ID=<key> [STATE=<name>] [ASSIGNEE=<id>] [SUMMARY="..."] [DESCRIPTION="..."] - Update an issue
    create PROJECT=<key> ISSUE_TYPE_ID=<id> TITLE="..." [ASSIGNEE=<id>] [COMPONENT=<name>] [PARENT=<key>] [DESCRIPTION="..."] [LABELS=<names>] - Create issue

  Examples:
    /jira-issue get ID=PROJ-123
    /jira-issue list PROJECT=PROJ JQL="status = 'To Do'"
    /jira-issue update ID=PROJ-123 STATE="In Progress"
    /jira-issue create PROJECT=PROJ ISSUE_TYPE_ID=10002 TITLE="Fix bug" ASSIGNEE=5c74dcae24a84d130780201b
user-invocable: false
---

# Description

Manage Jira issues via REST API. This skill uses issueType ID (not name) for issue creation, ensuring it works with localized Jira instances.

## Commands

| Command  | Description                    | Docs                              |
|----------|--------------------------------|-----------------------------------|
| `get`    | Get issue details              | `{baseDir}/references/get.md`     |
| `list`   | List issues with filters       | `{baseDir}/references/list.md`    |
| `update` | Update an issue                | `{baseDir}/references/update.md`  |
| `create` | Create issue with issueType ID | `{baseDir}/references/create.md`  |

## Environment Variables

- `JIRA_API_TOKEN` - Required for API authentication
- `JIRA_EMAIL` - Required for API authentication (Basic Auth)
- `JIRA_URL` - Required. Jira instance URL (e.g., https://company.atlassian.net)

## Key Differences from MCP

This skill uses **issueType ID** instead of name for issue creation:

```bash
# MCP (issue_type by name - fails with localized names)
mcp__jira__jira_create_issue(issue_type="작업")  # ❌ May fail

# jira-issue skill (issue_type by ID - always works)
/jira-issue create ISSUE_TYPE_ID=10002 ...  # ✅ Works
```

Use `project-manage metadata` to get available issue type IDs:
```json
{
  "issueTypes": [
    {"id": "10001", "name": "Task", "subtask": false},
    {"id": "10002", "name": "Bug", "subtask": false},
    {"id": "10003", "name": "Sub-task", "subtask": true}
  ]
}
```

# Output

SUCCESS:
- For `get`: Issue details as JSON
- For `list`: Array of issues matching criteria
- For `update`: Updated issue confirmation
- For `create`: Created issue key and URL

ERROR: Error message string (e.g., "Issue not found: PROJ-999")

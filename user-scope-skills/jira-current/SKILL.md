---
name: jira-current
description: |
  Use this skill to get the current Jira context (project, user) with read-through caching.

  Commands:
    project - Get current project
    user - Get current user

  Examples:
    /jira-current project
    /jira-current user
user-invocable: false
---

# Description

Get current Jira context (project, user) with read-through caching.

Uses a read-through cache pattern:
1. Check cache for value
2. If cache miss, fetch list and prompt user to select (or fetch from API)
3. Save selection to cache
4. Return cached value

# Parameters

## Required

- Command: One of `project` or `user`

# Commands

| Command   | Description          | Docs                            |
| --------- | -------------------- | ------------------------------- |
| `project` | Get current project  | `{baseDir}/references/project.md` |
| `user`    | Get current user     | `{baseDir}/references/user.md`    |

## Cache File Format

**Location:** `$PWD/.agent/cache/jira-current.json` (project-local)

```json
{
  "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
  "user": {"accountId": "xxx", "displayName": "User Name", "emailAddress": "user@example.com"}
}
```

## Output

SUCCESS:
- Returns JSON object with requested context field

ERROR: Error message string

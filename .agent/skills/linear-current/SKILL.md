---
name: linear-current
description: "Get current Linear context (team, project, user) with read-through caching.\n\nCommands:\n  project - Get current project\n  team - Get current team\n  user - Get current user (viewer)\n\nExamples:\n  /linear-current project\n  /linear-current team\n  /linear-current user"
user-invocable: false
---

# Linear Current Skill

Get current Linear context (team, project, user) with read-through caching.

Uses a read-through cache pattern:
1. Check cache for value
2. If cache miss, fetch list and prompt user to select
3. Save selection to cache
4. Return cached value

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `project` | Get current project | `{baseDir}/references/project.md` |
| `team` | Get current team | `{baseDir}/references/team.md` |
| `user` | Get current user | `{baseDir}/references/user.md` |

## Cache File Format

**Location:** `$PWD/.agent/cache/linear-current.json` (project-local)

```json
{
  "team": {"id": "uuid", "name": "Team Name"},
  "project": {"id": "uuid", "name": "Project Name"},
  "user": {"id": "uuid", "name": "User Name", "email": "user@example.com"}
}
```

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication (only for `user` command)

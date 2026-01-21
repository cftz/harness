---
name: project-manage
description: |
  Use this skill to manage project management system (PMS) context.

  IMPORTANT: This is the ONLY interface for accessing PMS context. Workflows and skills
  should call project-manage instead of linear-current or jira-current directly.
  This abstraction allows workflows to work without knowing which provider is used.

  Commands:
    init - Initialize PMS selection and project context
    provider - Get current PMS provider (linear/jira)
    project - Get current project info (normalized)
    user - Get current user info (normalized)
    metadata - Get project metadata (issue types, labels, components)

  All commands accept optional PROVIDER parameter:
    PROVIDER=linear|jira - If provided, use and cache this provider
                           If omitted, use cached or prompt user

  Examples:
    /project-manage init
    /project-manage provider
    /project-manage project
    /project-manage project PROVIDER=jira
    /project-manage user
    /project-manage metadata
user-invocable: true
---

# Description

Unified interface for managing project management system (PMS) context. Abstracts away the differences between Linear and Jira to provide a consistent API for other skills.

## Commands

| Command    | Description                                  | Docs                              |
| ---------- | -------------------------------------------- | --------------------------------- |
| `init`     | Initialize PMS selection and project context | `{baseDir}/references/init.md`    |
| `provider` | Get current PMS provider (linear/jira)       | `{baseDir}/references/provider.md`|
| `project`  | Get current project info                     | `{baseDir}/references/project.md` |
| `user`     | Get current user info                        | `{baseDir}/references/user.md`    |
| `metadata` | Get project metadata                         | `{baseDir}/references/metadata.md`|

## PROVIDER Parameter

All commands accept an optional `PROVIDER` parameter:

```
skill: project-manage
args: project PROVIDER=jira
```

### Resolution Logic

```
1. PROVIDER parameter provided?
   ├─ Yes → Use + save to cache → proceed
   └─ No  → Check cache
            ├─ Cache hit → Use cached value → proceed
            └─ Cache miss → AskUserQuestion → Cache selection → proceed
```

### Why This Matters

Workflows can pass through user-specified PROVIDER:

```python
# When clarify-workflow receives PROVIDER=jira
skill: project-manage
args: project PROVIDER=jira  # Pass through value from parent workflow

# When called without PROVIDER
skill: project-manage
args: project  # project-manage resolves via cache or inference
```

## Cache File Format

**Location:** `$PWD/.agent/cache/project-manage.json` (project-local)

```json
{
  "provider": "jira",
  "project": {
    "id": "10001",
    "key": "PROJ",
    "name": "Project Name"
  },
  "user": {
    "id": "xxx",
    "name": "User Name",
    "email": "user@example.com"
  },
  "metadata": {
    "issueTypes": [
      {"id": "10001", "name": "Task"},
      {"id": "10002", "name": "Bug"}
    ],
    "labels": ["frontend", "backend", "urgent"],
    "components": [
      {"id": "10001", "name": "API"},
      {"id": "10002", "name": "Web"}
    ]
  }
}
```

## Integration with Other Skills

**IMPORTANT**: Workflows should call `project-manage` instead of provider-specific skills directly.

### Before (provider-aware workflow)
```python
# Workflow has to know about providers
if provider == "linear":
    skill: linear:linear-current
    args: project
elif provider == "jira":
    skill: jira:jira-current
    args: project
```

### After (provider-agnostic workflow)
```python
# Workflow doesn't know or care about provider
skill: project-manage
args: project
# → Returns normalized {id, key, name} regardless of provider
```

### Parameter Resolution
```
# Before: explicit PROVIDER required
/implement-workflow ISSUE_ID=PROJ-123 PROVIDER=jira

# After: PROVIDER auto-resolved from project-manage
/implement-workflow ISSUE_ID=PROJ-123
```

## Normalized Data Model

project-manage normalizes provider-specific data into a consistent format:

### Project

| Field   | Linear Source     | Jira Source    |
| ------- | ----------------- | -------------- |
| `id`    | `id` (UUID)       | `id` (numeric) |
| `key`   | N/A (use name)    | `key`          |
| `name`  | `name`            | `name`         |

### User

| Field   | Linear Source     | Jira Source       |
| ------- | ----------------- | ----------------- |
| `id`    | `id` (UUID)       | `accountId`       |
| `name`  | `name`            | `displayName`     |
| `email` | `email`           | `emailAddress`    |

## Output

SUCCESS:
- Returns requested context as JSON

ERROR: Error message string (e.g., "PMS not initialized. Run /project-manage init first")

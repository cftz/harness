# Project Manage Skill

## Intent

**Provide the single abstraction layer for all PMS (Project Management System) operations.**

Workflows and skills should call `project-manage` instead of `linear-current` or `jira-current` directly. This allows workflows to be completely provider-agnostic - they don't need to know whether Linear or Jira is being used.

## Motivation

### The Problem

Without abstraction, every workflow needs provider-specific branching:

```python
# Every workflow repeats this pattern
if provider == "linear":
    result = skill("linear:linear-current", "project")
    project_id = result.id
elif provider == "jira":
    result = skill("jira:jira-current", "project")
    project_id = result.id
# ... more provider-specific handling
```

This creates:
- **Code duplication**: Same if/else in every workflow
- **Tight coupling**: Workflows know about Linear and Jira internals
- **Maintenance burden**: Adding a new provider requires updating all workflows
- **Inconsistent behavior**: Each workflow might handle edge cases differently

### The Solution

project-manage provides a unified interface:

```python
# Workflow is provider-agnostic
result = skill("project-manage", "project")
project_id = result.id  # Works for both Linear and Jira
```

## Design Decisions

- **Single entry point**: All PMS context access goes through project-manage
- **Provider abstraction**: Workflows never call linear-current or jira-current directly
- **Normalized data model**: Returns consistent `{id, key, name}` regardless of provider
- **Read-through cache**: Check cache first, prompt/fetch only on miss
- **Project-local cache**: Each project directory has its own PMS context

## Key Features

### 1. Provider-Agnostic Workflows

Workflows call project-manage and get normalized data:

| Command    | Returns                              |
| ---------- | ------------------------------------ |
| `provider` | `"linear"` or `"jira"`               |
| `project`  | `{id, key, name}`                    |
| `user`     | `{id, name, email}`                  |
| `metadata` | `{issueTypes, labels, components}`   |

### 2. One-Time Setup

Run `/project-manage init` once per project:
1. Select PMS (Linear or Jira)
2. Select project
3. Auto-fetch current user
4. All cached for future use

### 3. Automatic Resolution

When a workflow needs project info:
```
skill: project-manage
args: project

# Internally:
# 1. Check cache → hit? return immediately
# 2. Check provider cache → "jira"
# 3. Call jira:jira-current project
# 4. Normalize response
# 5. Cache and return
```

## Constraints

- This skill should NOT create or modify issues/projects
- This skill should NOT bypass the cache (except `init` which refreshes it)
- Workflows should NOT call linear-current or jira-current directly
- Cache invalidation requires re-running `init` or deleting cache file

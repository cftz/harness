---
name: linear-guide
description: |
  Behavioral guidelines for Linear tasks. You must follow these guidelines when working with Linear issues, documents, comments, etc.

  IMPORTANT: Always refer to these guidelines when performing Linear-related tasks.
user-invocable: false
---

# Linear Guide

Behavioral guidelines to follow when performing Linear-related tasks.

## Core Principles

### 1. Prioritize Skills Over MCP

When working with Linear, **you must use Skills over MCP**.

| Task | Skill to Use | MCP Usage Prohibited |
|------|-------------|----------------------|
| Issue get/create/update | `linear-issue` | linear MCP get/create/update |
| Document get/create/update | `linear-document` | linear MCP document |
| Comment list/create | `linear-comment` | linear MCP comment |
| Issue relation management | `linear-issue-relation` | linear MCP relation |
| Workflow state lookup | `linear-state` | linear MCP state |
| Team lookup | `linear-team` | linear MCP team |
| Project lookup | `linear-project` | linear MCP project |
| Label lookup | `linear-issue-label` | linear MCP label |
| Current context | `linear-current` | - |

**Exception**: MCP usage is only allowed for features not supported by Skills

### 2. Required Parameters for Issue List Queries

When fetching issue lists, **you must specify the following parameters**:

```
skill: linear-issue
args: list PROJECT_ID=<project_id> STATE=<state> FIRST=<limit>
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `PROJECT_ID` | **Yes** | Project ID or name |
| `STATE` | **Yes** | State filter (e.g., Todo, In Progress, Done) |
| `FIRST` | **Yes** | Maximum number to fetch (no default, must be specified) |

**Incorrect example:**
```
skill: linear-issue
args: list
```

**Correct example:**
```
skill: linear-issue
args: list PROJECT_ID=cops STATE=Todo FIRST=10
```

## Available Linear Skills

| Skill | Purpose |
|-------|---------|
| `linear-issue` | Issue CRUD (get, list, create, update) |
| `linear-document` | Document CRUD (get, list, search, create, update) |
| `linear-comment` | Comments (list, create) |
| `linear-issue-relation` | Issue relations (create, list, update, delete) |
| `linear-state` | Workflow state lookup |
| `linear-team` | Team list lookup |
| `linear-project` | Project list lookup |
| `linear-issue-label` | Label list lookup |
| `linear-current` | Current team/project/user context |

## Checklist

Before performing Linear tasks, verify:

- [ ] Is there a Skill that performs this task?
- [ ] When listing issues, are PROJECT_ID, STATE, and FIRST all specified?
- [ ] Is MCP usage unavoidable? (feature not supported by Skills)

# Linear Output Document

This document defines how to create Linear issues from clarified tasks.

## Input

- `PROJECT_ID` - Linear Project ID or name
- `DRAFT_PATHS` - Comma-separated list of temporary file paths from draft-clarify
- `ASSIGNEE` - (Optional) User to assign issues to (ID, name, email, or "me")
- `PARENT_ISSUE_ID` - (Optional) Parent issue ID for sub-issues

## Draft File Format

Each draft file should contain YAML frontmatter with task metadata:

```yaml
---
title: "Task Title"
description: |
  Task description in Markdown format.
dependencies:
  - task-name-1
  - task-name-2
---
```

The `dependencies` field lists other task names (not issue IDs) that must be completed first.

## Process

### Step 1: Resolve Defaults

Get current user for assignee if not provided:

```
skill: linear-current
args: user
```

### Step 2: Parse and Read Draft Files

1. Split `DRAFT_PATHS` by comma
2. Read each file and extract frontmatter:
   - `title` - Issue title
   - `description` - Issue description
   - `dependencies` - List of task names this depends on

3. Build a task map: `{task_name -> task_data}`

### Step 3: Determine Creation Order

Build a dependency graph and sort tasks topologically:
1. Tasks with no dependencies are created first
2. Tasks are created only after their dependencies

### Step 4: Create Issues

For each task in dependency order:

1. **Resolve blocking issue IDs**: Convert task names in `dependencies` to their created issue IDs
2. **Create the issue**:

```
skill: linear-issue
args: create TITLE="{title}" DESCRIPTION="{description}" PROJECT={PROJECT_ID} [PARENT={PARENT_ISSUE_ID}] [BLOCKED_BY="{blocking_ids}"] [ASSIGNEE={ASSIGNEE}]
```

3. **Record the created issue ID**: Map task name to issue identifier for dependency resolution

### Step 5: Report Results

List all created issues and their relationships.

## Example

```
Input:
  PROJECT_ID: cops
  DRAFT_PATHS: .agent/tmp/20260110-auth,.agent/tmp/20260110-api,.agent/tmp/20260110-deploy
  PARENT_ISSUE_ID: TA-100
  ASSIGNEE: me

Draft Files:
  .agent/tmp/20260110-auth:
    ---
    title: "Implement authentication"
    description: "Add JWT-based auth..."
    dependencies: []
    ---

  .agent/tmp/20260110-api:
    ---
    title: "Build API endpoints"
    description: "Create REST endpoints..."
    dependencies:
      - auth
    ---

  .agent/tmp/20260110-deploy:
    ---
    title: "Deploy to staging"
    description: "Configure deployment..."
    dependencies:
      - auth
      - api
    ---

Step 1 - Resolve defaults:
  skill: linear-current
  args: user
  -> user_id

Step 2 - Parse files:
  Task map:
    auth -> {title: "Implement authentication", deps: []}
    api -> {title: "Build API endpoints", deps: ["auth"]}
    deploy -> {title: "Deploy to staging", deps: ["auth", "api"]}

Step 3 - Dependency order:
  1. auth (no deps)
  2. api (deps: auth)
  3. deploy (deps: auth, api)

Step 4 - Create issues:

  Create auth:
    skill: linear-issue
    args: create TITLE="Implement authentication" DESCRIPTION="Add JWT-based auth..." PROJECT=cops PARENT=TA-100 ASSIGNEE=me
    -> Created TA-101

  Create api:
    skill: linear-issue
    args: create TITLE="Build API endpoints" DESCRIPTION="Create REST endpoints..." PROJECT=cops PARENT=TA-100 BLOCKED_BY="TA-101" ASSIGNEE=me
    -> Created TA-102

  Create deploy:
    skill: linear-issue
    args: create TITLE="Deploy to staging" DESCRIPTION="Configure deployment..." PROJECT=cops PARENT=TA-100 BLOCKED_BY="TA-101,TA-102" ASSIGNEE=me
    -> Created TA-103

Result:
  Issue map: {auth: TA-101, api: TA-102, deploy: TA-103}
```

## Output

```
Issues created:
- TA-101: Implement authentication
- TA-102: Build API endpoints
- TA-103: Deploy to staging

Blocking relationships:
- TA-102 blocked by TA-101
- TA-103 blocked by TA-101, TA-102

Parent issue: TA-100
```

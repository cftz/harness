# Linear Output Document

This document defines how to create Linear issues from prepared task data.

## Input (from SKILL.md)

- `PROJECT_ID` - Linear Project ID or name
- `TASK_MAP` - Parsed task data: `{task_name -> {title, description, blockedBy}}`
- `CREATION_ORDER` - Topologically sorted task names
- `ASSIGNEE` - Resolved user ID (from project-manage)
- `PARENT_ISSUE_ID` - (Optional) Parent issue ID for sub-issues

## Process

### Step 1: Create Issues

For each task in `CREATION_ORDER`:

1. **Resolve blocking issue IDs**: Convert task names in `blockedBy` to their created issue IDs
2. **Create the issue**:

```
skill: linear:linear-issue
args: create TITLE="{title}" DESCRIPTION="{description}" PROJECT={PROJECT_ID} [PARENT={PARENT_ISSUE_ID}] [BLOCKED_BY="{blocking_ids}"] [ASSIGNEE={ASSIGNEE}]
```

3. **Record the created issue ID**: Map task name to issue identifier for dependency resolution

### Step 2: Report Results

Return:
- `ISSUE_IDS`: Map of task names to created Linear issue IDs
- `BLOCKING_RELATIONS`: List of blocking relationships

## Example

```
Input (from SKILL.md):
  PROJECT_ID: cops
  TASK_MAP:
    auth -> {title: "Implement authentication", description: "Add JWT-based auth...", blockedBy: []}
    api -> {title: "Build API endpoints", description: "Create REST endpoints...", blockedBy: ["auth"]}
    deploy -> {title: "Deploy to staging", description: "Configure deployment...", blockedBy: ["auth", "api"]}
  CREATION_ORDER: ["auth", "api", "deploy"]
  ASSIGNEE: user-uuid-123
  PARENT_ISSUE_ID: TA-100

Step 1 - Create issues:

  Create auth (no blockedBy):
    skill: linear:linear-issue
    args: create TITLE="Implement authentication" DESCRIPTION="Add JWT-based auth..." PROJECT=cops PARENT=TA-100 ASSIGNEE=user-uuid-123
    -> Created TA-101

  Create api (blockedBy: auth -> TA-101):
    skill: linear:linear-issue
    args: create TITLE="Build API endpoints" DESCRIPTION="Create REST endpoints..." PROJECT=cops PARENT=TA-100 BLOCKED_BY="TA-101" ASSIGNEE=user-uuid-123
    -> Created TA-102

  Create deploy (blockedBy: auth, api -> TA-101, TA-102):
    skill: linear:linear-issue
    args: create TITLE="Deploy to staging" DESCRIPTION="Configure deployment..." PROJECT=cops PARENT=TA-100 BLOCKED_BY="TA-101,TA-102" ASSIGNEE=user-uuid-123
    -> Created TA-103

Step 2 - Report:
  ISSUE_IDS: {auth: TA-101, api: TA-102, deploy: TA-103}
  BLOCKING_RELATIONS:
    - TA-102 blocked by TA-101
    - TA-103 blocked by TA-101, TA-102
```

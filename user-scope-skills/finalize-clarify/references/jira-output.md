# Jira Output Document

This document defines how to create Jira issues from prepared task data using the `jira-issue` skill.

## Prerequisites

This document requires the `jira-issue` skill and Jira environment variables to be configured:
- `JIRA_API_TOKEN`
- `JIRA_EMAIL`
- `JIRA_URL`

## Input (from SKILL.md)

- `PROJECT_ID` - Jira Project key (e.g., `PROJ`, `OPS`)
- `TASK_MAP` - Parsed task data: `{task_name -> {title, description, blockedBy}}`
- `CREATION_ORDER` - Topologically sorted task names
- `ASSIGNEE` - User account ID (NOT email). From `project-manage user` result's `id` field.
- `PARENT_ISSUE_ID` - (Optional) Parent issue key for sub-tasks
- `METADATA` - Project metadata from `project-manage metadata`:
  - `issueTypes`: Array of `{id, name, subtask}` - available issue types
  - `components`: Array of `{id, name}` - available components
  - `defaultComponent`: Pre-selected default component name (may be null)

## Skills Used

| Skill | Purpose |
|-------|---------|
| `jira-issue` | Create new issues using issueType ID |

## MCP Tools Used (for linking only)

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_create_issue_link` | Create blocking relationships |

## Process

### Step 0: Determine Issue Type ID

Select the appropriate issue type **ID** from `METADATA.issueTypes`:

1. **If PARENT_ISSUE_ID is provided**: Use a sub-task type
   - Find issue type where `subtask: true`
   - Get its `id` (e.g., `"10003"`)

2. **If no parent (standalone issue)**: Use a regular task type
   - Find issue type where `subtask: false`
   - Prefer types named: "Task", "기타", "Story" (in that order)
   - Get its `id` (e.g., `"10001"`)

**Important**: Use the issue type **ID**, not name. This ensures issue creation works regardless of localized names.

### Step 1: Create Issues

For each task in `CREATION_ORDER`, use the `jira-issue` skill:

```
skill: jira-issue
args: create PROJECT={PROJECT_ID} ISSUE_TYPE_ID={issueTypeId} TITLE="{title}" DESCRIPTION="{description}" ASSIGNEE={ASSIGNEE} COMPONENT="{METADATA.defaultComponent}" PARENT={PARENT_ISSUE_ID}
```

Record the created issue key for dependency resolution.

**Notes:**
- `ISSUE_TYPE_ID`: Use the **id** from `METADATA.issueTypes` (Step 0), NOT the name
- `ASSIGNEE`: Must be account ID (e.g., "5c74dcae24a84d130780201b"), not email
- `COMPONENT`: Include if `METADATA.defaultComponent` is set
- `PARENT`: Include only if PARENT_ISSUE_ID is provided

### Step 2: Create Blocking Relationships

For each task that has `blockedBy`, create issue links using MCP:

```
mcp__jira__jira_create_issue_link(
    link_type="Blocks",
    inward_issue_key="{blocking_issue_key}",
    outward_issue_key="{blocked_issue_key}"
)
```

### Step 3: Report Results

Return:
- `ISSUE_IDS`: Map of task names to created Jira issue keys
- `BLOCKING_RELATIONS`: List of blocking relationships

## Example

```
Input (from SKILL.md):
  PROJECT_ID: MYPROJ
  TASK_MAP:
    auth -> {title: "Implement authentication", description: "Add JWT-based auth...", blockedBy: []}
    api -> {title: "Build API endpoints", description: "Create REST endpoints...", blockedBy: ["auth"]}
    deploy -> {title: "Deploy to staging", description: "Configure deployment...", blockedBy: ["auth", "api"]}
  CREATION_ORDER: ["auth", "api", "deploy"]
  ASSIGNEE: 5c74dcae24a84d130780201b  # account ID, NOT email
  PARENT_ISSUE_ID: MYPROJ-100
  METADATA:
    issueTypes:
      - {id: "10001", name: "기타", subtask: false}
      - {id: "10002", name: "하위 작업", subtask: true}
    components:
      - {id: "10001", name: "합성 패널"}
    defaultComponent: "합성 패널"

Step 0 - Determine issue type ID:
  PARENT_ISSUE_ID provided → Use subtask type
  Found: id="10002" (name="하위 작업", subtask: true)

Step 1 - Create issues using jira-issue skill:

  Create auth:
    skill: jira-issue
    args: create PROJECT=MYPROJ ISSUE_TYPE_ID=10002 TITLE="Implement authentication" DESCRIPTION="Add JWT-based auth..." ASSIGNEE=5c74dcae24a84d130780201b COMPONENT="합성 패널" PARENT=MYPROJ-100
    -> Created MYPROJ-101

  Create api:
    skill: jira-issue
    args: create PROJECT=MYPROJ ISSUE_TYPE_ID=10002 TITLE="Build API endpoints" DESCRIPTION="Create REST endpoints..." ASSIGNEE=5c74dcae24a84d130780201b COMPONENT="합성 패널" PARENT=MYPROJ-100
    -> Created MYPROJ-102

  Create deploy:
    skill: jira-issue
    args: create PROJECT=MYPROJ ISSUE_TYPE_ID=10002 TITLE="Deploy to staging" DESCRIPTION="Configure deployment..." ASSIGNEE=5c74dcae24a84d130780201b COMPONENT="합성 패널" PARENT=MYPROJ-100
    -> Created MYPROJ-103

Step 2 - Create blocking relationships:

  mcp__jira__jira_create_issue_link(
      link_type="Blocks",
      inward_issue_key="MYPROJ-101",
      outward_issue_key="MYPROJ-102"
  )
  -> MYPROJ-101 blocks MYPROJ-102

  mcp__jira__jira_create_issue_link(
      link_type="Blocks",
      inward_issue_key="MYPROJ-101",
      outward_issue_key="MYPROJ-103"
  )
  -> MYPROJ-101 blocks MYPROJ-103

  mcp__jira__jira_create_issue_link(
      link_type="Blocks",
      inward_issue_key="MYPROJ-102",
      outward_issue_key="MYPROJ-103"
  )
  -> MYPROJ-102 blocks MYPROJ-103

Step 3 - Report:
  ISSUE_IDS: {auth: MYPROJ-101, api: MYPROJ-102, deploy: MYPROJ-103}
  BLOCKING_RELATIONS:
    - MYPROJ-101 blocks MYPROJ-102
    - MYPROJ-101 blocks MYPROJ-103
    - MYPROJ-102 blocks MYPROJ-103
```

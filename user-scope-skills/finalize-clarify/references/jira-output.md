# Jira Output Document

This document defines how to create Jira issues from prepared task data using the MCP Atlassian server.

## Prerequisites

This document requires the `jira` MCP server to be configured. Verify with:

```
ListMcpResourcesTool(server="jira")
```

If not configured, return error:
```
STATUS: ERROR
OUTPUT: Jira MCP server is not configured. Add jira server to .mcp.json first.
```

## Input (from SKILL.md)

- `PROJECT_ID` - Jira Project key (e.g., `PROJ`, `OPS`)
- `TASK_MAP` - Parsed task data: `{task_name -> {title, description, blockedBy}}`
- `CREATION_ORDER` - Topologically sorted task names
- `ASSIGNEE` - Resolved user email or account ID (from project-manage)
- `PARENT_ISSUE_ID` - (Optional) Parent issue key for sub-tasks

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_create_issue` | Create new issues |
| `mcp__jira__jira_create_issue_link` | Create blocking relationships |

## Process

### Step 1: Create Issues

For each task in `CREATION_ORDER`:

```
mcp__jira__jira_create_issue(
    project_key="{PROJECT_ID}",
    summary="{title}",
    issue_type="Task",
    description="{description}",
    assignee="{ASSIGNEE}",  # if provided
    additional_fields={"parent": "{PARENT_ISSUE_ID}"}  # if PARENT_ISSUE_ID provided
)
```

Record the created issue key for dependency resolution.

### Step 2: Create Blocking Relationships

For each task that has `blockedBy`, create issue links:

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
  ASSIGNEE: user@example.com
  PARENT_ISSUE_ID: MYPROJ-100

Step 1 - Create issues:

  Create auth:
    mcp__jira__jira_create_issue(
        project_key="MYPROJ",
        summary="Implement authentication",
        issue_type="Task",
        description="Add JWT-based auth...",
        assignee="user@example.com",
        additional_fields={"parent": "MYPROJ-100"}
    )
    -> Created MYPROJ-101

  Create api:
    mcp__jira__jira_create_issue(
        project_key="MYPROJ",
        summary="Build API endpoints",
        issue_type="Task",
        description="Create REST endpoints...",
        assignee="user@example.com",
        additional_fields={"parent": "MYPROJ-100"}
    )
    -> Created MYPROJ-102

  Create deploy:
    mcp__jira__jira_create_issue(
        project_key="MYPROJ",
        summary="Deploy to staging",
        issue_type="Task",
        description="Configure deployment...",
        assignee="user@example.com",
        additional_fields={"parent": "MYPROJ-100"}
    )
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

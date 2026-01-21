# Jira Issue/Attachment Output (PROJECT_ID)

This document defines how to save problem solutions to a Jira project as either an Issue or an Attachment on a placeholder issue.

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

## Input

- `PROJECT_ID` - Jira Project key (e.g., `MYPROJ`)
- `DRAFT_PATH` - Temporary file from draft-problem-solution
- `NEW_ISSUE` - (Optional) `true` to create Issue (default), `false` to create placeholder issue with attachment

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_create_issue` | Create new issue |
| `mcp__jira__jira_update_issue` | Attach file to issue |
| `mcp__jira__jira_add_comment` | Add comment |

## Process

### 1. Read Draft File

Read the draft solution file and extract:
- Title from YAML frontmatter
- Problem statement
- Full content

### 2. Prepare Description/Content

For **Issue** creation (NEW_ISSUE=true):
- Use the problem statement as the issue description
- Include top recommendations in the description

For **Attachment** creation (NEW_ISSUE=false):
- First create a placeholder issue
- Then attach the full solution document

### 3. Create Issue or Attachment

**If NEW_ISSUE=true (default):**

Create an actionable issue for implementing the solution:

```
mcp__jira__jira_create_issue(
    project_key="{PROJECT_ID}",
    summary="[Ideation] {title from frontmatter}",
    issue_type="Task",
    description="{problem statement}\n\n## Top Recommendations\n{recommendations}"
)
```

**If NEW_ISSUE=false:**

First create a placeholder issue, then attach the document:

1. Create placeholder issue:
```
mcp__jira__jira_create_issue(
    project_key="{PROJECT_ID}",
    summary="[Solution] {title from frontmatter}",
    issue_type="Task",
    description="Solution document for: {problem statement}"
)
```

2. Attach document to the created issue:
```
mcp__jira__jira_update_issue(
    issue_key="{created_issue_key}",
    fields={},
    attachments="{DRAFT_PATH}"
)
```

## Example (Issue Creation)

```
Input:
  PROJECT_ID: MYPROJ
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: true (default)

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Create Issue:
  mcp__jira__jira_create_issue(
      project_key="MYPROJ",
      summary="[Ideation] State Synchronization Solutions",
      issue_type="Task",
      description="Problem: How to synchronize state across microservices\n\n## Top Recommendations\n1. Event Sourcing with Kafka\n2. CRDT-based approach"
  )
  -> Created MYPROJ-456

Result:
  Issue MYPROJ-456 created
```

## Example (Attachment Creation)

```
Input:
  PROJECT_ID: MYPROJ
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: false

Step 1 - Create placeholder issue:
  mcp__jira__jira_create_issue(
      project_key="MYPROJ",
      summary="[Solution] State Synchronization Solutions",
      issue_type="Task",
      description="Solution document for: How to synchronize state across microservices"
  )
  -> Created MYPROJ-457

Step 2 - Attach document:
  mcp__jira__jira_update_issue(
      issue_key="MYPROJ-457",
      fields={},
      attachments=".agent/tmp/xxxxxxxx-solution"
  )

Result:
  Issue MYPROJ-457 created with attached solution document
```

## Output

### For Issue (NEW_ISSUE=true)

SUCCESS:
- ISSUE_KEY: Created Jira issue key
- TITLE: Issue summary

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_KEY: MYPROJ-456
  TITLE: "[Ideation] State Synchronization Solutions"
```

### For Attachment (NEW_ISSUE=false)

SUCCESS:
- ISSUE_KEY: Created placeholder Jira issue key
- ATTACHMENT_NAME: Attached filename

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_KEY: MYPROJ-457
  ATTACHMENT_NAME: xxxxxxxx-solution
```

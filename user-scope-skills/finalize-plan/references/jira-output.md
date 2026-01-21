# Jira Output Document

This document defines how to save execution plans to Jira as an attachment on an issue.

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

- `ISSUE_ID` - Jira Issue key (e.g., `PROJ-123`)
- Temporary file from the previous step containing the execution plan

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_update_issue` | Attach file and optionally update issue |
| `mcp__jira__jira_add_comment` | Add comment with summary |

## Process

### 1. Read Draft File

Read the draft plan file and extract:
- Title from YAML frontmatter
- Full content for the attachment

### 2. Attach Plan File

Use the Jira MCP tool to attach the plan file to the issue:

```
mcp__jira__jira_update_issue(
    issue_key="{ISSUE_ID}",
    fields={},
    attachments="{DRAFT_PATH}"
)
```

### 3. Add Comment (Optional)

Add a comment summarizing that the plan has been attached:

```
mcp__jira__jira_add_comment(
    issue_key="{ISSUE_ID}",
    comment="[Plan] {title from frontmatter}\n\nExecution plan has been attached to this issue."
)
```

## Example

```
Input:
  ISSUE_ID: PROJ-123
  DRAFT_PATH: .agent/tmp/xxxxxxxx-plan

Draft frontmatter:
  ---
  title: API Implementation
  issueId: PROJ-123
  ---

Step 1 - Attach file:
  mcp__jira__jira_update_issue(
      issue_key="PROJ-123",
      fields={},
      attachments=".agent/tmp/xxxxxxxx-plan"
  )
  -> File attached as "xxxxxxxx-plan"

Step 2 - Add comment:
  mcp__jira__jira_add_comment(
      issue_key="PROJ-123",
      comment="[Plan] API Implementation\n\nExecution plan has been attached to this issue."
  )

Result:
  Plan file attached to PROJ-123
  Comment added with plan title
```

## Output

Return result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  ATTACHMENT_NAME: {attached filename}
  ISSUE_KEY: {issue_key}
```

Example:
```
STATUS: SUCCESS
OUTPUT:
  ATTACHMENT_NAME: xxxxxxxx-plan
  ISSUE_KEY: PROJ-123
```

If an error occurs:
```
STATUS: ERROR
OUTPUT: {error message describing what failed}
```

Notes:
- Attachment is visible in the Issue's Attachments section
- Comment provides context for the attached plan
- Unlike Linear, Jira doesn't have a native Document concept, so we use attachments

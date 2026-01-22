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

### 2. Prepare Attachment File

**IMPORTANT**: Do NOT attach the temporary file directly. Create a properly named file with `.md` extension.

1. Sanitize the title for filename use (replace spaces with hyphens, remove special characters)
2. Create attachment filename: `plan-{sanitized_title}.md`
3. Copy the draft file content to the new file path

```
# Example: title = "API Implementation"
# Sanitized: "api-implementation"
# Attachment filename: "plan-api-implementation.md"

cp {DRAFT_PATH} /tmp/plan-{sanitized_title}.md
```

### 3. Attach Plan File

Use the Jira MCP tool to attach the properly named plan file to the issue:

```
mcp__jira__jira_update_issue(
    issue_key="{ISSUE_ID}",
    fields={},
    attachments="/tmp/plan-{sanitized_title}.md"
)
```

### 4. Add Comment (Optional)

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

Step 1 - Read draft file:
  Extract title from frontmatter: "API Implementation"

Step 2 - Prepare attachment file:
  Title: "API Implementation"
  Sanitized: "api-implementation"
  Attachment path: /tmp/plan-api-implementation.md

  cp .agent/tmp/xxxxxxxx-plan /tmp/plan-api-implementation.md

Step 3 - Attach file:
  mcp__jira__jira_update_issue(
      issue_key="PROJ-123",
      fields={},
      attachments="/tmp/plan-api-implementation.md"
  )
  -> File attached as "plan-api-implementation.md"

Step 4 - Add comment:
  mcp__jira__jira_add_comment(
      issue_key="PROJ-123",
      comment="[Plan] API Implementation\n\nExecution plan has been attached to this issue."
  )

Result:
  Plan file "plan-api-implementation.md" attached to PROJ-123
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
  ATTACHMENT_NAME: plan-api-implementation.md
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

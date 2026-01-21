# Jira Document Output (ISSUE_ID)

This document defines how to save problem solutions as an attachment on an existing Jira issue.

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

- `ISSUE_ID` - Jira Issue key to attach the document to (e.g., `PROJ-123`)
- `DRAFT_PATH` - Temporary file from draft-problem-solution

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_update_issue` | Attach file to issue |
| `mcp__jira__jira_add_comment` | Add comment with summary |

## Process

### 1. Read Draft File

Read the draft solution file and extract:
- Title from YAML frontmatter
- Full content for the attachment

### 2. Attach File to Issue

Use the Jira MCP tool to attach the solution file to the issue:

```
mcp__jira__jira_update_issue(
    issue_key="{ISSUE_ID}",
    fields={},
    attachments="{DRAFT_PATH}"
)
```

### 3. Add Comment

Add a comment indicating the solution has been attached:

```
mcp__jira__jira_add_comment(
    issue_key="{ISSUE_ID}",
    comment="[Solution] {title from frontmatter}\n\nProblem solution document has been attached to this issue."
)
```

## Example

```
Input:
  ISSUE_ID: PROJ-123
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Step 1 - Attach file:
  mcp__jira__jira_update_issue(
      issue_key="PROJ-123",
      fields={},
      attachments=".agent/tmp/xxxxxxxx-solution"
  )
  -> File attached

Step 2 - Add comment:
  mcp__jira__jira_add_comment(
      issue_key="PROJ-123",
      comment="[Solution] State Synchronization Solutions\n\nProblem solution document has been attached to this issue."
  )

Result:
  Solution document attached to PROJ-123
```

## Output

SUCCESS:
- ATTACHMENT_NAME: Attached filename
- ISSUE_KEY: Jira issue key

Example:
```
STATUS: SUCCESS
OUTPUT:
  ATTACHMENT_NAME: xxxxxxxx-solution
  ISSUE_KEY: PROJ-123
```

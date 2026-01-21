# Jira Task Document

Instructions for loading plan and requirements from a Jira issue for implementation.

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

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_get_issue` | Fetch issue details |
| `mcp__jira__jira_download_attachments` | Download plan attachment |

## Process

### 1. Fetch Issue Details

```
mcp__jira__jira_get_issue(
    issue_key="{ISSUE_ID}"
)
```

### 2. Extract Requirements

From the response, extract:
- **Summary**: Issue title
- **Description**: Requirements and acceptance criteria

### 3. Find Plan Attachment

Look in the `attachment` field for plan documents:

1. Filter attachments by filename pattern: `*plan*.md` or `*Plan*.md`
2. If multiple matches, select the most recently uploaded one
3. If no plan attachment found, report error: "No plan attachment found for issue {ISSUE_ID}"

### 4. Download Plan Document

```
mcp__jira__jira_download_attachments(
    issue_key="{ISSUE_ID}",
    attachment_ids=["{plan_attachment_id}"],
    download_path=".agent/tmp"
)
```

### 5. Return Loaded Data

Provide the loaded data:

```
Plan:
  Source: Jira Attachment
  Issue Key: {ISSUE_ID}
  Attachment: {attachment_filename}
  Local Path: {downloaded_file_path}
  Content: {plan_content}

Requirements:
  Summary: {issue_summary}
  Description: {issue_description}
```

## Error Handling

- If issue does not exist: Report error "Issue not found: {ISSUE_ID}"
- If no plan attachment found: Report error "No plan attachment found for issue {ISSUE_ID}. Attach a plan document first."
- If attachment download fails: Report error with details

## Output

Plan and requirements loaded from the Jira issue, ready for implementation.

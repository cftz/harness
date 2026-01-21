# Jira Task Loading

Instructions for loading task source from Jira Issue.

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

## Process

### 1. Fetch Issue Details

```
mcp__jira__jira_get_issue(
    issue_key="{ISSUE_ID}"
)
```

### 2. Extract Information

From the response, extract:
- **Summary**: Use as task context (equivalent to Linear title)
- **Description**: Use as initial requirements text
- **Labels**: Note any relevant categorization
- **Components**: Additional categorization
- **Acceptance criteria**: If defined in description or custom field

### 3. Fetch Comments (Optional)

Comments are included in the issue response under the `comment` field. Parse the comments array for additional context.

## Output

Requirements gathered from the Jira issue, ready for the clarification process.

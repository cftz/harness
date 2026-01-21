# Jira Task Document

This document defines how to gather requirements from a Jira issue.

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

1. Use MCP to fetch issue details:
   ```
   mcp__jira__jira_get_issue(
       issue_key="{ISSUE_ID}"
   )
   ```

2. Extract the following information:
   - **Summary**: Issue title
   - **Description**: Detailed requirements
   - **Acceptance criteria**: If defined in description or custom field
   - **Labels**: Categorization
   - **Components**: Additional categorization
   - **Attachments**: Any attached documents (check for existing plan documents)

3. Comments are included in the issue response. Parse for additional context.

## Output

Requirements gathered from the Jira issue, ready for the planning process.

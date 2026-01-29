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

### 4. Parse Issue Links for Blocking Issues

From the `issuelinks` array in the response, filter links where:
- `type.name` is "Blocks" AND `inwardIssue` exists (meaning that issue blocks this one)
- OR `type.inward` contains "is blocked by"

### 5. Fetch Blocking Issue Context

For each blocking issue found in step 4:

1. **Fetch blocking issue details:**
   ```
   mcp__jira__jira_get_issue(
       issue_key="{blocking_issue_key}"
   )
   ```

2. **Check for Plan content:**
   - Look in attachments for Plan document
   - Check description for embedded plan information

**Edge Case Handling:**
- Process up to 5 blocking issues, ordered by status (In Progress > To Do > Done)
- If no Plan document exists, include issue description only with note "No plan document found"
- Detect circular dependencies (A blocks B, B blocks A) and skip with warning
- Only fetch direct blockers (depth=1), not transitive dependencies

### 6. Compile Output

Combine all gathered information for the clarification process.

## Output

Requirements gathered from the Jira issue, ready for the clarification process.

Include the following section if blocking issues exist:

```markdown
## Blocking Issue Context

### {BLOCKING_ISSUE_KEY}: {summary}
- **Status**: {status.name}
- **Description**: {description summary}
- **Plan Document**: {extracted interfaces/APIs if available, or "No plan document found"}
```

Repeat for each blocking issue (up to 5).

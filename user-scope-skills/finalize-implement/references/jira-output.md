# Jira Output

Instructions for updating Jira issue state after finalization.

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
- `target_state` - Target state name: "In Review" or "Done"

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_get_issue` | Fetch current issue state |
| `mcp__jira__jira_get_transitions` | Get available transitions |
| `mcp__jira__jira_transition_issue` | Update issue state |

## Process

### 1. Get Current Issue State

```
mcp__jira__jira_get_issue(
    issue_key="{ISSUE_ID}"
)
```

Extract the current status from `fields.status.name`.

### 2. Check If Update Needed

If current status == target state (case-insensitive):
- Log: "Issue already in {target_state}, skipping update"
- Return without updating

### 3. Get Available Transitions

```
mcp__jira__jira_get_transitions(
    issue_key="{ISSUE_ID}"
)
```

Find a transition that leads to the target state:
- Look for transition where `to.name` matches target state (case-insensitive)
- Common mappings:
  - "In Review" -> "In Review", "Code Review", "Review"
  - "Done" -> "Done", "Closed", "Resolved"

### 4. Transition Issue

```
mcp__jira__jira_transition_issue(
    issue_key="{ISSUE_ID}",
    transition_name="{transition_name}"
)
```

Or by ID:
```
mcp__jira__jira_transition_issue(
    issue_key="{ISSUE_ID}",
    transition_id="{transition_id}"
)
```

### 5. Return Result

Log: "Updated issue state to {target_state}"

Return the Jira issue URL for the final report:
- Format: `https://{jira-instance}/browse/{ISSUE_ID}`

## State Mapping

| Target State | Common Jira Equivalents |
|--------------|-------------------------|
| In Review | In Review, Code Review, Review, Peer Review |
| Done | Done, Closed, Resolved, Complete |

If exact match not found, look for transitions containing the target state keyword.

## Error Handling

- If issue does not exist: Report error "Issue not found: {ISSUE_ID}"
- If transition not available: Report "Cannot transition to '{target_state}'. Available transitions: {list}"
- If MCP call fails: Report error with details

## Output

Issue state updated successfully, ready for final report.

# Jira Document Output

Instructions for saving suggestions as an attachment on a Jira issue.

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

## When to Use

Use this reference when `ISSUE_ID` is provided with `PROVIDER=jira`.

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_update_issue` | Attach suggestions file to issue |
| `mcp__jira__jira_add_comment` | Add comment with summary |

## Process

### 1. Create Temporary File

First, create a temporary file to hold the suggestions content:

```
skill: mktemp
args: suggestions
```

Store the returned path in `temp_file_path`.

### 2. Write Suggestions Content

Write the suggestions document to `temp_file_path` using the Write tool.

The content should follow the output format defined in SKILL.md.

### 3. Attach File to Issue

Use the Jira MCP tool to attach the suggestions file to the issue:

```
mcp__jira__jira_update_issue(
    issue_key="{ISSUE_ID}",
    fields={},
    attachments="{temp_file_path}"
)
```

### 4. Add Comment to Issue

Add a comment summarizing the findings:

```
mcp__jira__jira_add_comment(
    issue_key="{ISSUE_ID}",
    comment="Improvement analysis completed for {TARGET}.\n\nFound {N} issues:\n- Critical: {X}\n- High: {Y}\n- Medium: {Z}\n- Low: {W}\n\nSee attached document for details."
)
```

### 5. Return Output

Report the result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  RESULT: COMPLETE
  ISSUES_COUNT: Critical={X}, High={Y}, Medium={Z}, Low={W}
  OUTPUT_PATH: Attachment on {ISSUE_ID}
```

## Example

```
Input:
  TARGET: repository
  ISSUE_ID: PROJ-123
  PROVIDER: jira

Execution:
  1. skill: mktemp
     args: suggestions
     -> Returns: .agent/tmp/20260117-143052-suggestions

  2. Write suggestions content to temp file

  3. mcp__jira__jira_update_issue(
         issue_key="PROJ-123",
         fields={},
         attachments=".agent/tmp/20260117-143052-suggestions"
     )
     -> Attaches document

  4. mcp__jira__jira_add_comment(
         issue_key="PROJ-123",
         comment="Improvement analysis completed for repository..."
     )
     -> Adds comment to PROJ-123

Output:
  STATUS: SUCCESS
  OUTPUT:
    RESULT: COMPLETE
    ISSUES_COUNT: Critical=1, High=5, Medium=3, Low=1
    OUTPUT_PATH: Attachment on PROJ-123
```

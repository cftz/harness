# Jira Output Document (Code Review)

This document defines how to save review results as an attachment on a Jira issue.

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
- Review result content (Pass or Changes Required)

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_update_issue` | Attach review file to issue |
| `mcp__jira__jira_add_comment` | Add comment with result summary |

## Process

### 1. Create Temporary File

First, create a temporary file to hold the review content:

```
skill: mktemp
args: review
```

Store the returned path in `temp_file_path`.

### 2. Write Review Content

Write the review document to `temp_file_path` using the Write tool.

The content should follow the output format defined in SKILL.md, formatted as Markdown:
- For Pass: List files reviewed and rules applied
- For Changes Required: Include violations table and acceptance criteria

### 3. Attach File to Issue

Use the Jira MCP tool to attach the review file to the issue:

```
mcp__jira__jira_update_issue(
    issue_key="{ISSUE_ID}",
    fields={},
    attachments="{temp_file_path}"
)
```

### 4. Add Comment with Summary

Add a comment summarizing the review result:

**For Pass:**
```
mcp__jira__jira_add_comment(
    issue_key="{ISSUE_ID}",
    comment="✅ Code Review: PASS\n\nAll changes follow project rules correctly. See attached review document for details."
)
```

**For Changes Required:**
```
mcp__jira__jira_add_comment(
    issue_key="{ISSUE_ID}",
    comment="⚠️ Code Review: CHANGES REQUIRED\n\n{N} violation(s) found. See attached review document for details and required fixes."
)
```

## Example

```
Input:
  ISSUE_ID: PROJ-123
  Review Status: Changes Required
  Violations: 3

Execution:
  1. skill: mktemp
     args: review
     -> Returns: .agent/tmp/20260110-143052-review

  2. Write review content to temp file

  3. mcp__jira__jira_update_issue(
         issue_key="PROJ-123",
         fields={},
         attachments=".agent/tmp/20260110-143052-review"
     )
     -> Attaches review document

  4. mcp__jira__jira_add_comment(
         issue_key="PROJ-123",
         comment="⚠️ Code Review: CHANGES REQUIRED\n\n3 violation(s) found. See attached review document for details and required fixes."
     )
     -> Adds comment to PROJ-123

Result:
  Review document attached to PROJ-123
  Comment added with review summary
```

## Output

Return result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  RESULT: PASS or CHANGES_REQUIRED
  REVIEW_PATH: Attachment on {ISSUE_ID}
```

Example:
```
STATUS: SUCCESS
OUTPUT:
  RESULT: CHANGES_REQUIRED
  REVIEW_PATH: Attachment on PROJ-123
```

If an error occurs:
```
STATUS: ERROR
OUTPUT: {error message describing what failed}
```

Notes:
- Attachment is visible in the Issue's Attachments section
- Comment provides quick summary without opening the attachment
- Unlike Linear Documents, Jira attachments are simple files

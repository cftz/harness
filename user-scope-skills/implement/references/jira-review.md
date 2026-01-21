# Jira Review Document

Instructions for fetching a Review attachment from Jira when using `ISSUE_ID` without explicit `REVIEW_PATH`.

## Prerequisites

This document requires the `jira` MCP server to be configured.

## Input

- `ISSUE_ID` - Jira Issue key (e.g., `PROJ-123`)

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_get_issue` | Fetch issue details with attachments |
| `mcp__jira__jira_download_attachments` | Download review attachment |

## Process

### 1. List Attachments on Issue

```
mcp__jira__jira_get_issue(
    issue_key="{ISSUE_ID}"
)
```

Extract the `attachment` field from the response.

### 2. Identify Review Document

From the attachments, find the Review Document by filtering:

1. **Filename Pattern**: Attachment filename contains "review" or "Review"
2. **Content Pattern**: If multiple matches, look for files containing "Status: Changes Required"

If multiple Review Documents exist, select the **most recently uploaded** one.

### 3. Download Review Content

```
mcp__jira__jira_download_attachments(
    issue_key="{ISSUE_ID}",
    attachment_ids=["{review_attachment_id}"],
    download_path=".agent/tmp"
)
```

### 4. Parse Review Structure

The Review Document follows this structure:

```markdown
# Review Result

**Status**: Changes Required

## Request Summary
[Brief description of what needs to be fixed]

## Acceptance Criteria
- [ ] [Specific fix for violation 1]
- [ ] [Specific fix for violation 2]

## Scope
### In Scope
- Fix identified rule violations

### Out of Scope
- Any other refactoring or improvements

## Violations Found
| File | Line | Rule | Issue | Suggested Fix |
| ... | ... | ... | ... | ... |

## Rules References
- [Rule files that were applied]
```

Extract:
- **Acceptance Criteria**: The checklist of fixes to implement
- **Violations Found**: The detailed table of issues with file:line references
- **Rules References**: The rule files to read for context

## Error Handling

- If no attachments on issue: Report error "No attachments found on issue {ISSUE_ID}"
- If no Review attachment found: Report error "No Review attachment found for issue {ISSUE_ID}. Run code-review first."
- If Review status is "Pass": Report "Review status is Pass. No fixes required."

## Output

Review document loaded from Jira, ready for fix implementation.

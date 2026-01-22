# Linear Output Document

This document defines how to save execution plans to Linear as a Document attached to the Issue.

## Input

- `ISSUE_ID` - Issue ID from plan input (required for Linear output)
- Temporary file from the previous step containing the execution plan

## Process

### 1. Create Document

Use the `linear-document` skill's `create` command to attach the plan as a Document to the Issue:

```
skill: linear:linear-document
args: create TITLE="[Plan] {title from frontmatter}" CONTENT_FILE={temp_file_path} ISSUE_ID={ISSUE_ID}
```

## Example

```
Input:
  ISSUE_ID: TA-123
  Temp file: .agent/tmp/xxxxxxxx-plan

Step 1 - Create Document:
  skill: linear:linear-document
  args: create TITLE="[Plan] API Implementation" CONTENT_FILE=.agent/tmp/xxxxxxxx-plan ISSUE_ID=TA-123

Result:
  Document "[Plan] API Implementation" attached to TA-123
```

## Output

Return result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  DOCUMENT_URL: {document_url}
  ISSUE_ID: {issue_id}
```

Example:
```
STATUS: SUCCESS
OUTPUT:
  DOCUMENT_URL: https://linear.app/team/document/abc123
  ISSUE_ID: TA-123
```

If an error occurs:
```
STATUS: ERROR
OUTPUT: {error message describing what failed}
```

Notes:
- Document URL is visible in the Issue's Resources section
- Issue status update is handled by the common logic in SKILL.md

# Linear Output Document (Code Review)

This document defines how to save review results as a Linear document attached to an issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
- Review result content (Pass or Changes Required)

## Process

### 0. Create Temporary File

First, create a temporary file to hold the review content:

```
skill: mktemp
args: review
```

Store the returned path in `temp_file_path`.

### 1. Create Linear Document

Use the `linear-document` skill to create a new document attached to the issue:

```
skill: linear-document
args: create TITLE="Code Review - {ISSUE_ID}" ISSUE_ID={ISSUE_ID} CONTENT_FILE={temp_file_path}
```

### 2. Format Review Content

The content should follow the output format defined in SKILL.md, formatted as Markdown:
- For Pass: List files reviewed and rules applied
- For Changes Required: Include violations table and acceptance criteria

### 3. Update Issue (if Changes Required)

If the review status is "Changes Required":

1. Add a comment to the issue summarizing the violations:
   ```
   skill: linear-comment
   args: create ISSUE_ID={ISSUE_ID} BODY="Code review completed with violations found. See attached document for details."
   ```

2. Optionally update issue labels to indicate review status

### 4. Notify User

- Inform user of the review result
- Provide link to the created document
- If Changes Required, summarize key violations

## Example

```
Input:
  ISSUE_ID: TA-123
  Review Status: Changes Required

Execution:
  0. skill: mktemp
     args: review
     -> Returns: .agent/tmp/20260110-143052-review

  1. skill: linear-document
     args: create TITLE="Code Review - TA-123" ISSUE_ID=TA-123 CONTENT_FILE=.agent/tmp/20260110-143052-review
     -> Creates document with review content

  2. skill: linear-comment
     args: create ISSUE_ID=TA-123 BODY="Code review completed..."
     -> Adds comment to TA-123

Result:
  Document created and linked to TA-123
  Review URL: https://linear.app/team/document/...
```

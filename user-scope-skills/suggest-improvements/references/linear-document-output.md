# Linear Document Output

Instructions for saving suggestions as a Linear document attached to an issue.

## When to Use

Use this reference when `ISSUE_ID` is provided.

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

### 3. Create Linear Document

Use the `linear-document` skill to create a new document attached to the issue:

```
skill: linear:linear-document
args: create TITLE="Improvement Suggestions - {TARGET}" ISSUE_ID={ISSUE_ID} CONTENT_FILE={temp_file_path}
```

### 4. Add Comment to Issue

Add a comment summarizing the findings:

```
skill: linear:linear-comment
args: create ISSUE_ID={ISSUE_ID} BODY="Improvement analysis completed. Found {N} issues. See attached document for details."
```

### 5. Return Output

Report the result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  RESULT: COMPLETE
  ISSUES_COUNT: Critical={X}, High={Y}, Medium={Z}, Low={W}
  OUTPUT_PATH: Linear Document attached to {ISSUE_ID}
```

## Example

```
Input:
  TARGET: repository
  ISSUE_ID: TA-123

Execution:
  1. skill: mktemp
     args: suggestions
     -> Returns: .agent/tmp/20260117-143052-suggestions

  2. Write suggestions content to temp file

  3. skill: linear:linear-document
     args: create TITLE="Improvement Suggestions - repository" ISSUE_ID=TA-123 CONTENT_FILE=.agent/tmp/20260117-143052-suggestions
     -> Creates document attached to TA-123

  4. skill: linear:linear-comment
     args: create ISSUE_ID=TA-123 BODY="Improvement analysis completed..."
     -> Adds comment to TA-123

Output:
  STATUS: SUCCESS
  OUTPUT:
    RESULT: COMPLETE
    ISSUES_COUNT: Critical=1, High=5, Medium=3, Low=1
    OUTPUT_PATH: Linear Document attached to TA-123
```

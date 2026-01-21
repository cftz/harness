# Linear Task Document (Code Review)

This document defines how to load review context from a Linear issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

## Process

### 1. Fetch Issue Details

Use the `linear-issue` skill to get the issue information:

```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

Extract:
- Title
- Description
- Labels
- Attachments (document links)

### 2. Find Attached Documents

Look for attached documents that contain task or plan information:

1. Check issue attachments for document links
2. Use the `linear-document` skill to find documents associated with the issue:

```
skill: linear:linear-document
args: list ISSUE_ID={ISSUE_ID}
```

Look for documents with titles containing:
- "Task" or "Requirements"
- "Plan" or "Implementation"

### 3. Load Document Contents

For each relevant document found, use the `linear-document` skill:

```
skill: linear:linear-document
args: get ID={document_id}
```

Read the document content to understand:
- What was originally requested (task/requirements document)
- What was planned to be implemented (plan document)

### 4. Extract Target Files

From the plan document, extract the list of files that were supposed to be modified:
- Look for "Files to modify" sections
- Find file paths in code blocks
- Check implementation steps for file references

## Output

After reading the issue and documents, you should have:
- **Original requirements**: From issue description or task document
- **Implementation plan**: From plan document (if exists)
- **Target file list**: Files that should have been changed

## Example

```
ISSUE_ID: TA-123

Issue: "Add user authentication"
  - Description: Implement JWT-based auth...
  - Attachments: [doc-456, doc-789]

Document doc-456 (Task):
  - Acceptance criteria
  - Scope definition

Document doc-789 (Plan):
  - Target files: internal/service/auth.go
  - Implementation steps
```

Use this context to guide your code review, ensuring the implementation matches the original plan.

# Linear Document Output (ISSUE_ID)

This document defines how to save problem solutions as a Linear Document attached to an existing issue.

## Input

- `ISSUE_ID` - Linear Issue ID to attach the document to (e.g., `TA-123`)
- `DRAFT_PATH` - Temporary file from draft-problem-solution

## Process

### 1. Read Draft File

Read the draft solution file and extract:
- Title from YAML frontmatter
- Full content for the document body

### 2. Create Document

Use the `linear:linear-document` skill's `create` command to attach the solution as a Document to the Issue:

```
skill: linear:linear-document
args: create TITLE="[Solution] {title from frontmatter}" CONTENT_FILE={DRAFT_PATH} ISSUE_ID={ISSUE_ID}
```

## Example

```
Input:
  ISSUE_ID: TA-123
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Step 1 - Create Document:
  skill: linear:linear-document
  args: create TITLE="[Solution] State Synchronization Solutions" CONTENT_FILE=.agent/tmp/xxxxxxxx-solution ISSUE_ID=TA-123

Result:
  Document "[Solution] State Synchronization Solutions" attached to TA-123
```

## Output

SUCCESS:
- DOCUMENT_URL: Created document URL
- ISSUE_ID: Issue the document was attached to

Example:
```
STATUS: SUCCESS
OUTPUT:
  DOCUMENT_URL: https://linear.app/team/document/xxx
  ISSUE_ID: TA-123
```

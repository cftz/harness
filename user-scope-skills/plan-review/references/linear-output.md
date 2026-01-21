# Linear Output Document (Plan Review)

This document defines how to save review results as a Linear document attached to the issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
- Temporary file containing the review result
- Review status: "Approved" or "Revision Needed"

## Process

### 1. Check for Existing Review Document

Query the issue to find existing Plan Review document:

```
skill: linear-issue
args: get ID={ISSUE_ID}
```

From the `documents` array, find a document with title starting with `[Plan Review]`:

```json
"documents": [
  {"id": "doc-123", "title": "[Plan] Add user authentication"},
  {"id": "doc-456", "title": "[Plan Review] TA-123"}
]
```

### 2. Create or Update Review Document

**If existing `[Plan Review]` document found:**

Use the `linear-document` skill's `update` command:

```
skill: linear-document
args: update ID={existing_doc_id} CONTENT_FILE={temp_file_path}
```

**If no `[Plan Review]` document exists:**

Use the `linear-document` skill's `create` command:

```
skill: linear-document
args: create TITLE="[Plan Review] {ISSUE_ID}" CONTENT_FILE={temp_file_path} ISSUE_ID={ISSUE_ID}
```

### 3. Update Issue Labels (Optional)

Consider adding labels to indicate review status using the `linear-issue` skill:

**If Approved:**
```
skill: linear-issue
args: update ID={ISSUE_ID} ADD_LABEL_IDS=plan-approved-label-id
```

**If Revision Needed:**
```
skill: linear-issue
args: update ID={ISSUE_ID} ADD_LABEL_IDS=plan-needs-revision-label-id
```

> **Note**: To get label IDs:
> ```
> skill: linear-issue-label
> args: list
> ```
> Use the returned `id` value (not the label name) for `ADD_LABEL_IDS`.

### 4. Notify User

- Inform user of the review result
- Provide link to the review document
- If Revision Needed, summarize key violations

## Example

```
Input:
  ISSUE_ID: TA-123
  Review Status: Revision Needed
  Temp file: .agent/tmp/plan-review.xxxxxxxx

Execution:
  1. skill: linear-issue
     args: get ID=TA-123
     -> documents: [
          {"id": "doc-123", "title": "[Plan] Add user authentication"},
          {"id": "doc-456", "title": "[Plan Review] TA-123"}
        ]
     -> Found existing review document: doc-456

  2. skill: linear-document
     args: update ID=doc-456 CONTENT_FILE=.agent/tmp/plan-review.xxxxxxxx
     -> Updates existing review document

  3. skill: linear-issue
     args: update ID=TA-123 ADD_LABEL_IDS=revision-label-id
     -> Updates issue labels

Output:
  Review document updated: [Plan Review] TA-123
  Issue labeled: plan-needs-revision
```

## Document Structure

Each Issue maintains a single Plan and Plan Review document:

```
Issue (TA-123)
├── [Plan] Add User Authentication   <- One plan document (updated on revisions)
└── [Plan Review] TA-123             <- One review document (overwritten each review)
```

## Output

- Link to the created/updated Linear review document
- Updated issue labels

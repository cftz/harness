# Linear Task Document (Plan Review)

This document defines how to load a plan and task document from a Linear issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

## Process

### 1. Fetch Issue Details

Use the `linear-issue` skill to get the issue information:

```
skill: linear-issue
args: get ID={ISSUE_ID}
```

Extract:
- Title
- **Description** (this is the Task document containing requirements)
- Documents array (linked documents)

### 2. Extract Task Document

The Issue Description contains the Task document (requirements) from clarify stage:
- Task Summary
- Acceptance Criteria
- Scope (In Scope / Out of Scope)
- Constraints

Store this as the Task document for Task Alignment Review in Step 5.

### 3. Find Plan Document

From the issue's `documents` array, look for documents with titles containing:
- "Plan"
- "Implementation"
- "Design"

Example documents array:
```json
"documents": [{"id": "doc-456", "title": "[Plan] Add user authentication"}]
```

### 4. Load Plan Document Content

Use the `linear-document` skill to get the plan content:

```
skill: linear-document
args: get ID={document_id}
```

### 5. Parse Plan Content

From the document content, extract:
- Title (from document title or first heading)
- Issue ID (from frontmatter or use input ISSUE_ID)
- Implementation Steps
- Summary of Changes
- Target file list

## Output

After reading the issue and documents, you should have:

- **Task document**: Issue Description (requirements from clarify)
- **Plan document**: Full content from Linear document
- **Issue context**: Title from the issue
- **Target file list**: Files mentioned in the plan

## Example

```
ISSUE_ID: TA-123

Issue: "Add user authentication"
  - Description: (Task document)
    # Task Summary
    Implement JWT-based authentication...

    # Acceptance Criteria
    - [ ] User can login with email/password
    - [ ] JWT token is returned on success
    ...

    # Scope
    ## In Scope
    - Login endpoint
    ...

  - documents: [{"id": "doc-456", "title": "[Plan] Add user authentication"}]

Document doc-456 (Plan):
  - Title: [Plan] Add user authentication
  - Content: Implementation steps...

Extracted:
- Task document: Issue Description (for Task Alignment Review)
- Plan document: doc-456 content
- Target files: internal/service/auth/auth.go, etc.
```

# Linear Issue/Document Output (PROJECT_ID)

This document defines how to save problem solutions to a Linear project as either an Issue or a Document.

## Input

- `PROJECT_ID` - Linear Project ID or name
- `DRAFT_PATH` - Temporary file from draft-problem-solution
- `NEW_ISSUE` - (Optional) `true` to create Issue (default), `false` to create Document attached to a placeholder Issue

## Process

### 1. Read Draft File

Read the draft solution file and extract:
- Title from YAML frontmatter
- Problem statement
- Full content

### 2. Prepare Description/Content

For **Issue** creation (NEW_ISSUE=true):
- Use the problem statement as the issue description
- Top recommendations section as the main content

For **Document** creation (NEW_ISSUE=false):
- First create a placeholder issue to attach the document to
- Use the full solution content as the document body

### 3. Create Issue or Document

**If NEW_ISSUE=true (default):**

Create an actionable issue for implementing the solution:

```
skill: linear:linear-issue
args: create TITLE="[Ideation] {title from frontmatter}" DESCRIPTION="{problem statement + top recommendations}" PROJECT={PROJECT_ID}
```

**If NEW_ISSUE=false:**

First create a placeholder issue, then attach the document:

1. Create placeholder issue:
```
skill: linear:linear-issue
args: create TITLE="[Solution] {title from frontmatter}" DESCRIPTION="Solution document for: {problem statement}" PROJECT={PROJECT_ID}
```

2. Attach document to the created issue:
```
skill: linear:linear-document
args: create TITLE="[Solution] {title from frontmatter}" CONTENT_FILE={DRAFT_PATH} ISSUE_ID={created_issue_id}
```

## Example (Issue Creation)

```
Input:
  PROJECT_ID: cops
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: true (default)

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Create Issue:
  skill: linear:linear-issue
  args: create TITLE="[Ideation] State Synchronization Solutions" DESCRIPTION="Problem: How to synchronize state across microservices\n\nTop Recommendations:\n1. Event Sourcing with Kafka\n2. CRDT-based approach\n3. Saga Pattern" PROJECT=cops

Result:
  Issue COPS-456 created
```

## Example (Document Creation)

```
Input:
  PROJECT_ID: cops
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: false

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Step 1 - Create placeholder issue:
  skill: linear:linear-issue
  args: create TITLE="[Solution] State Synchronization Solutions" DESCRIPTION="Solution document for: How to synchronize state across microservices" PROJECT=cops
  -> Created COPS-457

Step 2 - Attach document:
  skill: linear:linear-document
  args: create TITLE="[Solution] State Synchronization Solutions" CONTENT_FILE=.agent/tmp/xxxxxxxx-solution ISSUE_ID=COPS-457

Result:
  Issue COPS-457 created with attached solution document
```

## Output

### For Issue (NEW_ISSUE=true)

SUCCESS:
- ISSUE_ID: Created issue identifier
- TITLE: Issue title

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_ID: COPS-456
  TITLE: "[Ideation] State Synchronization Solutions"
```

### For Document (NEW_ISSUE=false)

SUCCESS:
- ISSUE_ID: Created placeholder issue identifier
- DOCUMENT_URL: Attached document URL

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_ID: COPS-457
  DOCUMENT_URL: https://linear.app/team/document/xxx
```

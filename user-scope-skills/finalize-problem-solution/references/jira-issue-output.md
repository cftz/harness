# Jira Issue/Attachment Output (PROJECT_ID)

This document defines how to save problem solutions to a Jira project as either an Issue or an Attachment on a placeholder issue.

## Prerequisites

This document requires the `jira-issue` skill and Jira environment variables to be configured:
- `JIRA_API_TOKEN`
- `JIRA_EMAIL`
- `JIRA_URL`

## Input

- `PROJECT_ID` - Jira Project key (e.g., `MYPROJ`)
- `DRAFT_PATH` - Temporary file from draft-problem-solution
- `NEW_ISSUE` - (Optional) `true` to create Issue (default), `false` to create placeholder issue with attachment
- `METADATA` - Project metadata from `project-manage metadata`:
  - `issueTypes`: Array of `{id, name, subtask}` - available issue types
  - `components`: Array of `{id, name}` - available components
  - `defaultComponent`: Pre-selected default component name (may be null)

## Skills Used

| Skill | Purpose |
|-------|---------|
| `jira-issue` | Create new issues using issueType ID |

## MCP Tools Used (for attachments only)

| Tool | Purpose |
|------|---------|
| `mcp__jira__jira_update_issue` | Attach file to issue |
| `mcp__jira__jira_add_comment` | Add comment |

## Process

### 1. Read Draft File

Read the draft solution file and extract:
- Title from YAML frontmatter
- Problem statement
- Full content

### 2. Prepare Description/Content

For **Issue** creation (NEW_ISSUE=true):
- Use the problem statement as the issue description
- Include top recommendations in the description

For **Attachment** creation (NEW_ISSUE=false):
- First create a placeholder issue
- Then attach the full solution document

### 2.5. Determine Issue Type ID

Select the appropriate issue type **ID** from `METADATA.issueTypes`:

1. Find issue type where `subtask: false` (we're creating standalone issues, not sub-tasks)
2. Prefer types named: "Task", "기타", "Story" (in that order)
3. Get its `id` (e.g., `"10001"`)

**Important**: Use the issue type **ID**, not name. This ensures issue creation works regardless of localized names.

### 3. Create Issue or Attachment

**If NEW_ISSUE=true (default):**

Create an actionable issue for implementing the solution using jira-issue skill:

```
skill: jira-issue
args: create PROJECT={PROJECT_ID} ISSUE_TYPE_ID={issueTypeId} TITLE="[Ideation] {title from frontmatter}" DESCRIPTION="{problem statement}\n\n## Top Recommendations\n{recommendations}" COMPONENT="{METADATA.defaultComponent}"
```

**If NEW_ISSUE=false:**

First create a placeholder issue, then attach the document:

1. Create placeholder issue:
```
skill: jira-issue
args: create PROJECT={PROJECT_ID} ISSUE_TYPE_ID={issueTypeId} TITLE="[Solution] {title from frontmatter}" DESCRIPTION="Solution document for: {problem statement}" COMPONENT="{METADATA.defaultComponent}"
```

2. Attach document to the created issue using MCP:
```
mcp__jira__jira_update_issue(
    issue_key="{created_issue_key}",
    fields={},
    attachments="{DRAFT_PATH}"
)
```

## Example (Issue Creation)

```
Input:
  PROJECT_ID: MYPROJ
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: true (default)
  METADATA:
    issueTypes:
      - {id: "10001", name: "기타", subtask: false}
      - {id: "10002", name: "하위 작업", subtask: true}
    components:
      - {id: "10001", name: "합성 패널"}
    defaultComponent: "합성 패널"

Draft frontmatter:
  ---
  title: State Synchronization Solutions
  problem: How to synchronize state across microservices
  approach: analogous
  ---

Step 2.5 - Determine issue type ID:
  Found non-subtask type: id="10001" (name="기타")

Create Issue using jira-issue skill:
  skill: jira-issue
  args: create PROJECT=MYPROJ ISSUE_TYPE_ID=10001 TITLE="[Ideation] State Synchronization Solutions" DESCRIPTION="Problem: How to synchronize state across microservices\n\n## Top Recommendations\n1. Event Sourcing with Kafka\n2. CRDT-based approach" COMPONENT="합성 패널"
  -> Created MYPROJ-456

Result:
  Issue MYPROJ-456 created
```

## Example (Attachment Creation)

```
Input:
  PROJECT_ID: MYPROJ
  DRAFT_PATH: .agent/tmp/xxxxxxxx-solution
  NEW_ISSUE: false
  METADATA:
    issueTypes:
      - {id: "10001", name: "기타", subtask: false}
    defaultComponent: "합성 패널"

Step 1 - Create placeholder issue using jira-issue skill:
  skill: jira-issue
  args: create PROJECT=MYPROJ ISSUE_TYPE_ID=10001 TITLE="[Solution] State Synchronization Solutions" DESCRIPTION="Solution document for: How to synchronize state across microservices" COMPONENT="합성 패널"
  -> Created MYPROJ-457

Step 2 - Attach document using MCP:
  mcp__jira__jira_update_issue(
      issue_key="MYPROJ-457",
      fields={},
      attachments=".agent/tmp/xxxxxxxx-solution"
  )

Result:
  Issue MYPROJ-457 created with attached solution document
```

## Output

### For Issue (NEW_ISSUE=true)

SUCCESS:
- ISSUE_KEY: Created Jira issue key
- TITLE: Issue summary

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_KEY: MYPROJ-456
  TITLE: "[Ideation] State Synchronization Solutions"
```

### For Attachment (NEW_ISSUE=false)

SUCCESS:
- ISSUE_KEY: Created placeholder Jira issue key
- ATTACHMENT_NAME: Attached filename

Example:
```
STATUS: SUCCESS
OUTPUT:
  ISSUE_KEY: MYPROJ-457
  ATTACHMENT_NAME: xxxxxxxx-solution
```

# Linear Output Document

This document defines how to save execution plans to Linear as a Document attached to the Issue.

## Input

- `ISSUE_ID` - Issue ID from plan input (required for Linear output)
- Temporary file from the previous step containing the execution plan

## Process

### 1. Create Document

Use the `linear-document` skill's `create` command to attach the plan as a Document to the Issue:

```
skill: linear-document
args: create TITLE="[Plan] {title from frontmatter}" CONTENT_FILE={temp_file_path} ISSUE_ID={ISSUE_ID}
```

### 2. Get Todo State ID

Query the team's workflow states to find the "Todo" state ID:

```
skill: linear-state
args: list ISSUE_ID={ISSUE_ID} NAME=Todo
```

Extract the `id` from the first element of the output array.

### 3. Update Issue Status

After obtaining the state ID, update the Issue status to "Todo":

```
skill: linear-issue
args: update ID={ISSUE_ID} STATE_ID={todo_state_id}
```

## Example

```
Input:
  ISSUE_ID: TA-123
  Temp file: .agent/tmp/xxxxxxxx-plan

Step 1 - Create Document:
  skill: linear-document
  args: create TITLE="[Plan] API Implementation" CONTENT_FILE=.agent/tmp/xxxxxxxx-plan ISSUE_ID=TA-123

Step 2 - Get Todo State ID:
  skill: linear-state
  args: list ISSUE_ID=TA-123 NAME=Todo

  Output: [{ "id": "state-002", "name": "Todo", "type": "unstarted", "position": 1 }]
  Extract: todo_state_id = "state-002"

Step 3 - Update Issue Status:
  skill: linear-issue
  args: update ID=TA-123 STATE_ID=state-002

Result:
  Document "[Plan] API Implementation" attached to TA-123
  Issue TA-123 status updated to "Todo"
```

## Output

- Document URL (visible in the Issue's Resources section)
- Issue status updated to "Todo"

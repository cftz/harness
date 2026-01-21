# Linear Task Loading

Instructions for loading task source from Linear Issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

## Process

### 1. Fetch Issue Details

```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

### 2. Fetch Comments (Optional)

Get additional context from comments:

```
skill: linear:linear-comment
args: list ISSUE_ID={ISSUE_ID}
```

### 3. Extract Information

From the response, extract:
- **Title**: Use as task context
- **Description**: Use as initial requirements text
- **Labels**: Note any relevant categorization
- **Acceptance criteria**: If defined in description

## Output

Requirements gathered from the Linear issue, ready for the clarification process.

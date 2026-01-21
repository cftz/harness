# Linear Output

Instructions for updating Linear issue state after finalization.

## Prerequisites

This document requires Linear skills to be available.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
- `target_state` - Target state name: "In Review" or "Done"

## Process

### 1. Get Current Issue State

```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

Extract the current state from the response.

### 2. Check If Update Needed

If current state == target state:
- Log: "Issue already in {target_state}, skipping update"
- Return without updating

### 3. Get State ID for Target State

```
skill: linear:linear-state
args: list ISSUE_ID={ISSUE_ID} NAME={target_state}
```

Extract the state ID from the response.

### 4. Update Issue State

```
skill: linear:linear-issue
args: update ID={ISSUE_ID} STATE_ID={state_id}
```

### 5. Return Result

Log: "Updated issue state to {target_state}"

Return the updated issue URL for the final report.

## Error Handling

- If Linear API returns error: Report error with details
- If state not found: Report "State '{target_state}' not found for team"

## Output

Issue state updated successfully, ready for final report.

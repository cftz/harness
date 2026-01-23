# Linear Cycle Assignment

Add issue to active cycle using the `linear-cycle` skill.

## Input

- `ISSUE_ID` - Issue identifier (e.g., TA-123)
- Issue must already have team info available (from previous steps)

## Process

### 1. Get Issue Info

Get the issue to retrieve team ID:

```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

Extract `team.id` from the response.

### 2. Get Active Cycle

Query for the team's active cycle:

```
skill: linear:linear-cycle
args: get-active TEAM_ID={team_id}
```

If result is `null`, skip cycle assignment (this is not an error).

### 3. Add Issue to Cycle

If an active cycle exists, add the issue to it:

```
skill: linear:linear-cycle
args: add-issue ISSUE_ID={ISSUE_ID} CYCLE_ID={cycle_id}
```

## Example

```
Input:
  ISSUE_ID: TA-123

Step 1 - Get issue:
  skill: linear:linear-issue
  args: get ID=TA-123

  Response:
    { "id": "uuid-123", "identifier": "TA-123", "team": { "id": "team-uuid" } }

Step 2 - Get active cycle:
  skill: linear:linear-cycle
  args: get-active TEAM_ID=team-uuid

  Response:
    { "id": "cycle-uuid", "name": "Sprint 10", "number": 10 }

Step 3 - Add to cycle:
  skill: linear:linear-cycle
  args: add-issue ISSUE_ID=TA-123 CYCLE_ID=cycle-uuid

  Response:
    { "success": true, "issue": { "identifier": "TA-123", "cycle": { "name": "Sprint 10" } } }

Result:
  Issue TA-123 added to Sprint 10
```

## Output

This step does not return a separate output. Log the result:

- If cycle assigned: Log "Added to cycle: {cycle_name}"
- If no active cycle: Log "No active cycle found, skipping" (not an error)

## Error Handling

- If `linear:linear-issue get` fails: Return error
- If `linear:linear-cycle get-active` fails: Return error
- If `linear:linear-cycle add-issue` fails: Return error
- If no active cycle exists: Skip silently (not an error)

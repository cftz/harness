# add-issue

Add an issue to a cycle.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | Yes | Issue identifier (e.g., TA-123) or UUID |
| `CYCLE_ID` | Yes | Cycle UUID |

## Execution

```bash
{baseDir}/scripts/add_issue_to_cycle.sh "{ISSUE_ID}" "{CYCLE_ID}"
```

## Output

JSON object with update result:

```json
{
  "success": true,
  "issue": {
    "identifier": "TA-123",
    "title": "Issue title",
    "cycle": {
      "id": "cycle-uuid",
      "name": "Cycle 5"
    }
  }
}
```

## Example

```
skill: linear:linear-cycle
args: add-issue ISSUE_ID=TA-123 CYCLE_ID=cycle-uuid-456

Output:
{
  "success": true,
  "issue": {
    "identifier": "TA-123",
    "title": "Implement feature X",
    "cycle": {
      "id": "cycle-uuid-456",
      "name": "Sprint 10"
    }
  }
}
```

## Notes

- The script uses Linear's `issueUpdate` mutation with `cycleId` input
- Issue identifier (e.g., TA-123) or UUID can be used as ISSUE_ID

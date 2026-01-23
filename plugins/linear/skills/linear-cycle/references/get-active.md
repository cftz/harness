# get-active

Get the active cycle for a team.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TEAM_ID` | Yes | Team UUID |

## Execution

```bash
{baseDir}/scripts/get_active_cycle.sh "{TEAM_ID}"
```

## Output

JSON object with active cycle or `null`:

```json
{
  "id": "cycle-uuid",
  "name": "Cycle 5",
  "number": 5,
  "startsAt": "2026-01-20T00:00:00.000Z",
  "endsAt": "2026-02-03T00:00:00.000Z"
}
```

Returns `null` if no active cycle exists for the team.

## Example

```
skill: linear:linear-cycle
args: get-active TEAM_ID=abc-123-def

Output:
{
  "id": "cycle-uuid-456",
  "name": "Sprint 10",
  "number": 10,
  "startsAt": "2026-01-20T00:00:00.000Z",
  "endsAt": "2026-02-03T00:00:00.000Z"
}
```

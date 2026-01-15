# list

List Linear workflow states for a team.

## Usage

```
skill: linear-state
args: list [TEAM_ID=<id>] [ISSUE_ID=<id>] [NAME=<name>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TEAM_ID` | No | Team UUID to list states for |
| `ISSUE_ID` | No | Issue identifier (e.g., TA-123) to infer team from |
| `NAME` | No | Filter by state name (e.g., "Todo", "In Progress") |

If neither `TEAM_ID` nor `ISSUE_ID` is provided, uses `linear-current team` to get the current team:

```
skill: linear-current
args: team
```

## Output

JSON array of workflow states:

```json
[
  { "id": "uuid", "name": "Backlog", "type": "backlog", "position": 0 },
  { "id": "uuid", "name": "Todo", "type": "unstarted", "position": 1 },
  { "id": "uuid", "name": "In Progress", "type": "started", "position": 2 },
  { "id": "uuid", "name": "Done", "type": "completed", "position": 3 },
  { "id": "uuid", "name": "Canceled", "type": "canceled", "position": 4 }
]
```

### State Types

Linear workflow states have the following types:
- `triage` - Triage states
- `backlog` - Backlog states
- `unstarted` - Not started states (e.g., Todo)
- `started` - In progress states
- `completed` - Done states
- `canceled` - Canceled/archived states

## Execution

```bash
{baseDir}/scripts/list_states.sh [TEAM_ID] [ISSUE_ID] [NAME]
```

## Examples

```
# List all states for current team (uses linear-current team)
skill: linear-state
args: list

# List all states for a team by team ID
skill: linear-state
args: list TEAM_ID=abc-123

# Get states from an issue's team
skill: linear-state
args: list ISSUE_ID=TA-123

# Find the UUID for "Todo" state
skill: linear-state
args: list ISSUE_ID=TA-123 NAME=Todo
```

Output when filtering by NAME:
```json
[
  { "id": "state-uuid-002", "name": "Todo", "type": "unstarted", "position": 1 }
]
```

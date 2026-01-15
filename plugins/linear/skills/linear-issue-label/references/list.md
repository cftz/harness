# list

List Linear issue labels.

## Usage

```
skill: linear-issue-label
args: list [TEAM_ID=<team-id>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TEAM_ID` | No | Team ID. If not provided, uses `linear-current team` |

If `TEAM_ID` is not provided, uses `linear-current team` to get the current team:

```
skill: linear-current
args: team
```

## Output

JSON array of labels:

```json
[
  { "id": "uuid", "name": "bug", "color": "#ff0000", "description": "...", "isGroup": false },
  ...
]
```

## Execution

Run the script:

```bash
# List labels for a specific team
{baseDir}/scripts/list_labels.sh "team-uuid"
```


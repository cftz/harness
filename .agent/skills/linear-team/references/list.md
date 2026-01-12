# list

List all Linear teams.

## Usage

```
skill: linear-team
args: list
```

## Parameters

None.

## Output

JSON array of teams:

```json
[
  { "id": "uuid", "key": "TEAM", "name": "Team Name" },
  ...
]
```

## Execution

Run the script:

```bash
{baseDir}/scripts/list_teams.sh
```

## Example

```
skill: linear-team
args: list
```

Output:
```json
[
  { "id": "abc-123", "key": "TA", "name": "Team Attention" },
  { "id": "def-456", "key": "COPS", "name": "Cops" }
]
```

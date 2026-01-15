# list

List Linear projects.

## Usage

```
skill: linear-project
args: list [TEAM_ID=<team-id>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TEAM_ID` | No | Filter projects by team ID |

## Output

JSON array of projects:

```json
[
  { "id": "uuid", "name": "Project Name", "slugId": "slug", "teams": [...] },
  ...
]
```

## Execution

Run the script:

```bash
# List all projects
{baseDir}/scripts/list_projects.sh

# List projects for a specific team
{baseDir}/scripts/list_projects.sh "team-uuid"
```

## Example

```
skill: linear-project
args: list
```

Output:
```json
[
  { "id": "abc-123", "name": "C-Ops Platform", "slugId": "c-ops-platform", "teams": [{"id": "...", "name": "Cops"}] }
]
```

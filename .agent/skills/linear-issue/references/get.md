# get

Get a Linear issue by ID or identifier.

## Usage

```
skill: linear-issue
args: get ID=<issue-id>
```

## Parameters

| Parameter | Required | Description                             |
| --------- | -------- | --------------------------------------- |
| `ID`      | Yes      | Issue UUID or identifier (e.g., TA-123) |

## Output

JSON object with issue details:

```json
{
  "id": "uuid",
  "identifier": "TA-123",
  "title": "Issue Title",
  "description": "Markdown description...",
  "url": "https://linear.app/...",
  "state": { "id": "...", "name": "Todo" },
  "team": { "id": "...", "key": "TA", "name": "Team Name" },
  "project": { "id": "...", "name": "Project Name" },
  "assignee": { "id": "...", "name": "User", "email": "user@example.com" },
  "labels": { "nodes": [{ "id": "...", "name": "bug", "color": "#ff0000" }] },
  "priority": 2,
  "priorityLabel": "High",
  "parent": { "id": "...", "identifier": "TA-100", "title": "Parent Issue" },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Execution

```bash
{baseDir}/scripts/get_issue.sh "TA-123"
```

## Example

```
skill: linear-issue
args: get ID=TA-123
```

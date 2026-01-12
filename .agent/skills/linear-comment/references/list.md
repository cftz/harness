# list

List comments for a Linear issue.

## Usage

```
skill: linear-comment
args: list ISSUE_ID=<issue-id>
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | Yes | Issue UUID or identifier (e.g., TA-123) |

## Output

JSON array of comments:

```json
[
  {
    "id": "uuid",
    "body": "Comment content...",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "user": { "name": "User Name", "email": "user@example.com" }
  },
  ...
]
```

## Execution

```bash
{baseDir}/scripts/list_comments.sh "TA-123"
```

## Example

```
skill: linear-comment
args: list ISSUE_ID=TA-123
```

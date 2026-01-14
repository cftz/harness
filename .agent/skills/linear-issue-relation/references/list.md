# list

List all relations for a Linear issue.

## Usage

```
skill: linear-issue-relation
args: list ISSUE_ID=<id>
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | Yes | Issue UUID or identifier (e.g., TA-123) |

## Output

JSON array of relations:

```json
[
  {
    "id": "relation-uuid-1",
    "type": "blocks",
    "issue": {
      "id": "uuid",
      "identifier": "TA-123",
      "title": "Issue Title"
    },
    "relatedIssue": {
      "id": "uuid",
      "identifier": "TA-456",
      "title": "Blocked Issue"
    }
  },
  {
    "id": "relation-uuid-2",
    "type": "related",
    "issue": {
      "id": "uuid",
      "identifier": "TA-123",
      "title": "Issue Title"
    },
    "relatedIssue": {
      "id": "uuid",
      "identifier": "TA-789",
      "title": "Related Issue"
    }
  }
]
```

## Execution

```bash
{baseDir}/scripts/list_relations.sh "TA-123"
```

## Examples

```
# List all relations for an issue
skill: linear-issue-relation
args: list ISSUE_ID=TA-123

# Using UUID
skill: linear-issue-relation
args: list ISSUE_ID=abc123-def456-ghi789
```

## Notes

- Returns relations where the issue is either the source or target
- Use the returned `id` field for `update` or `delete` operations

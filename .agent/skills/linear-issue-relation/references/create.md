# create

Create a relation between two Linear issues.

## Usage

```
skill: linear-issue-relation
args: create ISSUE_ID=<id> RELATED_ISSUE_ID=<id> TYPE=<type>
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | Yes | The issue that has the relation (UUID or identifier, e.g., TA-123) |
| `RELATED_ISSUE_ID` | Yes | The related issue (UUID or identifier, e.g., TA-456) |
| `TYPE` | Yes | Relation type: `blocks`, `duplicate`, `related`, or `similar` |

## Relation Types

- `blocks` - ISSUE_ID blocks RELATED_ISSUE_ID (ISSUE_ID must be completed before RELATED_ISSUE_ID)
- `duplicate` - ISSUE_ID is a duplicate of RELATED_ISSUE_ID
- `related` - ISSUE_ID is related to RELATED_ISSUE_ID
- `similar` - ISSUE_ID is similar to RELATED_ISSUE_ID

## Output

JSON object with created relation:

```json
{
  "id": "relation-uuid",
  "type": "blocks",
  "issue": {
    "id": "uuid",
    "identifier": "TA-123",
    "title": "Issue Title"
  },
  "relatedIssue": {
    "id": "uuid",
    "identifier": "TA-456",
    "title": "Related Issue Title"
  }
}
```

## Execution

```bash
{baseDir}/scripts/create_relation.sh "TA-123" "TA-456" "blocks"
```

## Examples

```
# TA-123 blocks TA-456
skill: linear-issue-relation
args: create ISSUE_ID=TA-123 RELATED_ISSUE_ID=TA-456 TYPE=blocks

# Mark as duplicate
skill: linear-issue-relation
args: create ISSUE_ID=TA-200 RELATED_ISSUE_ID=TA-100 TYPE=duplicate

# Link related issues
skill: linear-issue-relation
args: create ISSUE_ID=TA-300 RELATED_ISSUE_ID=TA-301 TYPE=related
```

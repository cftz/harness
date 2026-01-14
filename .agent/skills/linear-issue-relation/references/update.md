# update

Update an existing Linear issue relation.

## Usage

```
skill: linear-issue-relation
args: update ID=<relation-id> [ISSUE_ID=<id>] [RELATED_ISSUE_ID=<id>] [TYPE=<type>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | The UUID of the relation to update |
| `ISSUE_ID` | No | New source issue (UUID or identifier) |
| `RELATED_ISSUE_ID` | No | New related issue (UUID or identifier) |
| `TYPE` | No | New relation type: `blocks`, `duplicate`, `related`, or `similar` |

## Output

JSON object with updated relation:

```json
{
  "id": "relation-uuid",
  "type": "related",
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
# Update type only
{baseDir}/scripts/update_relation.sh "relation-uuid" "" "" "related"

# Update related issue
{baseDir}/scripts/update_relation.sh "relation-uuid" "" "TA-789" ""
```

## Examples

```
# Change relation type from blocks to related
skill: linear-issue-relation
args: update ID=abc123 TYPE=related

# Change the related issue
skill: linear-issue-relation
args: update ID=abc123 RELATED_ISSUE_ID=TA-999

# Update multiple fields
skill: linear-issue-relation
args: update ID=abc123 RELATED_ISSUE_ID=TA-999 TYPE=blocks
```

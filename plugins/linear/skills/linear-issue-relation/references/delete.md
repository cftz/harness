# delete

Delete a Linear issue relation.

## Usage

```
skill: linear-issue-relation
args: delete ID=<relation-id>
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | The UUID of the relation to delete |

## Output

JSON object confirming deletion:

```json
{
  "success": true
}
```

## Execution

```bash
{baseDir}/scripts/delete_relation.sh "relation-uuid"
```

## Examples

```
# Delete a relation by ID
skill: linear-issue-relation
args: delete ID=abc123-def456-ghi789
```

## Notes

- Use `list` command to find relation IDs for an issue
- Deleting a relation removes it from both issues

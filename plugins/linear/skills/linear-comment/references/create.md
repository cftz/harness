# create

Create a comment on a Linear issue.

## Usage

```
skill: linear-comment
args: create ISSUE_ID=<issue-id> BODY="<comment-content>"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | Yes | Issue UUID or identifier (e.g., TA-123) |
| `BODY` | Yes | Comment content (markdown) |

## Output

JSON object with created comment:

```json
{
  "id": "uuid",
  "body": "Comment content...",
  "url": "https://linear.app/..."
}
```

## Execution

```bash
{baseDir}/scripts/create_comment.sh "TA-123" "Review completed."
```

## Example

```
skill: linear-comment
args: create ISSUE_ID=TA-123 BODY="Code review completed. See attached document for details."
```

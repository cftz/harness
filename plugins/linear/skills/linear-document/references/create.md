# create

Create a Linear document attached to an issue.

## Usage

```
skill: linear-document
args: create TITLE="<title>" ISSUE_ID=<issue-id> [CONTENT="<content>" | CONTENT_FILE=<path>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `TITLE` | Yes | Document title |
| `ISSUE_ID` | Yes | Issue UUID to attach document to |
| `CONTENT` | No | Document content (markdown) |
| `CONTENT_FILE` | No | Path to file containing content |

One of `CONTENT` or `CONTENT_FILE` should be provided.

## Output

JSON object with created document:

```json
{
  "id": "uuid",
  "url": "https://linear.app/...",
  "slugId": "slug",
  "title": "Title"
}
```

## Execution

```bash
# With inline content
{baseDir}/scripts/create_document.sh "Plan Title" "# Plan content..." "issue-uuid"

# With content from file
CONTENT=$(cat .agent/tmp/plan.md)
{baseDir}/scripts/create_document.sh "Plan Title" "$CONTENT" "issue-uuid"
```

## Example

```
skill: linear-document
args: create TITLE="Implementation Plan" ISSUE_ID=abc-123 CONTENT_FILE=.agent/tmp/plan.md
```

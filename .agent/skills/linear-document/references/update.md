# update

Update an existing Linear document.

## Usage

```
skill: linear-document
args: update ID=<document-id> [TITLE="<title>"] [CONTENT="<content>" | CONTENT_FILE=<path>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | Document UUID or slugId |
| `TITLE` | No | New document title |
| `CONTENT` | No | New document content (markdown) |
| `CONTENT_FILE` | No | Path to file containing new content |

At least one of `TITLE`, `CONTENT`, or `CONTENT_FILE` must be provided.

> If `CONTENT_FILE` is provided, read content from the file and use as `CONTENT`.

## Output

JSON object with updated document:

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
# Update title only
{baseDir}/scripts/update_document.sh "document-uuid" "New Title" ""

# Update content from inline
{baseDir}/scripts/update_document.sh "document-uuid" "" "# New content..."

# Update content from file
CONTENT=$(cat .agent/tmp/updated-plan.md)
{baseDir}/scripts/update_document.sh "document-uuid" "" "$CONTENT"
```

## Examples

```
# Update title only
skill: linear-document
args: update ID=abc-123 TITLE="Updated Plan"

# Update content from file
skill: linear-document
args: update ID=abc-123 CONTENT_FILE=.agent/tmp/plan-v2.md

# Update both title and content
skill: linear-document
args: update ID=abc-123 TITLE="Final Plan" CONTENT_FILE=.agent/tmp/final.md
```

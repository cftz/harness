# get

Get a Linear document by ID.

## Usage

```
skill: linear-document
args: get ID=<document-id>
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | Document UUID or slugId |

## Output

JSON object with document details:

```json
{
  "id": "uuid",
  "slugId": "slug",
  "title": "Document Title",
  "content": "# Markdown content...",
  "url": "https://linear.app/...",
  "issue": { "id": "...", "identifier": "TA-123", "title": "..." },
  "project": { "id": "...", "name": "..." }
}
```

## Execution

```bash
{baseDir}/scripts/get_document.sh "document-uuid-or-slug"
```

## Example

```
skill: linear-document
args: get ID=abc123-def456
```

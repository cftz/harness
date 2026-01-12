# search

Search Linear documents by text.

## Usage

```
skill: linear-document
args: search QUERY="<search-term>"
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `QUERY` | Yes | Search term |

## Output

JSON array of matching documents:

```json
[
  { "id": "uuid", "slugId": "slug", "title": "Title", "content": "...", "url": "..." },
  ...
]
```

## Execution

```bash
{baseDir}/scripts/search_documents.sh "API design"
```

## Example

```
skill: linear-document
args: search QUERY="implementation plan"
```

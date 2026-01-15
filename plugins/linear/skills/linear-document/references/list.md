# list

List Linear documents.

## Usage

```
skill: linear-document
args: list [ISSUE_ID=<issue-id>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ISSUE_ID` | No | Filter documents by issue ID |

## Output

JSON array of documents:

```json
[
  { "id": "uuid", "slugId": "slug", "title": "Title", "url": "..." },
  ...
]
```

## Execution

```bash
# List all documents
{baseDir}/scripts/list_documents.sh

# List documents for a specific issue
{baseDir}/scripts/list_documents.sh "TA-123"
```

## Example

```
skill: linear-document
args: list ISSUE_ID=TA-123
```

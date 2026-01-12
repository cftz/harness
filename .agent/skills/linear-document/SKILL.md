---
name: linear-document
description: "Manage Linear documents - get, list, search, create, and update.\n\nCommands:\n  get ID=<id> - Get document by ID\n  list [ISSUE_ID=...] - List documents\n  search QUERY=\"...\" - Search documents\n  create TITLE=\"...\" ISSUE_ID=... [CONTENT=\"...\" | CONTENT_FILE=...]\n  update ID=<id> [TITLE=\"...\"] [CONTENT=\"...\" | CONTENT_FILE=...]\n\nExamples:\n  /linear-document get ID=abc-123\n  /linear-document list ISSUE_ID=TA-123\n  /linear-document create TITLE=\"Plan\" ISSUE_ID=TA-456 CONTENT_FILE=.agent/tmp/plan.md\n  /linear-document update ID=doc-789 CONTENT_FILE=.agent/tmp/updated.md"
user-invocable: false
---

# Linear Document Skill

Manage Linear documents via GraphQL API.

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `get` | Get document by ID | `{baseDir}/references/get.md` |
| `list` | List documents | `{baseDir}/references/list.md` |
| `search` | Search documents | `{baseDir}/references/search.md` |
| `create` | Create document | `{baseDir}/references/create.md` |
| `update` | Update document | `{baseDir}/references/update.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

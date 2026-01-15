---
name: linear-issue-relation
description: |
  Use this skill to manage Linear issue relations - create, delete, list, and update.

  Commands:
    create ISSUE_ID=<id> RELATED_ISSUE_ID=<id> TYPE=<type> - Create relation between issues
    delete ID=<relation-id> - Delete a relation
    list ISSUE_ID=<id> - List relations for an issue
    update ID=<relation-id> [ISSUE_ID=<id>] [RELATED_ISSUE_ID=<id>] [TYPE=<type>] - Update a relation

  Relation Types: blocks, duplicate, related, similar

  Examples:
    /linear-issue-relation create ISSUE_ID=TA-123 RELATED_ISSUE_ID=TA-456 TYPE=blocks
    /linear-issue-relation delete ID=abc-123
    /linear-issue-relation list ISSUE_ID=TA-123
    /linear-issue-relation update ID=abc-123 TYPE=related
user-invocable: false
---

# Linear Issue Relation Skill

Manage relationships between Linear issues via GraphQL API.

## Relation Types

| Type | Description |
|------|-------------|
| `blocks` | Issue blocks the related issue |
| `duplicate` | Issue is a duplicate of the related issue |
| `related` | Issue is related to the related issue |
| `similar` | Issue is similar to the related issue |

## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `create` | Create a new relation | `{baseDir}/references/create.md` |
| `delete` | Delete a relation | `{baseDir}/references/delete.md` |
| `list` | List relations for an issue | `{baseDir}/references/list.md` |
| `update` | Update a relation | `{baseDir}/references/update.md` |

## Environment Variables

- `LINEAR_API_KEY` - Required for API authentication

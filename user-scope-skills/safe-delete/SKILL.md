---
name: safe-delete
description: |
  Use this skill to safely delete files and directories by moving them to a recoverable trash location.

  IMPORTANT: ALWAYS use this skill instead of `rm` command for file deletion.

  Files are moved to `.agent/tmp/trash/` with metadata for restoration.

  Commands:
    delete PATH... - Move files/directories to trash
    list [--all] - List items in trash
    restore ID - Restore item from trash

  Examples:
    /safe-delete delete src/old.ts
    /safe-delete delete src/deprecated/ tmp/test.js
    /safe-delete list
    /safe-delete restore 20260122-123045-abc123
user-invocable: true
---

# Description

Provides safe file deletion by moving items to `.agent/tmp/trash/` instead of permanently deleting them. Each deleted item is stored with metadata allowing restoration to its original location.

## Trash Structure

```
.agent/tmp/trash/
├── 20260122-123045-abc123/
│   ├── .meta.json         # {"original_path": "...", "deleted_at": "...", "type": "file|dir"}
│   └── {original-filename}
```

- Timestamp prefix for chronological sorting
- UUID suffix for collision avoidance
- Individual `.meta.json` for atomicity

## Commands

| Command   | Description                        | Docs                              |
| --------- | ---------------------------------- | --------------------------------- |
| `delete`  | Move files/directories to trash    | `{baseDir}/references/delete.md`  |
| `list`    | List items in trash                | `{baseDir}/references/list.md`    |
| `restore` | Restore item from trash            | `{baseDir}/references/restore.md` |

## Parameters

### delete Command

| Parameter | Required | Description                           |
| --------- | -------- | ------------------------------------- |
| `PATH...` | Yes      | One or more paths to delete           |

### list Command

| Parameter | Required | Description                           |
| --------- | -------- | ------------------------------------- |
| `--all`   | No       | Show all items (default: last 10)     |

### restore Command

| Parameter | Required | Description                           |
| --------- | -------- | ------------------------------------- |
| `ID`      | Yes      | Trash item ID (directory name)        |

## Safety Guards

- **Protected paths**: Refuses to delete `.agent/` directory and system paths (`/usr`, `/etc`, `/bin`, etc.)
- **Restore conflict**: Fails if file exists at original path

## Output

### delete Command

SUCCESS:
- DELETED: List of deleted paths with their trash IDs

ERROR: Error message string

### list Command

SUCCESS:
- ITEMS: List of trash items with ID, original path, deleted time, and type

ERROR: Error message string

### restore Command

SUCCESS:
- RESTORED: Original path where the item was restored

ERROR: Error message string

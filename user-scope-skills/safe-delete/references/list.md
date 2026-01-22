# `list` Command

List items in the trash directory with metadata.

## Process

### 1. Check Trash Directory

```bash
{baseDir}/scripts/list.sh [--all]
```

If `.agent/tmp/trash/` does not exist or is empty, output "Trash is empty."

### 2. Parse Trash Items

For each directory in `.agent/tmp/trash/`:
1. Read `.meta.json`
2. Extract: `original_path`, `deleted_at`, `type`

### 3. Output Formatted List

Output format (sorted by most recent first):

```
ID                          TYPE    DELETED_AT            ORIGINAL_PATH
--------------------------  ------  --------------------  -------------
20260122-123046-def456      file    2026-01-22 12:30:46   /path/to/debug.log
20260122-123045-abc123      dir     2026-01-22 12:30:45   /path/to/old-dir
```

Default: Show last 10 items
With `--all`: Show all items

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `--all` | No | Show all items instead of last 10 |

## Example

```bash
# Show last 10 items
$ {baseDir}/scripts/list.sh
ID                          TYPE    DELETED_AT            ORIGINAL_PATH
--------------------------  ------  --------------------  -------------
20260122-123046-def456      file    2026-01-22 12:30:46   /path/to/debug.log

Showing 1 of 1 items.

# Show all items
$ {baseDir}/scripts/list.sh --all
(shows complete list)
```

## Output

- If trash is empty: `Trash is empty.`
- Otherwise: Formatted table with header

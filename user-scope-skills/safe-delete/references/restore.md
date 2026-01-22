# `restore` Command

Restore an item from trash to its original location.

## Process

### 1. Locate Trash Item

```bash
{baseDir}/scripts/restore.sh ID
```

Find directory: `.agent/tmp/trash/{ID}/`

If not found, output error.

### 2. Read Metadata

Parse `.meta.json` to get `original_path`.

### 3. Check Destination

If file/directory exists at `original_path`, output error and abort.

### 4. Restore Item

1. Create parent directory if needed: `mkdir -p $(dirname original_path)`
2. Move item from trash to original path
3. Remove trash item directory (including `.meta.json`)

### 5. Return Result

Output the restored path.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | Trash item ID (directory name in `.agent/tmp/trash/`) |

## Example

```bash
$ {baseDir}/scripts/restore.sh 20260122-123045-abc123
/Users/jayce/project/src/old.ts
```

## Error Cases

| Error | Message |
|-------|---------|
| ID not found | `ERROR: Trash item not found: {ID}` |
| Metadata missing | `ERROR: Metadata file missing for: {ID}` |
| File exists | `ERROR: File already exists at original path: {path}` |
| No ID provided | `ERROR: No trash ID provided` |

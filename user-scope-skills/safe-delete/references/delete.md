# `delete` Command

Move files and directories to trash with metadata for later restoration.

## Process

### 1. Validate Paths

For each provided path:

1. Check path exists
2. Check path is not protected:
   - `.agent/` directory and subdirectories
   - System paths: `/usr`, `/etc`, `/bin`, `/sbin`, `/var`, `/tmp`, `/opt`, `/lib`
   - macOS system paths: `/System`, `/Applications`, `/Library`, `/private`
   - Home directory root

If validation fails, output error and skip the path.

### 2. Create Trash Entry

For each valid path:

```bash
{baseDir}/scripts/delete.sh PATH [PATH...]
```

The script will:
1. Generate trash ID: `{timestamp}-{uuid6}` (e.g., `20260122-123045-abc123`)
2. Create trash directory: `.agent/tmp/trash/{trash_id}/`
3. Create `.meta.json`:
   ```json
   {
       "original_path": "/absolute/path/to/file",
       "deleted_at": "2026-01-22T12:30:45Z",
       "type": "file|dir"
   }
   ```
4. Move item to trash directory

### 3. Return Results

Output one line per deleted item: `{trash_id}:{original_path}`

## Example

```bash
$ {baseDir}/scripts/delete.sh src/old.ts tmp/debug.log
20260122-123045-abc123:src/old.ts
20260122-123046-def456:tmp/debug.log
```

## Error Cases

| Error | Message |
|-------|---------|
| Path not found | `ERROR: Path does not exist: {path}` |
| Protected path | `ERROR: Cannot delete protected path: {path}` |
| No paths provided | `ERROR: No paths provided` |

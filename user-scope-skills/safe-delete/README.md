# safe-delete

Safe file deletion skill that moves files to a recoverable trash location instead of permanently deleting them.

## Intent

Prevent accidental permanent file deletion by AI agents. Instead of using `rm` which permanently destroys files, this skill moves files to a recoverable trash location. This provides a safety net for recovery if the agent makes a mistake.

## Usage

```bash
# Delete files/directories
/safe-delete delete src/old.ts
/safe-delete delete src/deprecated/ tmp/test.js

# List items in trash
/safe-delete list
/safe-delete list --all

# Restore from trash
/safe-delete restore 20260122-123045-abc123
```

## How It Works

Files are moved to `.agent/tmp/trash/` with metadata:

```
.agent/tmp/trash/
└── 20260122-123045-abc123/
    ├── .meta.json         # Original path, deletion time, type
    └── old.ts             # The actual file
```

## Safety Features

- Protected paths cannot be deleted:
  - `.agent/` directory
  - System directories (`/usr`, `/etc`, `/bin`, etc.)
  - Home directory root
- Restore fails if file already exists at original path
- All deletions are recoverable

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/delete.sh` | Move items to trash |
| `scripts/list.sh` | List trash contents |
| `scripts/restore.sh` | Restore from trash |

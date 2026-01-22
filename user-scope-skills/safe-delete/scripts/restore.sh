#!/bin/bash
# Restore item from trash to original location
# Usage: restore.sh ID

set -e

TRASH_DIR=".agent/tmp/trash"

# Parse arguments
if [[ $# -eq 0 ]]; then
    echo "ERROR: No trash ID provided" >&2
    echo "Usage: restore.sh ID" >&2
    exit 1
fi

TRASH_ID="$1"

# Locate trash item
TRASH_ITEM_DIR="$TRASH_DIR/$TRASH_ID"

if [[ ! -d "$TRASH_ITEM_DIR" ]]; then
    echo "ERROR: Trash item not found: $TRASH_ID" >&2
    exit 1
fi

# Read metadata
META_FILE="$TRASH_ITEM_DIR/.meta.json"
if [[ ! -f "$META_FILE" ]]; then
    echo "ERROR: Metadata file missing for: $TRASH_ID" >&2
    exit 1
fi

# Parse metadata
original_path=$(grep -o '"original_path"[[:space:]]*:[[:space:]]*"[^"]*"' "$META_FILE" | sed 's/.*: *"\([^"]*\)"/\1/')

if [[ -z "$original_path" ]]; then
    echo "ERROR: Could not read original path from metadata" >&2
    exit 1
fi

# Find the actual item (not .meta.json)
item_name=""
for f in "$TRASH_ITEM_DIR"/*; do
    fname=$(basename "$f")
    if [[ "$fname" != ".meta.json" ]]; then
        item_name="$fname"
        break
    fi
done

if [[ -z "$item_name" ]]; then
    echo "ERROR: No item found in trash directory: $TRASH_ID" >&2
    exit 1
fi

ITEM_PATH="$TRASH_ITEM_DIR/$item_name"

# Check if destination exists
if [[ -e "$original_path" ]]; then
    echo "ERROR: File already exists at original path: $original_path" >&2
    exit 1
fi

# Ensure parent directory exists
parent_dir=$(dirname "$original_path")
if [[ ! -d "$parent_dir" ]]; then
    mkdir -p "$parent_dir"
fi

# Restore item
mv "$ITEM_PATH" "$original_path"

# Clean up trash item directory
rm -rf "$TRASH_ITEM_DIR"

echo "$original_path"

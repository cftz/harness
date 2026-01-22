#!/bin/bash
# List items in trash
# Usage: list.sh [--all]

set -e

TRASH_DIR=".agent/tmp/trash"
SHOW_ALL=false
DEFAULT_LIMIT=10

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            SHOW_ALL=true
            shift
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            echo "Usage: list.sh [--all]" >&2
            exit 1
            ;;
    esac
done

# Check if trash directory exists
if [[ ! -d "$TRASH_DIR" ]]; then
    echo "Trash is empty."
    exit 0
fi

# Get list of trash items (sorted by name, which includes timestamp)
items=()
while IFS= read -r -d '' dir; do
    items+=("$dir")
done < <(find "$TRASH_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -rz)

if [[ ${#items[@]} -eq 0 ]]; then
    echo "Trash is empty."
    exit 0
fi

# Determine how many to show
total=${#items[@]}
if [[ "$SHOW_ALL" == "true" ]]; then
    limit=$total
else
    limit=$DEFAULT_LIMIT
    if [[ $total -lt $limit ]]; then
        limit=$total
    fi
fi

# Output header
printf "%-26s  %-6s  %-20s  %s\n" "ID" "TYPE" "DELETED_AT" "ORIGINAL_PATH"
printf "%-26s  %-6s  %-20s  %s\n" "--------------------------" "------" "--------------------" "-------------"

# Output items
count=0
for item_dir in "${items[@]}"; do
    if [[ $count -ge $limit ]]; then
        break
    fi

    meta_file="$item_dir/.meta.json"
    if [[ ! -f "$meta_file" ]]; then
        continue
    fi

    # Parse metadata (using sed/grep for portability)
    original_path=$(grep -o '"original_path"[[:space:]]*:[[:space:]]*"[^"]*"' "$meta_file" | sed 's/.*: *"\([^"]*\)"/\1/')
    deleted_at=$(grep -o '"deleted_at"[[:space:]]*:[[:space:]]*"[^"]*"' "$meta_file" | sed 's/.*: *"\([^"]*\)"/\1/')
    item_type=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$meta_file" | sed 's/.*: *"\([^"]*\)"/\1/')

    # Get ID from directory name
    trash_id=$(basename "$item_dir")

    # Format deleted_at for display (extract date and time part)
    deleted_display=$(echo "$deleted_at" | sed 's/T/ /; s/Z$//')

    printf "%-26s  %-6s  %-20s  %s\n" "$trash_id" "$item_type" "$deleted_display" "$original_path"

    ((count++))
done

# Show message if truncated
if [[ "$SHOW_ALL" == "false" && $total -gt $limit ]]; then
    echo ""
    echo "Showing $limit of $total items. Use --all to see all."
fi

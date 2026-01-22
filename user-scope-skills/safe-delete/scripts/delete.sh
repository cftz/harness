#!/bin/bash
# Move files/directories to trash with metadata for restoration
# Usage: delete.sh PATH [PATH...]

set -e

TRASH_DIR=".agent/tmp/trash"

# Protected paths - exact match (cannot delete these directories themselves)
PROTECTED_EXACT=(
    "/usr"
    "/etc"
    "/bin"
    "/sbin"
    "/var"
    "/tmp"
    "/opt"
    "/lib"
    "/System"
    "/Applications"
    "/Library"
    "/private"
    "$HOME"
)

# Protected paths - block directory and all contents
PROTECTED_RECURSIVE=(
    ".agent"
)

generate_trash_id() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local uuid=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$(date +%N)$$")
    # Take first 6 chars of uuid for brevity
    local short_uuid=$(echo "$uuid" | tr -d '-' | head -c 6 | tr '[:upper:]' '[:lower:]')
    echo "${timestamp}-${short_uuid}"
}

is_protected_path() {
    local path="$1"
    local abs_path=$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path") 2>/dev/null || echo "$path"

    # Check exact protected paths (only the directory itself, not contents)
    for protected in "${PROTECTED_EXACT[@]}"; do
        if [[ "$abs_path" == "$protected" ]]; then
            return 0
        fi
    done

    # Check recursive protected paths (directory and all contents)
    for protected in "${PROTECTED_RECURSIVE[@]}"; do
        # Check relative path
        if [[ "$path" == "$protected" || "$path" == "$protected/"* ]]; then
            return 0
        fi
        # Check absolute path
        local abs_protected
        if [[ "$protected" = /* ]]; then
            abs_protected="$protected"
        else
            abs_protected="$(pwd)/$protected"
        fi
        if [[ "$abs_path" == "$abs_protected" || "$abs_path" == "$abs_protected/"* ]]; then
            return 0
        fi
    done
    return 1
}

delete_item() {
    local path="$1"

    # Check if path exists
    if [[ ! -e "$path" ]]; then
        echo "ERROR: Path does not exist: $path" >&2
        return 1
    fi

    # Check if protected
    if is_protected_path "$path"; then
        echo "ERROR: Cannot delete protected path: $path" >&2
        return 1
    fi

    # Determine type
    local item_type="file"
    if [[ -d "$path" ]]; then
        item_type="dir"
    fi

    # Get absolute path before moving
    local abs_path
    if [[ "$path" = /* ]]; then
        abs_path="$path"
    else
        abs_path="$(pwd)/$path"
    fi

    # Generate trash ID and create directory
    local trash_id=$(generate_trash_id)
    local trash_item_dir="$TRASH_DIR/$trash_id"
    mkdir -p "$trash_item_dir"

    # Get original filename
    local filename=$(basename "$path")

    # Create metadata
    local deleted_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$trash_item_dir/.meta.json" << EOF
{
    "original_path": "$abs_path",
    "deleted_at": "$deleted_at",
    "type": "$item_type"
}
EOF

    # Move item to trash
    mv "$path" "$trash_item_dir/$filename"

    echo "$trash_id:$path"
}

# Ensure at least one path is provided
if [[ $# -eq 0 ]]; then
    echo "ERROR: No paths provided" >&2
    echo "Usage: delete.sh PATH [PATH...]" >&2
    exit 1
fi

# Create trash directory
mkdir -p "$TRASH_DIR"

# Process each path
deleted_items=()
had_error=0

for path in "$@"; do
    result=$(delete_item "$path") && deleted_items+=("$result") || had_error=1
done

# Output results
if [[ ${#deleted_items[@]} -gt 0 ]]; then
    for item in "${deleted_items[@]}"; do
        echo "$item"
    done
fi

exit $had_error

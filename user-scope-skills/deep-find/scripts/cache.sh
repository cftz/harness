#!/bin/bash
# Cache management for deep-find
# Commands: read, write, validate, path
set -e

# Determine project root
# Priority: CLAUDE_PROJECT_DIR (if set) > Git root > Current directory
_get_project_root() {
    if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
        echo "$CLAUDE_PROJECT_DIR"
    elif git rev-parse --show-toplevel 2>/dev/null; then
        : # git command outputs the result
    else
        echo "${PWD}"
    fi
}

PROJECT_ROOT="$(_get_project_root)"
CACHE_DIR="${PROJECT_ROOT}/.agent/cache/deep-find"

# Exit early if sourced by another script (only define CACHE_DIR)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0
fi

COMMAND="$1"
shift

# Get cache file path for a directory
get_cache_path() {
    local dir="$1"
    local abs_dir

    if [[ "$dir" = /* ]]; then
        abs_dir="$dir"
    else
        abs_dir="$(cd "$dir" 2>/dev/null && pwd)"
    fi

    # Create a safe filename from the path
    local safe_name=$(echo "$abs_dir" | sed 's|/|__|g' | sed 's|^__||')
    echo "${CACHE_DIR}/${safe_name}.json"
}

case "$COMMAND" in
    path)
        # Return cache file path for directory
        DIR="${1:-.}"
        get_cache_path "$DIR"
        ;;

    read)
        # Read cache for directory
        DIR="${1:-.}"
        CACHE_FILE=$(get_cache_path "$DIR")

        if [ -f "$CACHE_FILE" ]; then
            cat "$CACHE_FILE"
        else
            echo '{"exists": false}'
        fi
        ;;

    write)
        # Write cache for directory
        # Reads JSON from stdin
        DIR="${1:-.}"
        CACHE_FILE=$(get_cache_path "$DIR")

        mkdir -p "$CACHE_DIR"
        cat > "$CACHE_FILE"
        echo "$CACHE_FILE"
        ;;

    validate)
        # Validate cache entries against current file state
        # Input: directory path
        # Output: JSON with valid/invalid status for each file
        DIR="${1:-.}"
        CACHE_FILE=$(get_cache_path "$DIR")

        if [ ! -f "$CACHE_FILE" ]; then
            echo '{"valid": false, "reason": "no_cache"}'
            exit 0
        fi

        # Check if cache file is older than any file in the directory
        CACHE_MTIME=$(stat -f%m "$CACHE_FILE" 2>/dev/null || stat -c%Y "$CACHE_FILE" 2>/dev/null)

        cd "$DIR"
        INVALID_FILES=""

        for f in $(find . -maxdepth 1 -type f -not -name '.*' | sed 's|^\./||'); do
            FILE_MTIME=$(stat -f%m "$f" 2>/dev/null || stat -c%Y "$f" 2>/dev/null)
            if [ "$FILE_MTIME" -gt "$CACHE_MTIME" ]; then
                if [ -n "$INVALID_FILES" ]; then
                    INVALID_FILES="$INVALID_FILES, \"$f\""
                else
                    INVALID_FILES="\"$f\""
                fi
            fi
        done

        if [ -n "$INVALID_FILES" ]; then
            echo "{\"valid\": false, \"reason\": \"files_modified\", \"files\": [$INVALID_FILES]}"
        else
            echo '{"valid": true}'
        fi
        ;;

    *)
        echo "Usage: cache.sh {path|read|write|validate} [directory]"
        exit 1
        ;;
esac

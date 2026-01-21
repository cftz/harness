#!/bin/bash
# Read a file or directory with cache awareness and optional slicing
# Returns cached summary if valid, or content/message if cache is stale/missing
# Usage: read.sh PATH [OFFSET] [LIMIT]
#   For files:
#     OFFSET: Start line number (1-based, default: 1)
#     LIMIT: Number of lines to read (default: 500)
#   For directories:
#     OFFSET/LIMIT are ignored
set -e

TARGET="$1"
OFFSET="${2:-1}"
LIMIT="${3:-500}"

# Get CACHE_DIR from cache.sh (ensures consistent absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/cache.sh"

if [ -z "$TARGET" ]; then
    echo '{"error": "PATH parameter required"}'
    exit 1
fi

if [ ! -e "$TARGET" ]; then
    echo '{"error": "Path not found", "path": "'"$TARGET"'"}'
    exit 1
fi

# Determine if target is file or directory
if [ -d "$TARGET" ]; then
    TARGET_TYPE="directory"
else
    TARGET_TYPE="file"
fi

# Get absolute path
if [ "$TARGET_TYPE" = "directory" ]; then
    ABS_PATH=$(cd "$TARGET" && pwd)
    DIR="$ABS_PATH"
    ENTRY_NAME=$(basename "$ABS_PATH")
    # For directory, cache is stored in the parent directory's cache file
    PARENT_DIR=$(dirname "$ABS_PATH")
    SAFE_DIR=$(echo "$PARENT_DIR" | sed 's|/|__|g' | sed 's|^__||')
else
    ABS_PATH=$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")
    DIR=$(dirname "$ABS_PATH")
    ENTRY_NAME=$(basename "$ABS_PATH")
    SAFE_DIR=$(echo "$DIR" | sed 's|/|__|g' | sed 's|^__||')
fi

CACHE_FILE="${CACHE_DIR}/${SAFE_DIR}.json"

# ==================== DIRECTORY HANDLING ====================
if [ "$TARGET_TYPE" = "directory" ]; then
    # Check if cache exists and has entry for this directory
    if [ -f "$CACHE_FILE" ]; then
        CACHED_ENTRY=$(cat "$CACHE_FILE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    entry = data.get('entries', {}).get('$ENTRY_NAME', {})
    if entry and entry.get('type') == 'directory':
        meta = entry.get('metadata', {})
        print(json.dumps({
            'found': True,
            'list_hash': meta.get('list_hash', ''),
            'max_mtime': meta.get('max_mtime', 0),
            'summary': entry.get('summary', '')
        }))
    else:
        print(json.dumps({'found': False}))
except:
    print(json.dumps({'found': False}))
" 2>/dev/null || echo '{"found": false}')

        CACHE_FOUND=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('found', False))")

        if [ "$CACHE_FOUND" = "True" ]; then
            CACHED_LIST_HASH=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('list_hash', ''))")
            CACHED_MAX_MTIME=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('max_mtime', 0))")
            CACHED_SUMMARY=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('summary', ''))")

            # Calculate current directory hash
            CURRENT_LIST_HASH=$(ls -1 "$ABS_PATH" 2>/dev/null | sort | md5 2>/dev/null || ls -1 "$ABS_PATH" 2>/dev/null | sort | md5sum 2>/dev/null | cut -d' ' -f1)

            # Get max mtime of files in directory
            if [[ "$OSTYPE" == "darwin"* ]]; then
                CURRENT_MAX_MTIME=$(find "$ABS_PATH" -maxdepth 1 -type f -exec stat -f%m {} \; 2>/dev/null | sort -rn | head -1)
            else
                CURRENT_MAX_MTIME=$(find "$ABS_PATH" -maxdepth 1 -type f -exec stat -c%Y {} \; 2>/dev/null | sort -rn | head -1)
            fi
            CURRENT_MAX_MTIME="${CURRENT_MAX_MTIME:-0}"

            # Compare hashes to check validity
            if [ "$CURRENT_LIST_HASH" = "$CACHED_LIST_HASH" ] && [ "$CURRENT_MAX_MTIME" = "$CACHED_MAX_MTIME" ] && [ -n "$CACHED_SUMMARY" ]; then
                # Cache is valid - return summary only
                cat <<EOF
{
  "status": "cached",
  "type": "directory",
  "path": "$ABS_PATH",
  "summary": $(echo "$CACHED_SUMMARY" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))"),
  "metadata": {
    "list_hash": "$CURRENT_LIST_HASH",
    "max_mtime": $CURRENT_MAX_MTIME
  }
}
EOF
                exit 0
            fi
        fi
    fi

    # Cache is invalid or missing - return needs_init message
    cat <<EOF
{
  "status": "needs_init",
  "type": "directory",
  "path": "$ABS_PATH",
  "message": "Directory summary not cached. Run /deep-find init DIR=$TARGET"
}
EOF
    exit 0
fi

# ==================== FILE HANDLING ====================
# Get current file metadata
if [[ "$OSTYPE" == "darwin"* ]]; then
    CURRENT_MTIME=$(stat -f%m "$TARGET")
    CURRENT_SIZE=$(stat -f%z "$TARGET")
else
    CURRENT_MTIME=$(stat -c%Y "$TARGET")
    CURRENT_SIZE=$(stat -c%s "$TARGET")
fi

# Get total line count
TOTAL_LINES=$(wc -l < "$TARGET" | tr -d ' ')

# Check if cache exists and has entry for this file
if [ -f "$CACHE_FILE" ]; then
    CACHED_ENTRY=$(cat "$CACHE_FILE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    entry = data.get('entries', {}).get('$ENTRY_NAME', {})
    if entry and entry.get('type') == 'file':
        meta = entry.get('metadata', {})
        print(json.dumps({
            'found': True,
            'mtime': meta.get('mtime'),
            'size': meta.get('size'),
            'hash': meta.get('hash'),
            'summary': entry.get('summary', '')
        }))
    else:
        print(json.dumps({'found': False}))
except:
    print(json.dumps({'found': False}))
" 2>/dev/null || echo '{"found": false}')

    CACHE_FOUND=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('found', False))")

    if [ "$CACHE_FOUND" = "True" ]; then
        CACHED_MTIME=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('mtime', 0))")
        CACHED_SUMMARY=$(echo "$CACHED_ENTRY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('summary', ''))")

        # Compare mtime to check validity
        if [ "$CURRENT_MTIME" = "$CACHED_MTIME" ] && [ -n "$CACHED_SUMMARY" ]; then
            # Cache is valid - return summary only
            cat <<EOF
{
  "status": "cached",
  "type": "file",
  "path": "$ABS_PATH",
  "summary": $(echo "$CACHED_SUMMARY" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))"),
  "metadata": {
    "size": $CURRENT_SIZE,
    "mtime": $CURRENT_MTIME,
    "total_lines": $TOTAL_LINES
  }
}
EOF
            exit 0
        fi
    fi
fi

# Cache is invalid or missing - return content (with optional slicing)
if [ "$LIMIT" -eq 0 ]; then
    # Read all lines from offset
    CONTENT=$(tail -n +$OFFSET "$TARGET")
    LINES_READ=$((TOTAL_LINES - OFFSET + 1))
    if [ $LINES_READ -lt 0 ]; then LINES_READ=0; fi
    HAS_MORE="false"
else
    # Read specific number of lines from offset
    CONTENT=$(tail -n +$OFFSET "$TARGET" | head -n $LIMIT)
    LINES_READ=$(echo "$CONTENT" | wc -l | tr -d ' ')
    END_LINE=$((OFFSET + LIMIT - 1))
    if [ $END_LINE -lt $TOTAL_LINES ]; then
        HAS_MORE="true"
    else
        HAS_MORE="false"
    fi
fi

cat <<EOF
{
  "status": "needs_summary",
  "type": "file",
  "path": "$ABS_PATH",
  "content": $(echo "$CONTENT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),
  "metadata": {
    "size": $CURRENT_SIZE,
    "mtime": $CURRENT_MTIME,
    "total_lines": $TOTAL_LINES
  },
  "slice": {
    "offset": $OFFSET,
    "limit": $LIMIT,
    "lines_read": $LINES_READ,
    "has_more": $HAS_MORE
  }
}
EOF

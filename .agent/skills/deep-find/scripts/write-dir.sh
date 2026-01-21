#!/bin/bash
# Write a summary for a directory to the cache
# Creates or updates the cache entry for the given directory in its parent's cache file
# Usage: write-dir.sh DIR "SUMMARY"
set -e

DIR="$1"
SUMMARY="$2"

# Get CACHE_DIR from cache.sh (ensures consistent absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/cache.sh"

if [ -z "$DIR" ] || [ -z "$SUMMARY" ]; then
    echo '{"error": "DIR and SUMMARY parameters required"}'
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo '{"error": "Directory not found", "dir": "'"$DIR"'"}'
    exit 1
fi

# Get absolute path
ABS_DIR=$(cd "$DIR" && pwd)
DIRNAME=$(basename "$ABS_DIR")
PARENT_DIR=$(dirname "$ABS_DIR")

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Get cache file path (stored in parent directory's cache)
SAFE_PARENT=$(echo "$PARENT_DIR" | sed 's|/|__|g' | sed 's|^__||')
CACHE_FILE="${CACHE_DIR}/${SAFE_PARENT}.json"

# Calculate directory hash
# 1. List hash: hash of sorted file/directory names (structure change detection)
if command -v md5 &> /dev/null; then
    LIST_HASH=$(ls -1 "$ABS_DIR" 2>/dev/null | sort | md5)
else
    LIST_HASH=$(ls -1 "$ABS_DIR" 2>/dev/null | sort | md5sum | cut -d' ' -f1)
fi

# 2. Max mtime: maximum mtime of files in directory (content change detection)
if [[ "$OSTYPE" == "darwin"* ]]; then
    MAX_MTIME=$(find "$ABS_DIR" -maxdepth 1 -type f -exec stat -f%m {} \; 2>/dev/null | sort -rn | head -1)
else
    MAX_MTIME=$(find "$ABS_DIR" -maxdepth 1 -type f -exec stat -c%Y {} \; 2>/dev/null | sort -rn | head -1)
fi
MAX_MTIME="${MAX_MTIME:-0}"

# Create or update cache file
if [ -f "$CACHE_FILE" ]; then
    # Update existing cache
    python3 <<PYTHON
import json
import sys

try:
    with open('$CACHE_FILE', 'r') as f:
        data = json.load(f)
except:
    data = {"version": 1, "path": "$PARENT_DIR", "entries": {}}

# Update entry
data['entries']['$DIRNAME'] = {
    "type": "directory",
    "metadata": {
        "list_hash": "$LIST_HASH",
        "max_mtime": $MAX_MTIME
    },
    "summary": """$SUMMARY"""
}

# Update timestamp
from datetime import datetime
data['timestamp'] = datetime.now().isoformat()

with open('$CACHE_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(json.dumps({"success": True, "cache_file": "$CACHE_FILE", "dir": "$DIRNAME"}))
PYTHON
else
    # Create new cache
    python3 <<PYTHON
import json
from datetime import datetime

data = {
    "version": 1,
    "path": "$PARENT_DIR",
    "timestamp": datetime.now().isoformat(),
    "entries": {
        "$DIRNAME": {
            "type": "directory",
            "metadata": {
                "list_hash": "$LIST_HASH",
                "max_mtime": $MAX_MTIME
            },
            "summary": """$SUMMARY"""
        }
    }
}

with open('$CACHE_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(json.dumps({"success": True, "cache_file": "$CACHE_FILE", "dir": "$DIRNAME", "created": True}))
PYTHON
fi

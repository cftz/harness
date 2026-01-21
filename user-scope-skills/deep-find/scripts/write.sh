#!/bin/bash
# Write a summary for a file to the cache
# Creates or updates the cache entry for the given file
# Usage: write.sh FILE "SUMMARY"
set -e

FILE="$1"
SUMMARY="$2"

# Get CACHE_DIR from cache.sh (ensures consistent absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/cache.sh"

if [ -z "$FILE" ] || [ -z "$SUMMARY" ]; then
    echo '{"error": "FILE and SUMMARY parameters required"}'
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo '{"error": "File not found", "file": "'"$FILE"'"}'
    exit 1
fi

# Get absolute path and directory
ABS_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")
DIR=$(dirname "$ABS_FILE")
FILENAME=$(basename "$ABS_FILE")

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Get cache file path
SAFE_DIR=$(echo "$DIR" | sed 's|/|__|g' | sed 's|^__||')
CACHE_FILE="${CACHE_DIR}/${SAFE_DIR}.json"

# Get current file metadata
if [[ "$OSTYPE" == "darwin"* ]]; then
    CURRENT_MTIME=$(stat -f%m "$FILE")
    CURRENT_SIZE=$(stat -f%z "$FILE")
else
    CURRENT_MTIME=$(stat -c%Y "$FILE")
    CURRENT_SIZE=$(stat -c%s "$FILE")
fi

# Get file hash
if command -v md5 &> /dev/null; then
    HASH=$(md5 -q "$FILE")
elif command -v md5sum &> /dev/null; then
    HASH=$(md5sum "$FILE" | cut -d' ' -f1)
else
    HASH="unavailable"
fi

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
    data = {"version": 1, "path": "$DIR", "entries": {}}

# Update entry
data['entries']['$FILENAME'] = {
    "type": "file",
    "metadata": {
        "size": $CURRENT_SIZE,
        "mtime": $CURRENT_MTIME,
        "hash": "$HASH"
    },
    "summary": """$SUMMARY"""
}

# Update timestamp
from datetime import datetime
data['timestamp'] = datetime.now().isoformat()

with open('$CACHE_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(json.dumps({"success": True, "cache_file": "$CACHE_FILE", "file": "$FILENAME"}))
PYTHON
else
    # Create new cache
    python3 <<PYTHON
import json
from datetime import datetime

data = {
    "version": 1,
    "path": "$DIR",
    "timestamp": datetime.now().isoformat(),
    "entries": {
        "$FILENAME": {
            "type": "file",
            "metadata": {
                "size": $CURRENT_SIZE,
                "mtime": $CURRENT_MTIME,
                "hash": "$HASH"
            },
            "summary": """$SUMMARY"""
        }
    }
}

with open('$CACHE_FILE', 'w') as f:
    json.dump(data, f, indent=2)

print(json.dumps({"success": True, "cache_file": "$CACHE_FILE", "file": "$FILENAME", "created": True}))
PYTHON
fi

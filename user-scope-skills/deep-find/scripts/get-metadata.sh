#!/bin/bash
# Get metadata for a single file (hash, mtime, size)
# Outputs JSON format
set -e

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo '{"error": "File not found"}'
    exit 1
fi

# Get file size
if [[ "$OSTYPE" == "darwin"* ]]; then
    SIZE=$(stat -f%z "$FILE")
    MTIME=$(stat -f%m "$FILE")
else
    SIZE=$(stat -c%s "$FILE")
    MTIME=$(stat -c%Y "$FILE")
fi

# Get file hash (MD5 for speed)
if command -v md5 &> /dev/null; then
    HASH=$(md5 -q "$FILE")
elif command -v md5sum &> /dev/null; then
    HASH=$(md5sum "$FILE" | cut -d' ' -f1)
else
    HASH="unavailable"
fi

# Output JSON
cat <<EOF
{
  "size": $SIZE,
  "mtime": $MTIME,
  "hash": "$HASH"
}
EOF

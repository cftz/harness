#!/bin/bash
# Write a value to cache (merge with existing)
# Usage: write_cache.sh <key> <json_value>
# Example: write_cache.sh provider '"jira"'
# Example: write_cache.sh project '{"id":"10001","key":"PROJ","name":"Project Name"}'

set -euo pipefail

KEY="$1"
VALUE="$2"
CACHE_DIR="$PWD/.agent/cache"
CACHE_FILE="$CACHE_DIR/project-manage.json"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Read existing cache or create empty object
if [[ -f "$CACHE_FILE" ]]; then
  EXISTING=$(cat "$CACHE_FILE")
else
  EXISTING="{}"
fi

# Merge new value and write back
echo "$EXISTING" | jq --argjson val "$VALUE" ".$KEY = \$val" > "$CACHE_FILE"

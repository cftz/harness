#!/bin/bash
# Read a specific key from cache
# Usage: read_cache.sh <key>
# key: provider, project, user, or metadata
# Output: JSON if found, "null" if not found
# Exit: always 0

set -euo pipefail

KEY="$1"

# Find project root (git repository root)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
CACHE_DIR="$PROJECT_ROOT/.agent/cache"
CACHE_FILE="$CACHE_DIR/project-manage.json"

if [[ ! -f "$CACHE_FILE" ]]; then
  echo "null"
  exit 0
fi

# Extract value (returns null if key doesn't exist)
jq ".$KEY" "$CACHE_FILE"

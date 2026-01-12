#!/bin/bash
# Create temporary files with optional suffixes
# Usage: mktemp.sh [suffix1] [suffix2] ...

set -e

# Use project-local .agent/tmp/ directory
TMPDIR_LOCAL=".agent/tmp"
mkdir -p "$TMPDIR_LOCAL"

DEFAULT_SUFFIX="tmp"

generate_random() {
    # Sortable timestamp prefix (YYYYMMDD-HHMMSS)
    date +%Y%m%d-%H%M%S
}

create_temp_file() {
    local suffix="${1:-$DEFAULT_SUFFIX}"
    local random_prefix=$(generate_random)
    local filepath="$TMPDIR_LOCAL/${random_prefix}-${suffix}"
    touch "$filepath"
    echo "$filepath"
}

# No arguments: create single file with default suffix
if [ $# -eq 0 ]; then
    create_temp_file "$DEFAULT_SUFFIX"
    exit 0
fi

# Create a file for each suffix
for SUFFIX in "$@"; do
    create_temp_file "$SUFFIX"
done

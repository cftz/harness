#!/bin/bash
# List files and directories in the given directory (current level only)
# Respects .gitignore if GITIGNORE=true
# Excludes asset-like files (images, binaries, etc.)
set -e

DIR="${1:-.}"
GITIGNORE="${2:-true}"

# Asset extensions to exclude
ASSET_EXTENSIONS="png|jpg|jpeg|gif|bmp|ico|svg|webp|mp3|mp4|wav|avi|mov|mkv|pdf|zip|tar|gz|7z|rar|exe|dll|so|dylib|woff|woff2|ttf|eot|min.js|min.css|bundle.js|chunk.js"

# Max file size to include (1MB)
MAX_SIZE=1048576

# Directories to exclude (dependencies, build outputs, caches)
EXCLUDED_DIRS="node_modules|vendor|dist|build|out|__pycache__|.pytest_cache|.venv|venv|env|.tox|coverage|.nyc_output|.next|.nuxt|.cache|target|obj|.gradle|logs|tmp|temp"

# Lock files to exclude
EXCLUDED_FILES="package-lock.json|yarn.lock|pnpm-lock.yaml|bun.lockb|Gemfile.lock|composer.lock|Cargo.lock|go.sum|poetry.lock"

cd "$DIR"

# Get list of files to process
if [ "$GITIGNORE" = "true" ] && git rev-parse --git-dir > /dev/null 2>&1; then
    # Use git ls-files for tracked files, plus untracked non-ignored files
    FILES=$(git ls-files --cached --others --exclude-standard 2>/dev/null | while read -r f; do
        # Only include files in current directory (not subdirectories)
        if [[ "$f" != */* ]] && [ -f "$f" ]; then
            echo "$f"
        fi
    done)
    DIRS=$(git ls-files --cached --others --exclude-standard 2>/dev/null | while read -r f; do
        # Extract top-level directory names
        if [[ "$f" == */* ]]; then
            echo "${f%%/*}"
        fi
    done | sort -u | while read -r d; do
        if [ -d "$d" ]; then
            echo "$d"
        fi
    done)
else
    # No git or gitignore disabled - list all files
    FILES=$(find . -maxdepth 1 -type f -not -name '.*' | sed 's|^\./||')
    DIRS=$(find . -maxdepth 1 -type d -not -name '.' -not -name '.*' | sed 's|^\./||')
fi

# Output JSON
echo "{"
echo '  "files": ['

first=true
for f in $FILES; do
    [ -z "$f" ] && continue

    # Skip excluded lock files
    if echo "$f" | grep -qE "^($EXCLUDED_FILES)$"; then
        continue
    fi

    # Skip asset files
    if echo "$f" | grep -qiE "\.($ASSET_EXTENSIONS)$"; then
        continue
    fi

    # Skip files larger than MAX_SIZE
    size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo "0")
    if [ "$size" -gt "$MAX_SIZE" ]; then
        continue
    fi

    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    printf '    "%s"' "$f"
done

echo ""
echo "  ],"
echo '  "directories": ['

first=true
for d in $DIRS; do
    [ -z "$d" ] && continue

    # Skip excluded directories
    if echo "$d" | grep -qE "^($EXCLUDED_DIRS)$"; then
        continue
    fi

    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    printf '    "%s"' "$d"
done

echo ""
echo "  ]"
echo "}"

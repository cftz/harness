---
name: mktemp
description: "Creates temporary files in .agent/tmp/ with sortable timestamp prefixes.\n\nArgs:\n  SUFFIX... (Optional) - One or more filename suffixes. Defaults to \"tmp\"\n\nExamples:\n  /mktemp\n  /mktemp plan review"
user-invocable: false
---

# mktemp Skill

Creates temporary files in `.agent/tmp/` (project-local temp directory) with sortable timestamp prefixes (YYYYMMDD-HHMMSS). Background subtasks have write access to this directory.

## Parameters

### Optional

- `SUFFIX...` - One or more filename suffixes. Defaults to `tmp` if none provided.

## Usage Examples

```bash
# Default suffix (single file)
skill: mktemp
# -> .agent/tmp/20260110-143052-tmp

# Custom suffix (single file)
skill: mktemp
args: cops
# -> .agent/tmp/20260110-143052-cops

# Multiple files (created in sequence)
skill: mktemp
args: report summary data
# -> .agent/tmp/20260110-143052-report
# -> .agent/tmp/20260110-143052-summary
# -> .agent/tmp/20260110-143052-data
```

## Process

1. Run `{baseDir}/scripts/mktemp.sh [suffix1] [suffix2] ...`
2. Return each created file path (one per line)

## Output

```
.agent/tmp/{YYYYMMDD-HHMMSS}-{SUFFIX1}
.agent/tmp/{YYYYMMDD-HHMMSS}-{SUFFIX2}
...
```

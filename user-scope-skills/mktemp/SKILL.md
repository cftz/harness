---
name: mktemp
description: |
  Use this skill when you need to create temporary files for drafts, intermediate work, or data exchange between skills.

  IMPORTANT: ALWAYS use this skill instead of system mktemp, touch, or Write tool for temp files in .agent/tmp/.

  Creates files in .agent/tmp/ with sortable timestamp prefixes (YYYYMMDD-HHMMSS).

  Args:
    SUFFIX... (Optional) - One or more filename suffixes. Defaults to "tmp"

  Examples:
    /mktemp
    /mktemp plan review
user-invocable: false
---

# mktemp Skill

Creates temporary files in `.agent/tmp/` (project-local temp directory) with sortable timestamp prefixes (YYYYMMDD-HHMMSS). Background subtasks have write access to this directory.

## Parameters

### Optional

- `SUFFIX...` - One or more filename suffixes. Defaults to `tmp` if none provided.

## Process

1. Run `{baseDir}/scripts/mktemp.sh [suffix1] [suffix2] ...`
2. Return each created file path (one per line)

## Output

```
.agent/tmp/{YYYYMMDD-HHMMSS}-{SUFFIX1}
.agent/tmp/{YYYYMMDD-HHMMSS}-{SUFFIX2}
...
```

# Temp Output

Instructions for when temp file output is selected (USE_TEMP=true or default).

## When to Use

Use this reference when:
- `USE_TEMP=true` is provided
- No output destination is explicitly provided (default behavior)

## Process

### 1. Create Temp File

Use `mktemp` skill to create temporary file:

```
skill: mktemp
args: suggestions
```

Store the returned path in `temp_file_path`.

### 2. Write Suggestions Content

Write the suggestions document to `temp_file_path` using the Write tool.

The content should follow the output format defined in SKILL.md:
- Summary with 2-3 sentence overview
- Issues by Severity sections (Critical, High, Medium, Low)
- Detailed Findings table

### 3. Return Output

Report the result following the standard output format:

```
STATUS: SUCCESS
OUTPUT:
  RESULT: COMPLETE
  ISSUES_COUNT: Critical={X}, High={Y}, Medium={Z}, Low={W}
  OUTPUT_PATH: {temp_file_path}
```

## Notes

- Temp files are stored in `.agent/tmp/` directory
- Temp files persist until manually cleaned up
- Useful for quick analysis without permanent storage requirement

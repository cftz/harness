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
args: code-review
```

Store the returned path in `temp_file_path`.

### 2. Write Review Content

Write the review result to `temp_file_path` using the Write tool.

The content should follow the output format defined in SKILL.md:
- For Pass: List files reviewed and rules applied
- For Changes Required: Include violations table and acceptance criteria

### 3. Notify User

Report the result to the user:

**If Pass:**
```
## Code Review Complete

**Status**: Pass

Review saved to: {temp_file_path}

All changes follow project rules correctly.

## Summary
- Files reviewed: {N}
- Rules applied: {N}

To save permanently, re-run with output destination:
  /code-review ARTIFACT_DIR_PATH=.agent/artifacts/...
  /code-review ISSUE_ID=TA-123
```

**If Changes Required:**
```
## Code Review Complete

**Status**: Changes Required

Review saved to: {temp_file_path}

{N} violations found that need to be addressed.

### Revision Checklist
- [ ] {item 1}
- [ ] {item 2}
...

Please address the violations and re-run code-review.
```

## Notes

- Temp files are stored in `.agent/tmp/` directory
- Temp files persist until manually cleaned up
- Useful for quick reviews without permanent storage requirement
- Workflow orchestrators (implement-workflow) typically use this mode

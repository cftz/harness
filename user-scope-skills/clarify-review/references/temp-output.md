# Temp Output

Instructions for when no output destination is provided (review stays in temp file).

## When to Use

Use this reference when neither `ARTIFACT_DIR_PATH` nor other output destination is provided.

## Process

### 1. Keep Review in Temp File

The review content remains in the temp file created by `mktemp` skill in Step 6.

No additional file operations needed.

### 2. Notify User

Report the result to the user:

**If Approved:**
```
## Clarify Review Complete

**Status**: Approved

Review saved to: {temp_file_path}

The task documents follow draft-clarify rules and properly address the original request.

To save permanently, re-run with ARTIFACT_DIR_PATH parameter:
  /clarify-review PROMPT_PATH=... DRAFT_PATHS=... ARTIFACT_DIR_PATH=.agent/artifacts/...
```

**If Revision Needed:**
```
## Clarify Review Complete

**Status**: Revision Needed

Review saved to: {temp_file_path}

{N} issues found that need to be addressed.

### Revision Checklist
- [ ] {item 1}
- [ ] {item 2}
...

Please update the draft documents and re-run clarify-review.
```

## Notes

- Temp files are stored in `.agent/tmp/` directory
- Temp files persist until manually cleaned up
- Useful for quick reviews without permanent storage requirement

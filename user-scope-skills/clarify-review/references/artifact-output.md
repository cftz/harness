# Artifact Output

Instructions for saving review result to artifact directory.

## When to Use

Use this reference when `ARTIFACT_DIR_PATH` parameter is provided.

## Process

### 1. Create Artifact File

Use the `artifact` skill to create a sequential file in the artifact directory:

```
skill: artifact
args: create {ARTIFACT_DIR_PATH} clarify-review
```

This creates a file like `{ARTIFACT_DIR_PATH}/03_clarify-review.md` (number depends on existing files).

### 2. Copy Review Content

Copy the review content from the temp file (created in Step 5 of main process) to the artifact file.

### 3. Notify User

Report the result to the user:

**If Approved:**
```
## Clarify Review Complete

**Status**: Approved

Review saved to: {artifact_file_path}

The task documents follow draft-clarify rules and properly address the original request.
Ready for finalization.
```

**If Revision Needed:**
```
## Clarify Review Complete

**Status**: Revision Needed

Review saved to: {artifact_file_path}

{N} issues found that need to be addressed.

### Revision Checklist
- [ ] {item 1}
- [ ] {item 2}
...

Please update the draft documents and re-run clarify-review.
```

## File Naming Convention

The artifact skill automatically assigns sequential numbers:
- `01_task.md` (if task document exists)
- `02_plan.md` (if plan exists)
- `03_clarify-review.md` (this review)

Or if this is the first clarify output:
- `01_clarify-review.md`

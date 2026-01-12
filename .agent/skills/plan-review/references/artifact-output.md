# Artifact Output Document (Plan Review)

This document defines how to save review results to an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- Temporary file from the previous step containing the review result
- Review status: "Approved" or "Revision Needed"

## Process

### 1. Create Review Artifact File

Use the `artifact` skill's `create` command to create a new file in the artifact directory:

```
skill: artifact
args: create {ARTIFACT_DIR_PATH} plan-review
```

This returns a path like `{ARTIFACT_DIR_PATH}/{NN}_plan-review.md` (number depends on existing files).

Store the returned path in `REVIEW_FILE`.

### 2. Write Review Content

Copy content from the temporary file to `REVIEW_FILE` using the Write tool.

The content should follow the output format defined in SKILL.md:
- For Approved: Include quality scores and optional improvements
- For Revision Needed: Include violations table, improvements, and revision checklist

### 3. Notify User

**If result is Approved:**
- Inform user that review passed
- Show summary of quality scores
- Display path to review file

**If result is Revision Needed:**
- Inform user of violations found
- Present the review document path
- Summarize required revisions
- List next steps

## Example

```
Input:
  ARTIFACT_DIR_PATH: .agent/artifacts/20260105-120000
  Review Status: Revision Needed
  Temp file: .agent/tmp/plan-review.xxxxxxxx

Execution:
  1. skill: artifact
     args: create .agent/artifacts/20260105-120000 plan-review
     -> Returns: .agent/artifacts/20260105-120000/03_plan-review.md

  2. Write review content to .agent/artifacts/20260105-120000/03_plan-review.md

Output:
  Review saved to: .agent/artifacts/20260105-120000/03_plan-review.md
```

## Output

- Path to the created review file (e.g., `.agent/artifacts/20260105-120000/03_plan-review.md`)

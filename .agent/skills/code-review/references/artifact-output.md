# Artifact Output Document (Code Review)

This document defines how to save review results to an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- Review result content (Pass or Changes Required)

## Process

### 1. Create Review Artifact File

Use the `artifact` skill to create a new file in the artifact directory:

```
skill: artifact
args: create {ARTIFACT_DIR_PATH} review
```

This returns a path like `{ARTIFACT_DIR_PATH}/03_review.md` (number depends on existing files).

Store the returned path in `REVIEW_FILE`.

### 2. Write Review Content

Write the review result to `REVIEW_FILE` using the Write tool.

The content should follow the output format defined in SKILL.md:
- For Pass: List files reviewed and rules applied
- For Changes Required: Include violations table and acceptance criteria

### 3. Notify User (if applicable)

If `AUTO_ACCEPT` is not `true` and result is Pass:
- Inform user that review passed
- Show summary of files reviewed

If result is Changes Required:
- Always inform user of violations found
- Present the review document path

## Example

```
Input:
  ARTIFACT_DIR_PATH: .agent/artifacts/20260105-120000
  Review Status: Pass

Execution:
  1. skill: artifact
     args: create .agent/artifacts/20260105-120000 review
     → Returns: .agent/artifacts/20260105-120000/03_review.md

  2. Write review content to .agent/artifacts/20260105-120000/03_review.md

Output:
  Review saved to: .agent/artifacts/20260105-120000/03_review.md
```

## Output

- Path to the created review file (e.g., `.agent/artifacts/20260105-120000/03_review.md`)

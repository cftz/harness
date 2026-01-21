# Artifact Task Document (Plan Review)

This document defines how to load a plan from an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)

## Process

### 1. List Directory Contents

```bash
ls -1 "$ARTIFACT_DIR_PATH"
```

### 2. Find Plan Documents

Look for files matching the pattern `*_plan*.md` or `*plan*.md`:

```bash
ls "$ARTIFACT_DIR_PATH"/*plan*.md 2>/dev/null
```

If multiple plan files exist, use the one with the highest sequence number.

### 3. Read Plan Document

Read the plan file and parse:
- YAML frontmatter (title, issueId)
- Overview section
- Implementation Steps
- Summary of Changes

### 4. Extract Target Files

From the plan document, extract all file paths mentioned in:
- Implementation Steps file headers
- Summary of Changes table

## Output

After reading the documents, you should have:

- **Plan title**: From frontmatter
- **Issue ID**: From frontmatter (if present)
- **Target file list**: All files mentioned in the plan
- **Implementation details**: Steps with code outlines

## Example

```
ARTIFACT_DIR_PATH: .agent/artifacts/20260105-120000

Directory contents:
  01_task.md
  02_plan.md

Using: 02_plan.md

Extracted:
- Title: Implement User Service
- Target files: internal/service/user/user.go, internal/service/user/user_test.go
```

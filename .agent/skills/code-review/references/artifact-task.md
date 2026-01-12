# Artifact Task Document

This document defines how to load review context from an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)

## Process

### 1. List Directory Contents

```bash
ls -1 "$ARTIFACT_DIR_PATH"
```

### 2. Find Task Documents

Look for files matching the pattern `*_task*.md` or `*_requirements*.md`:

```bash
ls "$ARTIFACT_DIR_PATH"/*task*.md "$ARTIFACT_DIR_PATH"/*requirements*.md 2>/dev/null
```

Read all matching files to understand:
- What was originally requested
- Acceptance criteria
- Scope boundaries

### 3. Find Plan Documents

Look for files matching the pattern `*_plan*.md`:

```bash
ls "$ARTIFACT_DIR_PATH"/*plan*.md 2>/dev/null
```

Read all matching files to understand:
- What was planned to be implemented
- Which files were targeted for changes
- Implementation approach

### 4. Extract Target Files

From the plan document, extract the list of files that were supposed to be modified. Look for:
- "Files to modify" sections
- File paths in code blocks
- Implementation steps referencing specific files

## Output

After reading the documents, you should have:
- **Original requirements**: What was requested
- **Implementation plan**: What was planned
- **Target file list**: Files that should have been changed

## Example

```
ARTIFACT_DIR_PATH: .agent/artifacts/20260105-120000

Directory contents:
  01_task.md
  02_plan.md

From 01_task.md:
  - Acceptance criteria
  - Scope definition

From 02_plan.md:
  - Target files: internal/service/auth.go, internal/handler/auth_handler.go
  - Implementation steps
```

Use this context to guide your code review, ensuring the implementation matches the original plan.

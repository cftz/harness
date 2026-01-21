# Artifact Output Document

This document defines how to save clarified tasks to an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Full Artifact Directory Path (e.g., `.agent/artifacts/20260110-120000`)
- `DRAFT_PATHS` - Comma-separated list of temporary file paths from draft-clarify

## Process

### Step 1: Parse Draft Paths

Split the `DRAFT_PATHS` parameter by comma to get individual file paths.

### Step 2: Extract Task Names

For each draft file path, extract the task name (remove random prefix):
- `.agent/tmp/20260110-task1` -> `task1`
- `.agent/tmp/abc123-feature` -> `feature`

### Step 3: Create Artifact Files

Use the `artifact` skill's `create` command to create all artifact files at once:

```
skill: artifact
args: create {ARTIFACT_DIR_PATH} {task1} {task2} ...
```

This creates sequentially numbered files like:
- `{ARTIFACT_DIR_PATH}/01_{task1}.md`
- `{ARTIFACT_DIR_PATH}/01_{task2}.md`

### Step 4: Copy Content

For each draft file, copy its content to the corresponding artifact file:

1. Read the draft file content
2. Write to the corresponding artifact file

Preserve all content exactly, including YAML frontmatter and all sections.

## Example

```
Input:
  ARTIFACT_DIR_PATH: .agent/artifacts/20260110-120000
  DRAFT_PATHS: .agent/tmp/20260110-auth,.agent/tmp/20260110-api

Step 1 - Parse paths:
  - .agent/tmp/20260110-auth
  - .agent/tmp/20260110-api

Step 2 - Extract names:
  - auth
  - api

Step 3 - Create artifact files:
  skill: artifact
  args: create .agent/artifacts/20260110-120000 auth api

  Creates:
  - .agent/artifacts/20260110-120000/01_auth.md
  - .agent/artifacts/20260110-120000/01_api.md

Step 4 - Copy content:
  .agent/tmp/20260110-auth -> .agent/artifacts/20260110-120000/01_auth.md
  .agent/tmp/20260110-api -> .agent/artifacts/20260110-120000/01_api.md
```

## Output

List of created artifact file paths:
```
Tasks saved to artifact directory:
- .agent/artifacts/20260110-120000/01_auth.md
- .agent/artifacts/20260110-120000/01_api.md
```

# Artifact Output Document

This document defines how to save problem solutions to an artifact directory.

## Input

- `ARTIFACT_DIR_PATH` - Full Artifact Directory Path (e.g., `.agent/artifacts/20260120-120000`)
- `DRAFT_PATH` - Temporary file from draft-problem-solution (e.g., `.agent/tmp/xxxxxxxx-solution`)

## Process

1. Extract file name from temporary file path (remove random prefix)
   - `.agent/tmp/xxxxxxxx-solution` -> `solution`

2. Use `artifact` skill's `create` command to create artifact file:
   ```
   skill: artifact
   args: create {ARTIFACT_DIR_PATH} solution
   ```
   This creates a sequentially numbered file like:
   - `{ARTIFACT_DIR_PATH}/{NN}_solution.md` (NN is the next sequential number)

3. Copy content from the temporary file to the artifact file

### Example

```
ARTIFACT_DIR_PATH: .agent/artifacts/20260120-120000
DRAFT_PATH: .agent/tmp/xxxxxxxx-solution

After create command:
  .agent/artifacts/20260120-120000/{NN}_solution.md <- content from .agent/tmp/xxxxxxxx-solution
```

## Output

SUCCESS:
- ARTIFACT_PATH: Created artifact file path

Example:
```
STATUS: SUCCESS
OUTPUT:
  ARTIFACT_PATH: .agent/artifacts/20260120-120000/02_solution.md
```

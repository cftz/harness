# Artifact Output

Instructions for saving suggestions to an artifact directory.

## When to Use

Use this reference when `ARTIFACT_DIR_PATH` is provided.

## Process

### 1. Create Artifact File

Use the `artifact` skill to create a new file in the artifact directory:

```
skill: artifact
args: create {ARTIFACT_DIR_PATH} suggestions
```

This returns a path like `{ARTIFACT_DIR_PATH}/01_suggestions.md` (number depends on existing files).

Store the returned path in `output_file`.

### 2. Write Suggestions Content

Write the suggestions document to `output_file` using the Write tool.

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
  OUTPUT_PATH: {output_file}
```

## Example

```
Input:
  TARGET: repository
  ARTIFACT_DIR_PATH: .agent/artifacts/20260117-120000

Execution:
  1. skill: artifact
     args: create .agent/artifacts/20260117-120000 suggestions
     -> Returns: .agent/artifacts/20260117-120000/01_suggestions.md

  2. Write suggestions content to .agent/artifacts/20260117-120000/01_suggestions.md

Output:
  STATUS: SUCCESS
  OUTPUT:
    RESULT: COMPLETE
    ISSUES_COUNT: Critical=0, High=3, Medium=5, Low=2
    OUTPUT_PATH: .agent/artifacts/20260117-120000/01_suggestions.md
```

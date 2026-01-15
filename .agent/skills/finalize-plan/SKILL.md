---
name: finalize-plan
description: "Use this skill to finalize approved plans by converting temporary draft files to final outputs (Artifact or Linear Document).\n\nArgs:\n  DRAFT_PATH=<path> (Required) - Path to temporary draft file\n  Output (OneOf, Required):\n    ARTIFACT_DIR_PATH=<path> - Save to artifact directory\n    ISSUE_ID=<id> - Save as Linear Document and update issue state\n\nExamples:\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ARTIFACT_DIR_PATH=.agent/artifacts/20260110\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ISSUE_ID=TA-123"
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Finalize Plan Skill

Converts temporary draft files to final outputs. Supports two output destinations:
- **Artifact Directory**: Creates numbered artifact file and copies content
- **Linear Document**: Creates document attached to issue and updates issue state to Todo

## Parameters

### Required

- `DRAFT_PATH` - Path to the temporary draft file (e.g., `.agent/tmp/abc123-plan`)

### Output Destination (OneOf, Required)

Provide exactly one:

- `ARTIFACT_DIR_PATH` - Artifact directory path to save the final output
- `ISSUE_ID` - Linear Issue ID to attach document and update state

## Process

### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`

### If ISSUE_ID is provided

Follow `{baseDir}/references/linear-output.md`

## Output

### For Artifact Output

```
Plan saved to: {artifact_file_path}
```

### For Linear Output

```
Document created: {document_url}
Issue {ISSUE_ID} status updated to Todo
```

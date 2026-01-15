---
name: finalize-clarify
description: "Use this skill to finalize clarified requirements by converting approved temporary task files to final outputs (Artifact files or Linear issues).\n\nArgs:\n  DRAFT_PATHS=<paths> (Required) - Comma-separated list of temporary file paths\n  Output (OneOf, Required):\n    ARTIFACT_DIR_PATH=<path> - Save to artifact directory\n    PROJECT_ID=<id> - Create Linear issues in project\n  Options:\n    ASSIGNEE=<id|name|email|me> - Issue assignee (default: linear-current user)\n    PARENT_ISSUE_ID=<id> - Create as sub-issues under this parent\n\nExamples:\n  /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1,.agent/tmp/20260110-task2 ARTIFACT_DIR_PATH=.agent/artifacts/20260110\n  /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops\n  /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops PARENT_ISSUE_ID=TA-123 ASSIGNEE=me"
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Finalize Clarify Skill

Converts approved temporary task files from draft-clarify to final outputs. This is Phase B of the clarify workflow, called only after user approval.

Supports two output destinations:
- **Artifact Directory**: Creates numbered artifact files and copies content
- **Linear Issues**: Creates issues with proper dependency relationships

## Parameters

### Required

- `DRAFT_PATHS` - Comma-separated list of temporary file paths from draft-clarify (e.g., `.agent/tmp/20260110-task1,.agent/tmp/20260110-task2`)

### Output Destination (OneOf, Required)

Provide exactly one:

- `ARTIFACT_DIR_PATH` - Artifact directory path to save the final outputs
- `PROJECT_ID` - Linear Project ID or name to create issues in

### Optional (Linear output only)

- `ASSIGNEE` - User to assign issues to (ID, name, email, or "me"). Defaults to current user via linear-current
- `PARENT_ISSUE_ID` - Parent issue ID to create as sub-issues under (e.g., `TA-123`)

## Process

### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`

### If PROJECT_ID is provided

Follow `{baseDir}/references/linear-output.md`

## Output

### For Artifact Output

```
Tasks saved to artifact directory:
- {artifact_file_path_1}
- {artifact_file_path_2}
...
```

### For Linear Output

```
Issues created:
- {issue_identifier_1}: {title_1}
- {issue_identifier_2}: {title_2}
...

Blocking relationships:
- {issue_2} blocked by {issue_1}
...
```

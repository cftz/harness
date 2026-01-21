---
name: finalize-clarify
description: |
  Use this skill to finalize clarified requirements by converting approved temporary task files to final outputs (Artifact files or Linear issues).

  IMPORTANT: Only call this skill after user approval of draft-clarify outputs. This is Phase B of the clarify workflow.

  Args:
    DRAFT_PATHS=<paths> (Required) - Comma-separated list of temporary file paths
    Output (OneOf, Required):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      PROJECT_ID=<id> - Create Linear issues in project
    Options:
      ASSIGNEE=<id|name|email|me> - Issue assignee (default: linear-current user)
      PARENT_ISSUE_ID=<id> - Create as sub-issues under this parent

  Examples:
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1,.agent/tmp/20260110-task2 ARTIFACT_DIR_PATH=.agent/artifacts/20260110
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops PARENT_ISSUE_ID=TA-123 ASSIGNEE=me
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Description

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

SUCCESS:
- For Artifact Output:
  - ARTIFACT_PATHS: List of created artifact file paths
- For Linear Output:
  - ISSUE_IDS: Map of task names to created issue identifiers
  - BLOCKING_RELATIONS: List of blocking relationships created

ERROR: Error message string (e.g., "Draft file not found: {path}", "Linear API error: {message}")

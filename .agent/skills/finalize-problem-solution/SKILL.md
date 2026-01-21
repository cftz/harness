---
name: finalize-problem-solution
description: |
  Use this skill to finalize problem solutions by converting temporary draft files to final outputs.

  Args:
    DRAFT_PATH=<path> (Required) - Path to temporary draft file from draft-problem-solution
    Output Destination (OneOf, Required):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      ISSUE_ID=<id> - Save as Linear Document attached to issue
      PROJECT_ID=<id> - Save to Linear project
    Options (PROJECT_ID only):
      NEW_ISSUE=<bool> - true=Create Issue (default), false=Create Document

  Examples:
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution ARTIFACT_DIR_PATH=.agent/artifacts/20260120
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution ISSUE_ID=TA-123
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution PROJECT_ID=cops
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution PROJECT_ID=cops NEW_ISSUE=false
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Finalize Problem Solution Skill

Converts temporary draft solution files from draft-problem-solution to final outputs. This is the finalization phase of the problem-solving workflow, called only after user approval.

Supports three output destinations:
- **Artifact Directory**: Creates numbered artifact file and copies content
- **Linear Document**: Creates document attached to an existing issue
- **Linear Issue/Document**: Creates a new issue or document in a project

## Parameters

### Required

- `DRAFT_PATH` - Path to the temporary draft file from draft-problem-solution (e.g., `.agent/tmp/xxx-solution`)

### Output Destination (OneOf, Required)

Provide exactly one:

- `ARTIFACT_DIR_PATH` - Artifact directory path to save the final output
- `ISSUE_ID` - Linear Issue ID to attach document to
- `PROJECT_ID` - Linear Project ID or name to create issue/document in

### Options (PROJECT_ID only)

- `NEW_ISSUE` - When using PROJECT_ID: `true` creates an Issue (default), `false` creates a Document

## Process

### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`

### If ISSUE_ID is provided

Follow `{baseDir}/references/linear-document-output.md`

### If PROJECT_ID is provided

Follow `{baseDir}/references/linear-issue-output.md`

## Output

SUCCESS:
- For Artifact Output:
  - ARTIFACT_PATH: Created artifact file path (e.g., `.agent/artifacts/20260120-120000/02_solution.md`)
- For Linear Document Output (ISSUE_ID):
  - DOCUMENT_URL: Created document URL
  - ISSUE_ID: Issue the document was attached to
- For Linear Issue Output (PROJECT_ID with NEW_ISSUE=true):
  - ISSUE_ID: Created issue identifier (e.g., `COPS-456`)
  - TITLE: Issue title
- For Linear Document Output (PROJECT_ID with NEW_ISSUE=false):
  - ISSUE_ID: Created placeholder issue identifier
  - DOCUMENT_URL: Attached document URL

ERROR: Error message string describing the failure

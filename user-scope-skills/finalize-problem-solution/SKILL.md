---
name: finalize-problem-solution
description: |
  Use this skill to finalize problem solutions by converting temporary draft files to final outputs.

  Args:
    DRAFT_PATH=<path> (Required) - Path to temporary draft file from draft-problem-solution
    Output Destination (OneOf, Required):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      ISSUE_ID=<id> - Save as Document/Attachment attached to issue
      PROJECT_ID=<id> - Save to project (Linear or Jira)
    Options:
      PROVIDER=linear|jira - Issue tracker provider (default: linear)
      NEW_ISSUE=<bool> - true=Create Issue (default), false=Create Document (PROJECT_ID only)

  Examples:
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution ARTIFACT_DIR_PATH=.agent/artifacts/20260120
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution ISSUE_ID=TA-123
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution PROJECT_ID=cops
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution PROJECT_ID=cops NEW_ISSUE=false
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution ISSUE_ID=PROJ-456 PROVIDER=jira
    /finalize-problem-solution DRAFT_PATH=.agent/tmp/xxx-solution PROJECT_ID=MYPROJ PROVIDER=jira
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Description

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
- `ISSUE_ID` - Issue ID to attach document/attachment to (e.g., `PROJ-123`)
- `PROJECT_ID` - Project ID or name to create issue/document in

### Options

- `PROVIDER` - Issue tracker provider when using `ISSUE_ID` or `PROJECT_ID` (default: `linear`)
  - `linear` - Linear (e.g., `TA-123`, `cops`)
  - `jira` - Jira (e.g., `PROJ-456`, `MYPROJ`)
- `NEW_ISSUE` - When using PROJECT_ID: `true` creates an Issue (default), `false` creates a Document/Attachment

## Process

### 0. Resolve Provider (if ISSUE_ID or PROJECT_ID provided)

If `ISSUE_ID` or `PROJECT_ID` is provided:
- If `PROVIDER` parameter is explicitly provided, use it
- If not provided, get from project-manage:
  ```
  skill: project-manage
  args: provider
  ```
  Use the returned provider value (or `linear` if project-manage not initialized)

### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`

### If ISSUE_ID is provided

Route based on resolved PROVIDER:

| PROVIDER           | Reference Document                               |
| ------------------ | ------------------------------------------------ |
| `linear` (default) | `{baseDir}/references/linear-document-output.md` |
| `jira`             | `{baseDir}/references/jira-document-output.md`   |

### If PROJECT_ID is provided

**For Jira provider only**, get metadata first:
```
skill: project-manage
args: metadata PROVIDER=jira
```

This returns `issueTypes`, `components`, and `defaultComponent` needed for issue creation.

Route based on resolved PROVIDER:

| PROVIDER           | Reference Document                            | Additional Data |
| ------------------ | --------------------------------------------- | --------------- |
| `linear` (default) | `{baseDir}/references/linear-issue-output.md` | (none)          |
| `jira`             | `{baseDir}/references/jira-issue-output.md`   | METADATA        |

## Output

SUCCESS:
- For Artifact Output:
  - ARTIFACT_PATH: Created artifact file path (e.g., `.agent/artifacts/20260120-120000/02_solution.md`)
- For Linear Document Output (ISSUE_ID, PROVIDER=linear):
  - DOCUMENT_URL: Created document URL
  - ISSUE_ID: Issue the document was attached to
- For Jira Attachment Output (ISSUE_ID, PROVIDER=jira):
  - ATTACHMENT_NAME: Attached filename
  - ISSUE_KEY: Jira issue key
- For Linear Issue Output (PROJECT_ID, PROVIDER=linear, NEW_ISSUE=true):
  - ISSUE_ID: Created issue identifier (e.g., `COPS-456`)
  - TITLE: Issue title
- For Linear Document Output (PROJECT_ID, PROVIDER=linear, NEW_ISSUE=false):
  - ISSUE_ID: Created placeholder issue identifier
  - DOCUMENT_URL: Attached document URL
- For Jira Issue Output (PROJECT_ID, PROVIDER=jira, NEW_ISSUE=true):
  - ISSUE_KEY: Created Jira issue key (e.g., `MYPROJ-456`)
  - TITLE: Issue summary
- For Jira Attachment Output (PROJECT_ID, PROVIDER=jira, NEW_ISSUE=false):
  - ISSUE_KEY: Created placeholder Jira issue key
  - ATTACHMENT_NAME: Attached filename

ERROR: Error message string describing the failure

## Constraints

- When moving temp files to final location, prefer Bash `mv` or `cp` commands over Read + Write tools to reduce token usage and avoid content copying errors

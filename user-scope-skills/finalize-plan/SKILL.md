---
name: finalize-plan
description: "Use this skill to finalize approved plans by converting temporary draft files to final outputs (Artifact or Linear Document).\n\nArgs:\n  DRAFT_PATH=<path> (Required) - Path to temporary draft file\n  Output (OneOf, Required):\n    ARTIFACT_DIR_PATH=<path> - Save to artifact directory\n    ISSUE_ID=<id> - Save as Linear Document and update issue state\n\nExamples:\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ARTIFACT_DIR_PATH=.agent/artifacts/20260110\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ISSUE_ID=TA-123"
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Finalize Plan Skill

Converts temporary draft files to final outputs. This skill handles the "finalization" phase of the planning workflow, ensuring that only approved plans are written to persistent storage.

Supports two output destinations:
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

### 1. Validate Input

1. Verify `DRAFT_PATH` exists and is readable
2. Verify exactly one output destination is provided (`ARTIFACT_DIR_PATH` or `ISSUE_ID`)
3. Read the draft file content and extract YAML frontmatter (title, issueId if present)

### 2. Execute Output

#### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`:

1. Extract file name from temporary file path (remove random prefix)
   - `.agent/tmp/xxxxxxxx-plan` -> `plan`
2. Use `artifact` skill's `create` command to create artifact file
3. Copy content from draft file to the artifact file

#### If ISSUE_ID is provided

Follow `{baseDir}/references/linear-output.md`:

1. Create Document using `linear-document` skill with title from frontmatter
2. Get Todo state ID using `linear-state` skill
3. Update issue status to Todo using `linear-issue` skill

### 3. Report Result

Report the final output path or URL to the user.

## Output

SUCCESS:
- PLAN_PATH: Final plan file path (for Artifact output)
- DOCUMENT_URL: Linear document URL (for Linear output)
- ISSUE_ID: Updated issue ID (for Linear output, same as input)

ERROR: Error message string describing what failed

### Example Output

**For Artifact Output:**
```
STATUS: SUCCESS
OUTPUT:
  PLAN_PATH: .agent/artifacts/20260110/02_plan.md
```

**For Linear Output:**
```
STATUS: SUCCESS
OUTPUT:
  DOCUMENT_URL: https://linear.app/team/document/xxx
  ISSUE_ID: TA-123
```

**For Error:**
```
STATUS: ERROR
OUTPUT: Draft file not found: .agent/tmp/abc123-plan
```

## Quality Checklist

Before completing, verify:

- [ ] Draft file exists and content was read successfully
- [ ] YAML frontmatter was parsed correctly (title extracted)
- [ ] Output destination was created successfully
- [ ] For Linear output: Issue state was updated to Todo
- [ ] Final output path/URL is reported to user

## Constraints

- Should NOT create or modify draft files (that is `draft-plan`'s responsibility)
- Should NOT validate plans (that is `plan-review`'s responsibility)
- Should NOT be called without user approval (except when `AUTO_ACCEPT=true` in workflow)
- Expects draft files in the format produced by `draft-plan`

---
name: finalize-plan
description: "Use this skill to finalize approved plans by converting temporary draft files to final outputs (Artifact or Linear Document).\n\nArgs:\n  DRAFT_PATH=<path> (Required) - Path to temporary draft file\n  Output (OneOf, Required):\n    ARTIFACT_DIR_PATH=<path> - Save to artifact directory\n    ISSUE_ID=<id> - Save as Document/Attachment and update issue state\n  Options:\n    PROVIDER=linear|jira - Issue tracker provider (default: linear)\n    ASSIGNEE=<id> - Assignee for the issue (optional, uses current user if not provided)\n\nExamples:\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ARTIFACT_DIR_PATH=.agent/artifacts/20260110\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ISSUE_ID=TA-123\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ISSUE_ID=PROJ-456 PROVIDER=jira\n  /finalize-plan DRAFT_PATH=.agent/tmp/abc123-plan ISSUE_ID=TA-123 ASSIGNEE=user-uuid"
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Description

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
- `ISSUE_ID` - Issue ID to attach document/attachment and update state

### Options

- `PROVIDER` - Issue tracker provider when using `ISSUE_ID` (default: `linear`)
  - `linear` - Linear Issue ID (e.g., `TA-123`)
  - `jira` - Jira Issue key (e.g., `PROJ-456`)
- `ASSIGNEE` - Assignee for the issue (optional, only used with `ISSUE_ID`)
  - If not provided: Uses current user from `project-manage user`
  - Linear: User UUID
  - Jira: Account ID

## Process

### 1. Validate Input

1. Verify `DRAFT_PATH` exists and is readable
2. Verify exactly one output destination is provided (`ARTIFACT_DIR_PATH` or `ISSUE_ID`)
3. Read the draft file content and extract YAML frontmatter (title, issueId if present)
4. Resolve `PROVIDER` (if `ISSUE_ID` provided):
   - If `PROVIDER` parameter is explicitly provided, use it
   - If not provided, get from project-manage:
     ```
     skill: project-manage
     args: provider
     ```
     Use the returned provider value (or `linear` if project-manage not initialized)

### 2. Execute Output

#### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`:

1. Extract file name from temporary file path (remove random prefix)
   - `.agent/tmp/xxxxxxxx-plan` -> `plan`
2. Use `artifact` skill's `create` command to create artifact file
3. Copy content from draft file to the artifact file

#### If ISSUE_ID is provided

Route based on resolved PROVIDER:

| PROVIDER           | Reference Document                      |
| ------------------ | --------------------------------------- |
| `linear` (default) | `{baseDir}/references/linear-output.md` |
| `jira`             | `{baseDir}/references/jira-output.md`   |

**For Linear (default):**
Follow `{baseDir}/references/linear-output.md`:
1. Create Document using `linear-document` skill

**For Jira:**
Follow `{baseDir}/references/jira-output.md`:
1. Attach plan file to Jira issue
2. Add comment summarizing the plan

### 3. Update Issue Status (Common)

After saving the plan, update the issue status to "ready for implementation" state (just before "In Progress").

| Provider | Target State | Method |
|----------|-------------|--------|
| Linear | Todo | Query state ID via `linear-state`, then update via `linear-issue` |
| Jira | To Do | `jira-issue update ID={ISSUE_ID} STATE="To Do"` |

**Linear:**
1. Query Todo state ID:
   ```
   skill: linear:linear-state
   args: list ISSUE_ID={ISSUE_ID} NAME=Todo
   ```
2. Update issue state:
   ```
   skill: linear:linear-issue
   args: update ID={ISSUE_ID} STATE_ID={todo_state_id}
   ```

**Jira:**
```
skill: jira-issue
args: update ID={ISSUE_ID} STATE="To Do"
```

Notes:
- Jira workflows may vary per project ("To Do", "Open", "Backlog", etc.)
- The jira-issue skill handles transition ID matching internally

### 4. Assign Issue (ISSUE_ID output only)

Assign the issue to the specified user.

**Resolve Assignee:**

1. If `ASSIGNEE` parameter is not provided:
   ```
   skill: project-manage
   args: user
   ```
   Use the returned `id` field as assignee

2. If `ASSIGNEE` parameter is provided, use the value directly

**Execute Assignment:**

| Provider | Command |
|----------|---------|
| Linear | `skill: linear:linear-issue`<br>`args: update ID={ISSUE_ID} ASSIGNEE_ID={assignee_id}` |
| Jira | `skill: jira-issue`<br>`args: update ID={ISSUE_ID} ASSIGNEE={assignee_id}` |

### 5. Add to Active Sprint/Cycle (ISSUE_ID output only)

Attempt to add issue to active sprint/cycle. If none exists, skip silently.

Route based on provider:

| Provider | Reference Document |
|----------|-------------------|
| Linear | `{baseDir}/references/linear-cycle.md` |
| Jira | `{baseDir}/references/jira-sprint.md` |

**For Linear:**
1. Get issue's team ID
2. Query active cycle for the team
3. If active cycle exists, add issue to it

**For Jira:**
1. Get agile boards for the project
2. Query active sprint from the board
3. If active sprint exists, add issue to it

Notes:
- If no active sprint/cycle exists, skip silently (not an error)
- This step is informational - failure should not block the workflow

### 6. Report Result

Report the final output path or URL to the user.

## Output

SUCCESS:
- For Artifact output:
  - PLAN_PATH: Final plan file path (e.g., `.agent/artifacts/20260110/02_plan.md`)
- For Linear output (PROVIDER=linear):
  - DOCUMENT_URL: Linear document URL
  - ISSUE_ID: Updated issue ID (same as input)
- For Jira output (PROVIDER=jira):
  - ATTACHMENT_NAME: Attached filename
  - ISSUE_KEY: Jira issue key

ERROR: Error message string describing what failed

## Quality Checklist

Before completing, verify:

- [ ] Draft file exists and content was read successfully
- [ ] YAML frontmatter was parsed correctly (title extracted)
- [ ] Output destination was created successfully
- [ ] For Issue output: Issue state was updated to "ready for implementation" state (Todo/To Do)
- [ ] For Issue output: Issue was assigned to user (ASSIGNEE or current user)
- [ ] For Issue output: Sprint/Cycle assignment was attempted (skip silently if none active)
- [ ] Final output path/URL is reported to user

## Constraints

- Should NOT create or modify draft files (that is `draft-plan`'s responsibility)
- Should NOT validate plans (that is `plan-review`'s responsibility)
- Should NOT be called without user approval (except when `AUTO_ACCEPT=true` in workflow)
- Expects draft files in the format produced by `draft-plan`

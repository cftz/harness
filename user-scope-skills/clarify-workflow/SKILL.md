---
name: clarify-workflow
description: |
  Use this skill to clarify and refine requirements before implementation.

  Orchestrates requirements clarification by combining draft-clarify, clarify-review, and finalize-clarify skills with automated review loop and user approval.

  Args:
    Task Source (OneOf, Required):
      REQUEST="<text>" - User's requirement text
      ISSUE_ID=<id> - Issue ID (e.g., PROJ-123)
    Output Destination (OneOf, Optional):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      PROJECT_ID=<id> - Save as issues in project
      (If neither provided, uses project-manage to get current project)
    Options:
      PROVIDER=linear|jira - Issue tracker provider (default: linear)
      ASSIGNEE=<id|name|email|me> - Issue assignee (default: current user from project-manage)
      AUTO_ACCEPT=true - Skip user review (default: false)
      MAX_CYCLES=<n> - Maximum auto-fix cycles (default: 10)

  Examples:
    /clarify-workflow ISSUE_ID=TA-123
    /clarify-workflow ISSUE_ID=TA-123 PROJECT_ID=cops
    /clarify-workflow ISSUE_ID=PROJ-123 PROJECT_ID=MYPROJ PROVIDER=jira
    /clarify-workflow REQUEST="Add auth feature" ARTIFACT_DIR_PATH=.agent/artifacts/20260107
model: claude-opus-4-5
---

# Description

**IMPORTANT: Use this workflow when you need to clarify and refine requirements before implementation.**

Orchestrates the requirements clarification process by combining `draft-clarify`, `clarify-review`, and `finalize-clarify` skills. This skill runs automated validation via `clarify-review`, auto-fixes any issues, and then presents the approved results to the user for final confirmation before saving to the destination.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify where requirements come from:

- `REQUEST` - User's requirement text (free-form description)
- `ISSUE_ID` - Issue ID (e.g., `PROJ-123`)

### Output Destination (OneOf, Optional)

Provide one of the following to specify where clarified requirements are saved:

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- `PROJECT_ID` - Project ID or name

If neither is provided, get the current project from project-manage (passing resolved PROVIDER):

```
skill: project-manage
args: project PROVIDER=<provider>
```

### Optional

- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`. Only used with PROJECT_ID output.
- `ASSIGNEE` - User to assign issues to. For Linear: ID, name, email, or "me". For Jira: email or account ID.
  If not provided, get the current user from project-manage (passing resolved PROVIDER):
  ```
  skill: project-manage
  args: user PROVIDER=<provider>
  ```
- `AUTO_ACCEPT` - If set to `true`, skip user review at the end. Defaults to `false`.
- `MAX_CYCLES` - Maximum number of auto-fix cycles for clarify-review loop. Defaults to `10`.

> **Note:** When `ISSUE_ID` is provided as input, it is automatically passed as `PARENT_ISSUE_ID` to `finalize-clarify`, creating the resulting tasks as sub-issues under the original issue.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Validate Parameters                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Verify task source (REQUEST or ISSUE_ID)             │  │
│  │ Resolve output destination if not provided            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Call draft-clarify (with resume loop)               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-clarify                                  │  │
│  │ args: create REQUEST=... or create ISSUE_ID=...       │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│              ┌───────────────┴───────────────┐              │
│              │                               │              │
│          SUCCESS                          AWAIT             │
│              │                               │              │
│              ↓                               ↓              │
│  ┌────────────────────┐    ┌──────────────────────────┐   │
│  │ Returns:           │    │ 1. Load context file     │   │
│  │ PROMPT_PATH,       │    │ 2. AskUserQuestion       │   │
│  │ DRAFT_PATHS        │    │ 3. Fill answers in file  │   │
│  └────────────────────┘    │ 4. Call resume           │   │
│                            └──────────────────────────┘   │
│                                         │                  │
│                                         └──→ Loop until    │
│                                              SUCCESS        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Auto-review Loop (automated)                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ cycle_count++                                        │  │
│  │ Check MAX_CYCLES limit                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: clarify-review                                │  │
│  │ args: PROMPT_PATH=... DRAFT_PATHS=...                │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                    │                  │
│          Revision Needed              Approved             │
│                     │                    │                  │
│                     ↓                    │                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-clarify                                 │  │
│  │ args: modify DRAFT_PATHS=... FEEDBACK_PATH=<review>  │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                       │
│                     └───────────→ Loop back to cycle++      │
└─────────────────────────────────────────────────────────────┘
                              │ Approved
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 4: User Review Loop (skip if AUTO_ACCEPT=true)        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Display clarify-review result (Approved document)     │  │
│  │ Display draft contents from DRAFT_PATHS               │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ AskUserQuestion: Approve or Request Changes?          │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                    │                  │
│          Request Changes              Approve              │
│                     │                    │                  │
│                     ↓                    │                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Revise drafts based on feedback                       │  │
│  │ (draft-clarify modify → clarify-review → loop)        │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                       │
│                     └───────────→ Back to Step 3            │
└─────────────────────────────────────────────────────────────┘
                              │ Approve
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Call finalize-clarify (only after approval)        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: finalize-clarify                               │  │
│  │ args: DRAFT_PATHS=... [ARTIFACT_DIR_PATH=... or       │  │
│  │       PROJECT_ID=...] [PARENT_ISSUE_ID=...] [ASSIGNEE=...]│
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Returns: Final output paths or Linear issue IDs       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Process

### 1. Validate Parameters

1. Verify that exactly one of `REQUEST` or `ISSUE_ID` is provided
2. Resolve `PROVIDER`:
   - If `PROVIDER` parameter is explicitly provided, use it
   - If not provided, get from project-manage:
     ```
     skill: project-manage
     args: provider
     ```
     Use the returned provider value (or `linear` if project-manage not initialized)
3. If neither `ARTIFACT_DIR_PATH` nor `PROJECT_ID` is provided:
   - Get current project from project-manage (pass resolved PROVIDER):
     ```
     skill: project-manage
     args: project PROVIDER=<provider>
     ```
   - Store the resolved project for use in Step 5
4. Initialize `cycle_count = 0` and `cycle_history = []` for tracking

### 2. Call draft-clarify Skill (with Resume Loop)

Invoke the `draft-clarify` skill with the task source:

```
# For REQUEST input:
skill: draft-clarify
args: create REQUEST=<text> PROVIDER=<provider>

# For ISSUE_ID input:
skill: draft-clarify
args: create ISSUE_ID=<id> PROVIDER=<provider>
```

> **Note**: Always pass the resolved `PROVIDER` value to draft-clarify to ensure consistent provider handling across the workflow.

#### Handle Return Status

The skill returns one of the following statuses per output-format rule:

**SUCCESS** - Skill finished successfully:
- `PROMPT_PATH` - Path to the prompt file containing the original request
- `DRAFT_PATHS` - Comma-separated paths to the draft task documents
- Proceed to Step 3

**AWAIT** - Skill needs user input:
- `CONTEXT_PATH` - Path to the saved context file
- Enter the resume loop (see below)

**ERROR** - Skill failed:
- Error message describing the failure
- Report error and exit workflow

#### Resume Loop for AWAIT

When draft-clarify returns `AWAIT`:

1. Load context using `checkpoint load`
2. Convert questions to `AskUserQuestion` format
3. Fill answers in context file
4. Validate with `checkpoint update`
5. Resume with `draft-clarify resume CONTEXT_PATH=...`

Loop until SUCCESS. Store `PROMPT_PATH` for use in revision loops.

### 3. Auto-review Loop

This step runs automatically without user interaction.

1. **Increment Cycle Count**
   ```
   cycle_count++
   ```

2. **Check MAX_CYCLES Limit**
   - If `cycle_count > MAX_CYCLES`:
     - Report failure with cycle history
     - Exit workflow with error

3. **Call clarify-review**
   ```
   skill: clarify-review
   args: PROMPT_PATH=<prompt_path> DRAFT_PATHS=<draft_paths>
   ```
   - Review result is saved to a temp file (no ARTIFACT_DIR_PATH)
   - Store the review result path as `REVIEW_PATH`

4. **Check Review Result**
   - Parse the review document to determine status
   - If **Approved**:
     - Record in cycle_history: `{cycle: N, result: "Approved"}`
     - Proceed to Step 4 (User Review Loop)
   - If **Revision Needed**:
     - Extract violation count from review document
     - Record in cycle_history: `{cycle: N, result: "Revision Needed", violations: count}`
     - Call draft-clarify modify:
       ```
       skill: draft-clarify
       args: modify DRAFT_PATHS=<paths> FEEDBACK_PATH=<review_path> PROMPT_PATH=<prompt_path>
       ```
     - Return to step 1 (Increment Cycle Count)

### 4. User Review Loop

> If `AUTO_ACCEPT=true`, skip this step and proceed directly to Step 5.

1. **Display Review Result**
   - Read and display the clarify-review Approved document
   - Highlight the Quality Score section

2. **Display Draft Content**
   - Read and display the content of each file in `DRAFT_PATHS` to the user
   - Present them clearly with proper formatting

3. **Request User Decision**
   - Use `AskUserQuestion` with the following options:
   ```
   AskUserQuestion:
     question: "Clarify-review passed. Do you approve these requirement documents?"
     header: "Requirements Review"
     options:
       - label: "Approve"
         description: "Approve requirements and generate final output"
       - label: "Request Changes"
         description: "Provide feedback to revise the documents"
   ```

4. **Handle User Response**
   - If user selects **"Approve"**: Proceed to Step 5
   - If user selects **"Request Changes"**:
     a. Wait for user feedback
     b. Revise the temporary files by invoking draft-clarify with modify command:
        ```
        skill: draft-clarify
        args: modify DRAFT_PATHS=<paths> FEEDBACK="<user_feedback>" PROMPT_PATH=<prompt_path>
        ```
        Note: Pass `PROMPT_PATH` to ensure revisions remain aligned with the original request.
     c. Return to Step 3 (Auto-review Loop) to re-validate the changes

### 5. Call finalize-clarify Skill

Once the review is approved, invoke the `finalize-clarify` skill:

- If `ARTIFACT_DIR_PATH` is provided:
  ```
  skill: finalize-clarify
  args: DRAFT_PATHS=<paths> ARTIFACT_DIR_PATH=<artifact_path>
  ```

- If `PROJECT_ID` is provided (or resolved in Step 1):
  ```
  skill: finalize-clarify
  args: DRAFT_PATHS=<paths> PROJECT_ID=<project_id> PROVIDER=<provider> [PARENT_ISSUE_ID=<issue_id>] [ASSIGNEE=<assignee>]
  ```
  - Pass `PROVIDER` parameter to finalize-clarify
  - If original input was `ISSUE_ID`, pass it as `PARENT_ISSUE_ID` to create sub-issues
  - If `ASSIGNEE` was provided, pass it to finalize-clarify

### 6. Report Result

Output the result from the `finalize-clarify` skill, including:
- Final output locations (artifact paths or Linear issue IDs)
- Summary of created tasks
- Cycle summary (number of auto-fix cycles)

## Output

SUCCESS:
- OUTPUT_LOCATION: Final output location (artifact directory path or project ID)
- PROVIDER: Issue tracker provider used (linear or jira), only for PROJECT_ID output
- TASKS_CREATED: List of created task paths or issue IDs
- CYCLE_COUNT: Number of auto-fix cycles
- CYCLE_HISTORY: Summary of each cycle result

ERROR: Error message string

### Output Report Format

When completing successfully, present results to user:

```
## Clarify Complete

- **Status**: Success
- **Output Location**: [artifact directory or Linear project]
- **Cycles**: {N} auto-fix cycle(s)

### Cycle Summary
| Cycle | Result          | Violations |
| ----- | --------------- | ---------- |
| 1     | Revision Needed | 3          |
| 2     | Approved        | -          |

[If artifact]:
Tasks saved to artifact directory:
- .agent/artifacts/YYYYMMDD-HHMMSS/01_task1.md
- .agent/artifacts/YYYYMMDD-HHMMSS/02_task2.md

[If Linear]:
Issues created:
- TA-124: Task 1 (blockedBy: none)
- TA-125: Task 2 (blockedBy: TA-124)

[If Jira]:
Issues created:
- PROJ-124: Task 1 (blockedBy: none)
- PROJ-125: Task 2 (blockedBy: PROJ-124)
```

## Quality Checklist

Before completing, verify:

- [ ] **Task source validated**: Exactly one of REQUEST or ISSUE_ID provided
- [ ] **Output destination resolved**: Either provided or resolved via project-manage
- [ ] **Drafts created**: draft-clarify skill completed successfully
- [ ] **Auto-review passed**: clarify-review returned Approved status
- [ ] **Cycle limit respected**: Auto-fix loop did not exceed MAX_CYCLES
- [ ] **User review completed**: User explicitly approved (or AUTO_ACCEPT=true)
- [ ] **Final output saved**: finalize-clarify skill completed successfully
- [ ] **Result reported**: Output locations and cycle summary communicated to user

## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- Gather requirements directly (delegated to draft-clarify)
- Validate requirements directly (delegated to clarify-review)
- Write to final destinations (delegated to finalize-clarify)
- Handle output format logic (handled by finalize-clarify)

### Dependent Skills

This skill requires the following skills to exist:
- `draft-clarify` - Creates draft task documents in temporary files
- `clarify-review` - Validates drafts against rules and original request
- `finalize-clarify` - Saves approved tasks to final destination (supports Linear and Jira)
- `project-manage` - Resolves default project and user (provider-agnostic)
- `checkpoint` - Manages interruptible checkpoint files for resume support

### Three-Phase Workflow

This skill enforces a strict three-phase workflow:
1. **Draft Phase**: Work is done in temporary files only (via draft-clarify)
2. **Review Phase**: Automated validation with auto-fix loop (via clarify-review)
3. **Finalize Phase**: Only after user approval, content is saved to final destination (via finalize-clarify)

**Anti-patterns to avoid:**
- Calling finalize-clarify before user approval
- Skipping the auto-review step
- Skipping the user review step (unless AUTO_ACCEPT=true)
- Assuming approval without explicit user confirmation
- Passing incomplete parameters to atomic skills
- Requesting user approval during each auto-fix cycle (the loop is automated)

### Plan Mode Interaction

This skill produces **requirements documents**, NOT implementation plans. Even if Plan mode is active:

1. **Do NOT write implementation details to the plan file** - No "Critical Files to Modify", "New Files to Create", or "Verification" sections
2. **The plan file should only summarize the clarify output** - List created issues/tasks with their dependencies
3. **Implementation planning is handled by the `/plan` skill** - This skill's job ends when issues are created

**Example plan file content after clarify:**
```markdown
# Clarify Results

Created Linear issues:
- TA-123: Task A (blockedBy: none)
- TA-124: Task B (blockedBy: TA-123)
- TA-125: Task C (blockedBy: TA-123)
```

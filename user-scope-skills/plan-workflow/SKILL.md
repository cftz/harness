---
name: plan-workflow
description: "Orchestrates plan creation by combining draft-plan, plan-review, and finalize-plan skills with automated review loop and user approval.\n\nArgs:\n  Task Source (OneOf, Required):\n    TASK_PATH=<path> - Task document path\n    ISSUE_ID=<id> - Linear Issue ID (e.g., TA-123)\n  Output (Optional):\n    ARTIFACT_DIR_PATH=<path> - Save to artifact directory (If omitted with ISSUE_ID, saves as Linear Document)\n  Options:\n    AUTO_ACCEPT=true - Skip user review (default: false)\n    MAX_CYCLES=<n> - Maximum auto-fix cycles (default: 10)\n\nExamples:\n  /plan-workflow ISSUE_ID=TA-123\n  /plan-workflow ISSUE_ID=TA-123 ARTIFACT_DIR_PATH=.agent/artifacts/20260107\n  /plan-workflow TASK_PATH=.agent/tmp/task.md ARTIFACT_DIR_PATH=.agent/artifacts/20260107"
model: claude-opus-4-5
---

# Plan Workflow Skill

Orchestrates the plan creation process by combining `draft-plan`, `plan-review`, and `finalize-plan` skills. This skill runs automated validation via `plan-review`, auto-fixes any issues, and then presents the approved results to the user for final confirmation before saving to the destination.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify where requirements come from:

- `TASK_PATH` - Path to a task document (e.g., `.agent/artifacts/20260105/01_task.md`)
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

### Output Destination (Optional)

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)

If not provided and `ISSUE_ID` is provided, the plan will be saved as a Document attached to the Issue in Linear.

> **Note**: If `TASK_PATH` is used without `ARTIFACT_DIR_PATH`, notify the user that an output destination is required and ask them to provide `ARTIFACT_DIR_PATH`.

### Optional

- `AUTO_ACCEPT` - If set to `true`, skip user review at the end. Defaults to `false`.
- `MAX_CYCLES` - Maximum number of auto-fix cycles for plan-review loop. Defaults to `10`.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Validate Parameters                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Verify task source (TASK_PATH or ISSUE_ID)           │  │
│  │ Initialize cycle_count = 0, cycle_history = []        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Call draft-plan (with resume loop)                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-plan                                     │  │
│  │ args: create TASK_PATH=... or create ISSUE_ID=...     │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│              ┌───────────────┴───────────────┐              │
│              │                               │              │
│           SUCCESS                         AWAIT             │
│              │                               │              │
│              ↓                               ↓              │
│  ┌────────────────────┐    ┌──────────────────────────┐   │
│  │ Returns:           │    │ 1. Load context file     │   │
│  │ DRAFT_PATH         │    │ 2. AskUserQuestion       │   │
│  └────────────────────┘    │ 3. Fill answers in file  │   │
│                            │ 4. Call resume           │   │
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
│  │ skill: plan-review                                    │  │
│  │ args: PLAN_PATH=<draft_path>                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                    │                  │
│          Revision Needed              Approved             │
│                     │                    │                  │
│                     ↓                    │                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-plan                                     │  │
│  │ args: modify DRAFT_PATH=... FEEDBACK_PATH=<review>    │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                       │
│                     └───────────→ Loop back to cycle++      │
└─────────────────────────────────────────────────────────────┘
                              │ Approved
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 4: User Review Loop (skip if AUTO_ACCEPT=true)        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Display plan-review result (Approved document)        │  │
│  │ Display draft contents from DRAFT_PATH                │  │
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
│  │ Revise draft based on feedback                        │  │
│  │ (draft-plan modify → plan-review → loop)              │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                       │
│                     └───────────→ Back to Step 3            │
└─────────────────────────────────────────────────────────────┘
                              │ Approve
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Finalize Plan (only after approval)                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: finalize-plan                                  │  │
│  │ args: DRAFT_PATH=... [ARTIFACT_DIR_PATH=... or        │  │
│  │       ISSUE_ID=...]                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Returns: Final output path or Linear Document ID      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Process

### 1. Validate Parameters

1. Verify that exactly one of `TASK_PATH` or `ISSUE_ID` is provided
2. If `TASK_PATH` is used without `ARTIFACT_DIR_PATH`:
   - Notify the user: "Output destination is required when using TASK_PATH"
   - Ask user to provide `ARTIFACT_DIR_PATH`
3. Initialize `cycle_count = 0` and `cycle_history = []` for tracking

### 2. Call draft-plan Skill (with Resume Loop)

Invoke the `draft-plan` skill with the task source:

```
# For TASK_PATH input:
skill: draft-plan
args: create TASK_PATH=<path>

# For ISSUE_ID input:
skill: draft-plan
args: create ISSUE_ID=<id>
```

#### Handle Return Status

The skill returns one of two statuses:

**SUCCESS** - Skill finished successfully:
- `DRAFT_PATH` - Path to the temporary file containing the draft plan
- Proceed to Step 3

**AWAIT** - Skill needs user input:
- `CONTEXT_PATH` - Path to the saved context file
- `QUESTIONS` - Array of questions requiring answers (e.g., package selection, architecture decisions)
- Enter the resume loop (see below)

#### Resume Loop for AWAIT

When draft-plan returns `AWAIT`:

1. **Load Context**
   ```
   skill: context
   args: load CONTEXT_PATH=<context_path>
   ```
   Extract pending questions from the context.

2. **Collect User Answers**
   Convert each question to `AskUserQuestion` format and collect answers:
   ```
   AskUserQuestion:
     question: "{question.question}"
     header: "{question.header}"
     options: {question.options}
   ```

3. **Fill Answers in Context File**
   For each answered question, edit the context file to fill the `**Answer**:` field:
   ```
   Edit the context file at CONTEXT_PATH:
   - Find "### Q{N}: {question}"
   - Replace empty "**Answer**:" with "**Answer**: {user_answer}"
   ```

4. **Validate Context**
   ```
   skill: context
   args: update CONTEXT_PATH=<context_path>
   ```
   Ensure all questions have answers filled in.

5. **Resume Skill**
   ```
   skill: draft-plan
   args: resume CONTEXT_PATH=<context_path>
   ```

6. **Check Return Status**
   - If `SUCCESS`: Extract `DRAFT_PATH`, proceed to Step 3
   - If `AWAIT`: Loop back to step 1 with new context

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

3. **Call plan-review**
   ```
   skill: plan-review
   args: PLAN_PATH=<draft_path>
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
     - Call draft-plan modify:
       ```
       skill: draft-plan
       args: modify DRAFT_PATH=<path> FEEDBACK_PATH=<review_path>
       ```
     - Return to step 1 (Increment Cycle Count)

### 4. User Review Loop

> If `AUTO_ACCEPT=true`, skip this step and proceed directly to Step 5.

1. **Display Review Result**
   - Read and display the plan-review Approved document
   - Highlight the Quality Score section

2. **Display Draft Content**
   - Read and display the content of `DRAFT_PATH` to the user
   - Present it clearly with proper formatting

3. **Request User Decision**
   - Use `AskUserQuestion` with the following options:
   ```
   AskUserQuestion:
     question: "Plan-review passed. Do you approve this plan?"
     header: "Plan Review"
     options:
       - label: "Approve"
         description: "Approve the plan and save to final destination"
       - label: "Request Changes"
         description: "Provide feedback to revise the plan"
   ```

4. **Handle User Response**
   - If user selects **"Approve"**: Proceed to Step 5
   - If user selects **"Request Changes"**:
     a. Wait for user feedback
     b. Revise the temporary file by invoking draft-plan with modify command:
        ```
        skill: draft-plan
        args: modify DRAFT_PATH=<path> FEEDBACK="<user_feedback>"
        ```
     c. Return to Step 3 (Auto-review Loop) to re-validate the changes

### 5. Call finalize-plan Skill

Once the plan is approved, invoke the `finalize-plan` skill:

- If `ARTIFACT_DIR_PATH` is provided:
  ```
  skill: finalize-plan
  args: DRAFT_PATH=<draft_path> ARTIFACT_DIR_PATH=<artifact_path>
  ```

- Else if `ISSUE_ID` is provided:
  ```
  skill: finalize-plan
  args: DRAFT_PATH=<draft_path> ISSUE_ID=<issue_id>
  ```

### 6. Report Result

Output the result from the `finalize-plan` skill, including:
- Final output location (artifact path or Linear Document ID)
- Summary of the plan
- Cycle summary (number of auto-fix cycles)

## Output

SUCCESS:
- OUTPUT_LOCATION: Final output path (artifact file or Linear Document ID)
- PLAN_TITLE: Title from the plan
- CYCLES: Number of auto-fix cycles completed
- CYCLE_HISTORY: Array of cycle results

AWAIT: Not applicable (this workflow skill does not suspend)

ERROR: Error message string (e.g., "MAX_CYCLES exceeded", "finalize-plan failed: ...")

### Success Report Format

When the workflow completes successfully, report to the user:

```
STATUS: SUCCESS
OUTPUT:
  OUTPUT_LOCATION: {artifact path or Linear Document ID}
  PLAN_TITLE: {title from the plan}
  CYCLES: {N}
  CYCLE_HISTORY:
    - cycle: 1, result: Revision Needed, violations: 3
    - cycle: 2, result: Approved

## Plan Workflow Complete

- **Output Location**: [artifact path or Linear Document ID]
- **Plan Title**: [title from the plan]
- **Cycles**: {N} auto-fix cycle(s)

### Cycle Summary
| Cycle | Result          | Violations |
| ----- | --------------- | ---------- |
| 1     | Revision Needed | 3          |
| 2     | Approved        | -          |

[If artifact]: File saved to: .agent/artifacts/YYYYMMDD-HHMMSS/NN_plan.md
[If Linear]: Document attached to issue: [ISSUE_ID]
```

### Error Report Format

When the workflow fails:

```
STATUS: ERROR
OUTPUT: {error message}
```

## Quality Checklist

Before completing, verify:

- [ ] **Task source validated**: Exactly one of TASK_PATH or ISSUE_ID provided
- [ ] **Draft created**: draft-plan skill completed successfully
- [ ] **Auto-review passed**: plan-review returned Approved status
- [ ] **Cycle limit respected**: Auto-fix loop did not exceed MAX_CYCLES
- [ ] **User review completed**: User explicitly approved (or AUTO_ACCEPT=true)
- [ ] **Final output saved**: finalize-plan skill completed successfully
- [ ] **Result reported**: Output location and cycle summary communicated to user

## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- Read requirements directly (delegated to draft-plan)
- Validate plans directly (delegated to plan-review)
- Write to final destinations (delegated to finalize-plan)
- Make architectural decisions (handled by draft-plan)

### Dependent Skills

This skill requires the following skills to exist:
- `draft-plan` - Creates draft plan in temporary file
- `plan-review` - Validates drafts against rules
- `finalize-plan` - Saves approved plan to final destination
- `context` - Manages interruptible context files for resume support

### Three-Phase Workflow

This skill enforces a strict three-phase workflow:
1. **Draft Phase**: Work is done in temporary files only (via draft-plan)
2. **Review Phase**: Automated validation with auto-fix loop (via plan-review)
3. **Finalize Phase**: Only after user approval, content is saved to final destination (via finalize-plan)

**Anti-patterns to avoid:**
- Calling finalize-plan before user approval
- Skipping the auto-review step
- Skipping the user review step (unless AUTO_ACCEPT=true)
- Assuming approval without explicit user confirmation
- Requesting user approval during each auto-fix cycle (the loop is automated)

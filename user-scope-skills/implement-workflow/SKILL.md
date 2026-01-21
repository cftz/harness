---
name: implement-workflow
description: |
  Use this skill to execute a complete implementation cycle with automated code review and iterative fixes.

  Orchestrates implementation by combining implement, code-review, fix, and finalize-implement skills with automated review loop.

  Args:
    Task Source (OneOf, Required):
      ISSUE_ID=<id> - Linear Issue ID (e.g., TA-123)
      PLAN_PATH=<path> + TASK_PATH=<path> - Local plan and requirements files
    Output (Optional):
      ARTIFACT_DIR_PATH=<path> - Save review documents to artifact directory
    Options:
      AUTO_ACCEPT=true - Skip user approval on Pass (default: false)
      BRANCH=<name> - Base branch for PR target in finalize-implement (default: main)
      MAX_CYCLES=<n> - Maximum fix cycles (default: 10)

  Examples:
    /implement-workflow ISSUE_ID=TA-123
    /implement-workflow ISSUE_ID=TA-123 AUTO_ACCEPT=true
    /implement-workflow PLAN_PATH=.agent/artifacts/20260107/02_plan.md TASK_PATH=.agent/artifacts/20260107/01_task.md ARTIFACT_DIR_PATH=.agent/artifacts/20260107
model: claude-opus-4-5

---

# Implement Workflow Skill

Orchestrates a complete implementation cycle from plan execution through code review and iterative fixes until the code passes review. This skill manages the automated review loop between implementation and code review, with user approval only at the final result.

## Important: DO / DON'T

**DO:**
- Invoke `/implement execute` skill for implementation
- Invoke `/code-review` skill for code review
- Invoke `/implement fix` skill for fixing violations
- Invoke `/finalize-implement` skill for commit/push/PR

**DON'T:**
- Edit code files directly (use Edit, Write tools)
- Read plan documents and implement yourself
- Make implementation decisions - delegate to `implement` skill

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify the implementation source:

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`). Plan from attached Document, requirements from description.
- `PLAN_PATH` + `TASK_PATH` - Local plan and task files for artifact-based workflows.

### Output Destination (Optional)

- `ARTIFACT_DIR_PATH` - Artifact directory path for saving review documents (e.g., `.agent/artifacts/20260105-120000`)

If not provided:
- With `ISSUE_ID`: Review documents are saved as Linear Documents attached to the issue
- With `PLAN_PATH + TASK_PATH`: **Required** - must provide `ARTIFACT_DIR_PATH`

### Options

- `AUTO_ACCEPT` - If set to `true`, skip user approval on final Pass. Defaults to `false`.
- `BRANCH` - Base branch for PR target in finalize-implement. Defaults to `main`.
- `MAX_CYCLES` - Maximum number of fix cycles before aborting. Defaults to `10`.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Validate Parameters                                 │
│  - Verify exactly one task source provided                  │
│  - Ensure ARTIFACT_DIR_PATH if using local files            │
│  - Initialize cycle_count = 0                               │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Execute Implementation                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: implement                                      │  │
│  │ args: execute ISSUE_ID=... or PLAN_PATH=...+TASK_PATH │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Code Review Loop                                    │
│  ┌────────────────────────────────────────────────────────┐│
│  │ LOOP:                                                   ││
│  │   1. cycle_count++                                      ││
│  │   2. Check MAX_CYCLES limit                             ││
│  │   3. Run code-review (USE_TEMP=true)                    ││
│  │   4. If Pass → EXIT LOOP                                ││
│  │   5. If Changes Required → Run implement fix            ││
│  │   6. CONTINUE LOOP                                      ││
│  └────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                               │ Pass
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Final User Approval (skip if AUTO_ACCEPT=true)      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ AskUserQuestion: Approve or Request Changes?          │  │
│  └──────────────────────────────────────────────────────┘  │
│       │                              │                      │
│    Approve                   Request Changes                │
│       │                              │                      │
│       ▼                              ▼                      │
│   Proceed                    Additional fix cycle           │
│                              (return to Step 3)             │
└─────────────────────────────────────────────────────────────┘
                               │ Approve
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Finalize Implementation                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: finalize-implement                             │  │
│  │ args: ISSUE_ID=<id> BRANCH=<name>                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  - Commit changes (idempotent)                              │
│  - Push to remote (idempotent)                              │
│  - Create PR (feature branch only, idempotent)              │
│  - Update Linear state (if ISSUE_ID provided)               │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 6: Report Result                                       │
│  - Summary of cycles completed                              │
│  - Files modified                                           │
│  - Verification status                                      │
│  - Finalize result (PR URL, Linear state)                   │
└─────────────────────────────────────────────────────────────┘
```

## Process

### 1. Validate Parameters

1. Verify that exactly one of:
   - `ISSUE_ID` is provided, OR
   - `PLAN_PATH` AND `TASK_PATH` are both provided

2. If `PLAN_PATH + TASK_PATH` are used without `ARTIFACT_DIR_PATH`:
   - Notify user: "Output destination is required when using PLAN_PATH + TASK_PATH"
   - Ask user to provide `ARTIFACT_DIR_PATH`

3. Initialize tracking variables:
   - `cycle_count = 0`
   - `cycle_history = []` (to track violations per cycle)

### 2. Execute Implementation

Invoke the `implement` skill with the execute command:

```
# For ISSUE_ID input:
skill: implement
args: execute ISSUE_ID=<id>

# For local files:
skill: implement
args: execute PLAN_PATH=<path> TASK_PATH=<path>
```

**On failure**: Report the error to user and abort workflow.

### 3. Code Review Loop

```
LOOP:
  1. Increment cycle_count

  2. Check cycle limit:
     If cycle_count > MAX_CYCLES:
       - Report error: "Maximum fix cycles ({MAX_CYCLES}) exceeded"
       - Include summary of persistent violations from cycle_history
       - Abort workflow

  3. Run code-review:
     # For ISSUE_ID:
     skill: code-review
     args: ISSUE_ID=<id> USE_TEMP=true

     # For ARTIFACT_DIR_PATH:
     skill: code-review
     args: ARTIFACT_DIR_PATH=<path> USE_TEMP=true

  4. Check result:
     If status == "Pass":
       - Record cycle in cycle_history: {cycle: N, violations: 0, result: "Pass"}
       - EXIT LOOP (proceed to Step 4)

     If status == "Changes Required":
       - Extract violation count from review document
       - Record cycle in cycle_history: {cycle: N, violations: count, result: "Changes Required"}
       - Extract REVIEW_PATH from code-review output

  5. Run implement fix:
     # For ISSUE_ID:
     skill: implement
     args: fix ISSUE_ID=<id>

     # For local files with explicit REVIEW_PATH:
     skill: implement
     args: fix PLAN_PATH=<path> REVIEW_PATH=<review_path>

  6. On fix failure:
     - Report error to user
     - Abort workflow

  7. CONTINUE LOOP
```

**Key design decisions:**
- `USE_TEMP=true` is passed to code-review during the loop to save review results to temp files
- User approval is handled at the workflow level after the final Pass result

### 4. Final User Approval

> Skip this step if `AUTO_ACCEPT=true`

Once code-review returns Pass:

1. Display summary to user:
   - Total cycles completed
   - Files modified
   - Final review status

2. Request user confirmation:
   ```
   AskUserQuestion:
     question: "Implementation passed code review. Would you like to approve?"
     header: "Implementation Complete"
     options:
       - label: "Approve"
         description: "Accept the implementation"
       - label: "Request Additional Changes"
         description: "Provide feedback for another fix cycle"
   ```

3. Handle response:
   - If **Approve**: Proceed to Step 5
   - If **Request Additional Changes**:
     - Wait for user to provide feedback
     - Create a temporary review document with user's feedback as violations
     - Run `implement fix` with user feedback as review source
     - Return to Step 3 (code review loop)

### 5. Finalize Implementation

> Only execute after Step 4 approval (or AUTO_ACCEPT=true)

Invoke the `finalize-implement` skill:

```
# For ISSUE_ID input (full flow with Linear):
skill: finalize-implement
args: ISSUE_ID=<id> BRANCH=<branch>

# For local files (PLAN_PATH + TASK_PATH) - Git ops only:
skill: finalize-implement
args: BRANCH=<branch>
```

**Key points:**
- `BRANCH` specifies the PR target branch (default: main)
- For local file workflows: Git ops only, Linear update skipped

**On failure:**
- Report the error with git operation that failed
- Provide suggestion for manual resolution

### 6. Report Result

Output the final result to user.

## Output Format

### Success Output

```markdown
## Implement Workflow Complete

- **Status**: Success
- **Cycles**: {N} fix cycle(s)
- **Source**: {ISSUE_ID or "Artifact"}

### Files Modified

- `path/to/file1.go`
- `path/to/file2.go`
- `path/to/file3_test.go`

### Verification

- Build: {checkmark}
- Tests: {checkmark}
- Code Review: Pass

### Cycle Summary

| Cycle | Violations Found | Violations Fixed |
| ----- | ---------------- | ---------------- |
| 1     | 3                | 3                |
| 2     | 1                | 1                |
| 3     | 0 (Pass)         | -                |

### Finalize Result

| Operation    | Status                | Details       |
| ------------ | --------------------- | ------------- |
| Commit       | {Created/Skipped}     | {commit_hash} |
| Push         | {Pushed/Skipped}      | {branch_name} |
| Pull Request | {Created/Skipped/N/A} | {pr_url}      |
| Linear State | {Updated/Skipped/N/A} | {state_name}  |

- **PR URL**: {pr_url} (if feature branch)
- **Linear Issue**: {linear_url} → {final_state} (if ISSUE_ID provided)

### Output Location

[If Artifact]: Review document: .agent/artifacts/20260107/03_review.md
[If Linear]: Review document attached to: TA-123
```

### Failure Output

```markdown
## Implement Workflow Failed

- **Status**: Failed
- **Stage**: {stage where failure occurred}
- **Cycles Completed**: {cycle_count}

### Error

{Error description}

### Suggestion

{Recommended action to resolve}

### Cycle History

| Cycle | Violations Found | Result |
| ----- | ---------------- | ------ |
| 1     | 5                | Fixed  |
| 2     | 3                | Fixed  |
| ...   | ...              | ...    |

### Files Modified Before Failure

- `path/to/file1.go` (may be partially complete)
```

## Quality Checklist

Before completing, verify:

- [ ] **Parameters validated**: Exactly one task source provided
- [ ] **Implementation executed**: implement skill completed successfully
- [ ] **Code review passed**: Loop exited with Pass status
- [ ] **User approval obtained**: User explicitly approved (or AUTO_ACCEPT=true)
- [ ] **Finalization completed**: Git operations and Linear update done (if ISSUE_ID provided)
- [ ] **Result reported**: Final status, PR URL, and output location communicated to user

## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- Read plan/task documents directly (delegated to implement skill)
- Write review documents (delegated to code-review skill)
- Make implementation decisions (handled by implement skill)

### Dependent Skills

This skill requires the following skills to exist:
- `implement` - Executes implementation and fixes code
- `code-review` - Validates implementations against project rules
- `finalize-implement` - Commits, pushes, creates PR, updates Linear state

### Automated Review Loop

This skill differs from `plan-workflow` and `clarify-workflow` in that:
- User approval happens only at the **end** (when Pass), not during drafting
- The loop is between code-review and implement fix, fully automated
- `USE_TEMP=true` is passed to code-review during the loop

**Anti-patterns to avoid:**
- Requesting user approval during each fix cycle
- Stopping the loop before code-review returns Pass
- Skipping code-review after implement execute

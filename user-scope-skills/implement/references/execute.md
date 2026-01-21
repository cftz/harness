# Execute Command

Executes implementation from a plan document. This is the default command for initial implementation.

## Parameters

### Source (OneOf, Required)

Provide one of the following to specify where the plan and requirements come from:

**Option A: Local Files**
- `PLAN_PATH` - Path to a plan document (e.g., `.agent/artifacts/20260107/02_plan.md`)
- `TASK_PATH` - Path to a task/requirements document (e.g., `.agent/artifacts/20260107/01_task.md`)

Both must be provided together.

**Option B: Linear Issue**
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
  - Plan: Retrieved from Document attached to the issue
  - Requirements: Retrieved from issue description

## Process

### 1. Read Plan and Requirements

**If `ISSUE_ID` is provided:**
Read [Linear Task Document]({baseDir}/references/linear-task.md) to fetch both:
- Plan document from attached Linear Document
- Requirements from issue description

**If `PLAN_PATH` + `TASK_PATH` are provided:**
- Read the plan file from `PLAN_PATH`
- Read the requirements file from `TASK_PATH`

Thoroughly understand:
- What needs to be implemented (from plan)
- Acceptance Criteria to verify against (from requirements)
- Implementation steps and their order
- Function signatures and algorithms specified
- Success criteria

**Error Handling:**
- If `ISSUE_ID` is provided but no Document is attached: Report error and ask user to attach a plan document first
- If `PLAN_PATH` file doesn't exist: Report the missing file path and exit
- If `TASK_PATH` file doesn't exist: Report the missing file path and exit
- If issue description is empty: Report that requirements are missing and exit

### 2. Update Issue State to In Progress

> Skip this step if `ISSUE_ID` is not provided (i.e., using local files)

Update the Linear issue state to indicate work has started:

1. Get current issue state:
   ```
   skill: linear-issue
   args: get ID={ISSUE_ID}
   ```

2. If current state is already "In Progress":
   - Log: "Issue already In Progress, skipping update"
   - Proceed to next step

3. Get state ID for "In Progress":
   ```
   skill: linear-state
   args: list ISSUE_ID={ISSUE_ID} NAME=In Progress
   ```

4. Update issue state:
   ```
   skill: linear-issue
   args: update ID={ISSUE_ID} STATE_ID={state_id}
   ```

5. Log: "Updated issue state to In Progress"

### 3. Install Dependencies

If the plan specifies external dependencies to install:
- Install each dependency using the appropriate package manager command
- Do NOT manually edit dependency files (go.mod, package.json, etc.)
- Verify installation success before proceeding

### 4. Read Prerequisite Files

If the plan lists files to read before implementation:
- Read all specified rule files
- Read all specified reference implementation files
- Understand the patterns and conventions before coding

### 5. Implement According to Plan

For each implementation step in the plan:
- Create or modify files exactly as specified
- Implement functions with the exact signatures provided
- Follow the algorithm comments/outline in the plan
- Do NOT add extra features, helpers, or optimizations not in the plan
- Do NOT create constants or variables not specified in the plan

**If instructions are unclear**: You MUST use `AskUserQuestion` to ask for clarification. Do not guess or make assumptions.

### 6. Verify Success Criteria

If the plan defines success criteria:
- Run specified build commands
- Run specified test commands
- Verify all criteria are met
- If any criterion fails, continue working to fix it

Additionally, verify against the Acceptance Criteria from the requirements document:
- Check that each AC item is satisfied by the implementation
- If any AC cannot be verified, note it in the output

## Output

See [Output Format]({baseDir}/SKILL.md#output) in main skill documentation.

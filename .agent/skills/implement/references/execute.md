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

## Usage Examples

```bash
# From Linear Issue (plan from attached Document, requirements from description)
/implement execute ISSUE_ID=TA-123

# From local files
/implement execute PLAN_PATH=.agent/artifacts/20260107/02_plan.md TASK_PATH=.agent/artifacts/20260107/01_task.md
```

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

### 2. Install Dependencies

If the plan specifies external dependencies to install:
- Install each dependency using the appropriate package manager command
- Do NOT manually edit dependency files (go.mod, package.json, etc.)
- Verify installation success before proceeding

### 3. Read Prerequisite Files

If the plan lists files to read before implementation:
- Read all specified rule files
- Read all specified reference implementation files
- Understand the patterns and conventions before coding

### 4. Implement According to Plan

For each implementation step in the plan:
- Create or modify files exactly as specified
- Implement functions with the exact signatures provided
- Follow the algorithm comments/outline in the plan
- Do NOT add extra features, helpers, or optimizations not in the plan
- Do NOT create constants or variables not specified in the plan

**If instructions are unclear**: You MUST use `AskUserQuestion` to ask for clarification. Do not guess or make assumptions.

### 5. Verify Success Criteria

If the plan defines success criteria:
- Run specified build commands
- Run specified test commands
- Verify all criteria are met
- If any criterion fails, continue working to fix it

Additionally, verify against the Acceptance Criteria from the requirements document:
- Check that each AC item is satisfied by the implementation
- If any AC cannot be verified, note it in the output

## Output

See [Output Format]({baseDir}/SKILL.md#output-format) in main skill documentation.

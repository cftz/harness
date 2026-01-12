# `create` Command

Creates a new draft execution plan from requirements.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify where requirements come from:

- `TASK_PATH` - Path to a task document (e.g., `.agent/artifacts/20260105/01_task.md`)
- `ISSUE_ID` - Linear Issue ID (e.g., `ABC-123`)

### Output (Optional)

- `OUTPUT_PATH` - Path to write the draft plan. If not provided, uses `mktemp` skill to create a temporary file.

## Usage Examples

```bash
# From Linear issue, auto-generate temp file
/draft-plan create ISSUE_ID=TA-123

# From task file, auto-generate temp file
/draft-plan create TASK_PATH=.agent/artifacts/20260105/01_task.md

# From Linear issue, specify output path
/draft-plan create ISSUE_ID=TA-123 OUTPUT_PATH=.agent/tmp/plan.md
```

## Process

### 1. Read Requirements

- If `TASK_PATH` is provided -> Read the file directly
- If `ISSUE_ID` is provided -> Read [Linear Task Document]({baseDir}/references/linear-task.md)

Thoroughly understand:
- What needs to be implemented
- Acceptance criteria
- Scope boundaries
- Constraints

### 2. Research Packages

If external libraries are needed rather than building from scratch:

1. Use Context7 MCP to investigate candidate packages
2. Evaluate based on:
   - Maturity and active community
   - Compatibility with existing packages
3. If multiple candidates are viable, use `AskUserQuestion` to get user selection
4. **MUST select exactly one package** - do not leave as "A or B"

### 3. Explore Codebase

1. Read rules in `.agent/rules/` directory to understand project conventions
2. Explore existing code patterns related to the requirements
3. Identify files that need to be modified or created

### 4. Make Architectural Decisions

1. Determine algorithms and architecture for implementation
2. **MUST select exactly one approach** - do not write "A or B" in the plan
3. If multiple approaches are viable, use `AskUserQuestion` to get user selection

### 5. Create Output File

- If `OUTPUT_PATH` is provided -> Use that path directly
- If `OUTPUT_PATH` is not provided -> Use the `mktemp` skill:
  ```
  skill: mktemp
  args: plan
  ```

### 6. Write Draft Plan

Write the execution plan to the output file following the Output Format defined in `{baseDir}/SKILL.md`.

## Output

Return the path to the created draft plan file:

```
Draft plan created: {DRAFT_PATH}
```

> Note: The output uses `DRAFT_PATH` (not `OUTPUT_PATH`) to maintain consistency with the `modify` command and dependent skills like `plan-workflow` that expect `DRAFT_PATH`.

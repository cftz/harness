# `create` Command

Creates a new draft execution plan from requirements.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify where requirements come from:

- `TASK_PATH` - Path to a task document (e.g., `.agent/artifacts/20260105/01_task.md`)
- `ISSUE_ID` - Linear Issue ID (e.g., `ABC-123`)

### Output (Optional)

- `OUTPUT_PATH` - Path to write the draft plan. If not provided, uses `mktemp` skill to create a temporary file.

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
3. If multiple candidates are viable, **save context and return** for user selection
4. **MUST select exactly one package** - do not leave as "A or B"

#### Checkpoint: Save Context if User Input Needed

When you need user input for package selection or other decisions, **save context and return** instead of using AskUserQuestion directly:

1. **Create context file** using context skill:
   ```
   skill: context
   args: save
   ```

2. **Fill context sections**:
   - Skill Invocation: Original call (e.g., `/draft-plan create ISSUE_ID=TA-123`)
   - Progress Summary: What has been done, why paused (detailed natural language)
   - Partial Outputs: Research results, package comparisons, requirements analysis
   - Pending Questions: Questions requiring answers (using question-template format)
   - Answered Questions: Previously answered questions

3. **Return AWAIT status**:
   ```
   STATUS: AWAIT
   CONTEXT_PATH: .agent/tmp/xxx-context.md
   ```

The workflow will:
1. Collect answers via AskUserQuestion
2. Fill answers in the context file
3. Call `resume CONTEXT_PATH=...` to continue

### 3. Explore Codebase

1. Read rules in `.agent/rules/` directory to understand project conventions
2. Explore existing code patterns related to the requirements
3. Identify files that need to be modified or created

### 4. Make Architectural Decisions

1. Determine algorithms and architecture for implementation
2. **MUST select exactly one approach** - do not write "A or B" in the plan
3. If multiple approaches are viable, **save context and return** for user selection (see Checkpoint pattern in Step 2)

### 5. Create Output File

- If `OUTPUT_PATH` is provided -> Use that path directly
- If `OUTPUT_PATH` is not provided -> Use the `mktemp` skill:
  ```
  skill: mktemp
  args: plan
  ```

### 6. Write Draft Plan

Write the execution plan to the output file following the Plan Document Format defined in `{baseDir}/SKILL.md`.

## Output

**On Success:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: {temp_file_path}
```

**On User Input Needed:**
```
STATUS: AWAIT
CONTEXT_PATH: {context_file_path}
```

> Note: The output uses `DRAFT_PATH` (not `OUTPUT_PATH`) to maintain consistency with the `modify` command and dependent skills like `plan-workflow` that expect `DRAFT_PATH`.

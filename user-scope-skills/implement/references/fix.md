# Fix Command

Fixes code based on code review feedback. Use this command after `code-review` returns "Changes Required".

## Parameters

### Source (OneOf, Required)

Provide one of the following combinations:

**Option A: Local Files**
- `PLAN_PATH` - Path to the original plan document
- `REVIEW_PATH` - Path to the review document with required changes

Both must be provided together.

**Option B: Linear Issue with explicit review**
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
- `REVIEW_PATH` - Path to the review document

**Option C: Linear Issue with auto-discovery**
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
  - Plan: Retrieved from Document attached to the issue
  - Review: Auto-discovered from attached Documents (see [Linear Review Document]({baseDir}/references/linear-review.md))

## Process

### 1. Read Plan and Review

**If `ISSUE_ID` is provided without `REVIEW_PATH`:**
- Read [Linear Task Document]({baseDir}/references/linear-task.md) to fetch the plan
- Read [Linear Review Document]({baseDir}/references/linear-review.md) to fetch the review

**If `ISSUE_ID` is provided with `REVIEW_PATH`:**
- Read [Linear Task Document]({baseDir}/references/linear-task.md) to fetch the plan
- Read the review file from `REVIEW_PATH`

**If `PLAN_PATH` + `REVIEW_PATH` are provided:**
- Read the plan file from `PLAN_PATH`
- Read the review file from `REVIEW_PATH`

Thoroughly understand:
- Original implementation context (from plan)
- What violations were found (from review)
- Acceptance Criteria to satisfy (from review)
- Specific fixes required for each violation

**Error Handling:**
- If `ISSUE_ID` is provided but no Plan Document is attached: Report error and exit
- If `ISSUE_ID` is provided but no Review Document is found: Report error and exit
- If `PLAN_PATH` file doesn't exist: Report the missing file path and exit
- If `REVIEW_PATH` file doesn't exist: Report the missing file path and exit

### 2. Install Dependencies

If the review specifies additional dependencies to install:
- Install each dependency using the appropriate package manager command
- Do NOT manually edit dependency files (go.mod, package.json, etc.)
- Verify installation success before proceeding

### 3. Read Prerequisite Files

Read files referenced in the plan and review:
- Rule files mentioned in violations (e.g., `.agent/rules/go/go-struct.md`)
- Files that need to be modified
- Related implementation files for context

### 4. Fix According to Review

For each violation in the review:
- Locate the file and line number
- Apply the suggested fix exactly as specified
- Ensure the fix follows the referenced rule
- Do NOT make additional changes beyond what the review requires
- Do NOT refactor or improve code that wasn't flagged

**If instructions are unclear**: You MUST use `AskUserQuestion` to ask for clarification. Do not guess or make assumptions.

### 5. Verify Success Criteria

Verify against the Acceptance Criteria from the review document:
- Check that each violation has been addressed
- Run build commands to ensure no regressions
- Run test commands if specified
- If any criterion fails, continue working to fix it

## Output

See [Output Format]({baseDir}/SKILL.md#output-format) in main skill documentation.

For fix command specifically, the Acceptance Criteria section should reflect the review violations that were addressed:

```
Acceptance Criteria:
- [x] Fixed: Optional field should use pointer type (path/to/file.go:42)
- [x] Fixed: Comment translated to English (path/to/file.go:78)
```

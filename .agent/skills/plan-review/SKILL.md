---
name: plan-review
description: |
  Use this skill to review plan documents for rule compliance before implementation.

  Reviews plan documents for rule compliance and suggests implementation improvements. Validates plans against .agent/rules/.

  Args:
    Plan Source (OneOf, Required):
      PLAN_PATH=<path> - Direct path to plan file
      ARTIFACT_DIR_PATH=<path> - Load plan from artifact directory
      ISSUE_ID=<id> - Load plan from Linear issue's linked document
    Output Destination (Optional, OneOf):
      USE_TEMP=true - Save to temp file (default)
      ARTIFACT_DIR_PATH=<path> - Save review to artifact directory
      ISSUE_ID=<id> - Save as Linear Document attached to issue

  Examples:
    /plan-review PLAN_PATH=.agent/tmp/plan.md
    /plan-review ARTIFACT_DIR_PATH=.agent/artifacts/20260105-120000
    /plan-review ISSUE_ID=TA-123
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Plan-Review Skill

Reviews plan documents to ensure compliance with project rules defined in `.agent/rules/` and suggests better implementation approaches. Outputs either an "Approved" result or a "Revision Needed" document with detailed findings.

## Parameters

### Plan Source (OneOf, Required)

Provide one of the following to specify where the plan is located:

- `PLAN_PATH` - Direct path to a plan file (e.g., `.agent/tmp/plan.md`)
- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

### Output Destination (Optional, OneOf)

- `USE_TEMP=true` - Save to temp file (default behavior)
- `ARTIFACT_DIR_PATH` - Artifact directory path to save the review result (when provided as Plan Source, it automatically becomes the Output Destination)
- `ISSUE_ID` - Save as Linear Document attached to the issue (when provided as Plan Source, it automatically becomes the Output Destination)

**Output Priority**:
1. `USE_TEMP=true` → Temp file
2. `ARTIFACT_DIR_PATH` → Artifact
3. `ISSUE_ID` → Linear Document
4. Default (no option) → Temp file

## Process

### 1. Load Plan Document

Load the plan document from the specified source:

- If `PLAN_PATH` is provided -> Read [Plan Path Task Document]({baseDir}/references/plan-path-task.md)
- If `ARTIFACT_DIR_PATH` is provided -> Read [Artifact Task Document]({baseDir}/references/artifact-task.md)
- If `ISSUE_ID` is provided -> Read [Linear Task Document]({baseDir}/references/linear-task.md)

Extract from the plan document:
- **Title**: From YAML frontmatter
- **Issue ID**: From YAML frontmatter (if present)
- **Overview**: Implementation goal description
- **Package Changes**: New packages to be added (if any)
- **Implementation Steps**: Each step with target files
- **Summary of Changes**: File list with action types

### 2. Extract Target Files

From the plan's Implementation Steps and Summary of Changes sections, extract:
- All file paths mentioned (e.g., `internal/service/user/user.go`)
- Action types for each file (Create, Modify, Delete)
- Package locations (e.g., `cli/`, `api/`, `daemon/`)

Create a list of target files that will be affected by the plan.

### 3. Load Applicable Rules

For each target file in the plan, identify which rules apply based on:

**File Extension Mapping:**
| Extension | Rule Files |
|-----------|-----------|
| `.go` | `go/*.md` |
| `.tsx`, `.ts` | `react/*.md` |
| `.proto` | `idl/*.md` |

**File Path Mapping:**
| Path Pattern | Rule Files |
|--------------|-----------|
| `**/internal/**` | `go/go-hexagonal-layout.md` |
| `**/inbound/**`, `**/outbound/**` | `go/go-port-adapter-pattern.md` |
| `**/platform/**` | `go/go-platform.md`, `go/go-platform-*.md` |

**Always Applicable:**
- `common.md`
- `workflow.md`
- `project.md`

Read each applicable rule file and extract:
- Rule requirements (MUST, SHOULD, etc.)
- Pattern requirements (naming, structure, etc.)
- Code examples

### 4. Perform Rule Compliance Review

For each Implementation Step in the plan:

1. **Check function signatures against rules:**
   - Struct field types (pointer vs value per `go-struct.md`)
   - Context as first parameter
   - Return types (concrete vs interface)
   - Naming conventions

2. **Check architecture against rules:**
   - Port/Adapter pattern compliance
   - Service isolation rules
   - Dependency flow direction
   - Package organization

3. **Check proposed packages:**
   - Verify package choices align with dependency rules
   - Check if well-tested alternatives exist (per `common.md`)

4. **Record violations:**
   - Step number and file path
   - Rule violated (reference to `.agent/rules/{file}`)
   - Description of the issue
   - Specific recommended fix

### 5. Perform Task Alignment Review (ISSUE_ID only)

> Skip this step if `ISSUE_ID` is not provided as Plan Source.

When `ISSUE_ID` is provided, the Issue Description contains the Task document (requirements). Compare the plan against this Task document:

1. **Acceptance Criteria Coverage**
   - All acceptance criteria from Task are addressed in Plan
   - No requirements are omitted
   - Each criteria has corresponding implementation steps

2. **Scope Alignment**
   - Plan stays within Task's In Scope boundaries
   - Plan doesn't include Out of Scope items
   - Any deviations are justified

3. **Record Task Alignment Issues**:
   - Missing acceptance criteria coverage
   - Scope violations
   - Unjustified additions

### 6. Analyze for Improvements

Beyond rule compliance, analyze the plan for:

1. **Better Patterns:**
   - Are there simpler architectural approaches?
   - Could existing utilities be reused?
   - Are there unnecessary abstractions?

2. **Better Packages:**
   - Are there more mature/maintained alternatives?
   - Are there packages that provide more features needed?
   - Use Context7 MCP to research alternatives if needed

3. **Better Structure:**
   - Could files be organized more logically?
   - Are there missing test scenarios?
   - Could steps be combined or split more effectively?

### 7. Determine Result

**Approved Criteria:**
- All proposed changes follow applicable rules
- No critical architectural concerns
- Task alignment passes (if ISSUE_ID provided)
- Any minor suggestions are informational only

**Revision Needed Criteria:**
- At least one rule violation found
- Critical architectural concern identified
- Missing required test scenarios
- Task alignment issues (if ISSUE_ID provided)

### 8. Write Review Document

Use `mktemp` skill to create temporary file:

```
skill: mktemp
args: plan-review
```

Write the review result following the [Output Format](#output-format).

### 9. Create Final Output

Determine output destination based on parameters:

1. If `USE_TEMP=true` -> Follow [Temp File Only Output](#temp-file-only-output) below
2. Else if `ARTIFACT_DIR_PATH` is provided -> Read [Artifact Output]({baseDir}/references/artifact-output.md) and follow its instructions
3. Else if `ISSUE_ID` is provided -> Read [Linear Output]({baseDir}/references/linear-output.md) and follow its instructions
4. Else (default) -> Follow [Temp File Only Output](#temp-file-only-output) below

### Temp File Only Output

When temp file output is selected:

1. Review result remains in the temp file created by `mktemp` skill in Step 8
2. Present the review result to the user
3. Inform user: "Review saved to: {temp_file_path}"
4. No artifact or Linear Document is created

This is useful for quick reviews where permanent storage is not needed.

## Output Format

### Approved Output

```markdown
# Plan Review Result

**Status**: Approved

The plan follows project rules and is ready for implementation.

## Plan Reviewed

- **Title**: {plan title}
- **Source**: {PLAN_PATH | ARTIFACT_DIR_PATH | ISSUE_ID}

## Files Covered

| File Path | Action | Rules Applied |
|-----------|--------|---------------|
| `path/to/file1.go` | Create | `go-struct.md`, `go-hexagonal-layout.md` |
| `path/to/file2.go` | Modify | `go-port-adapter-pattern.md` |

## Rules Applied

- `.agent/rules/common.md`
- `.agent/rules/workflow.md`
- `.agent/rules/go/go-struct.md`
- `.agent/rules/go/go-hexagonal-layout.md`

## Quality Score

| Category | Score | Notes |
|----------|-------|-------|
| Rule Compliance | Pass | All proposed changes follow applicable rules |
| Architecture | Pass | Structure follows hexagonal architecture |
| Test Coverage | Pass | All branches have test scenarios |
| Package Selection | Pass | Selected packages are appropriate |

## Task Alignment (ISSUE_ID only)

| Category | Score | Notes |
|----------|-------|-------|
| Acceptance Criteria Coverage | Pass | All criteria addressed |
| Scope Alignment | Pass | Within defined scope |

## Optional Improvements

{If any non-blocking suggestions exist}

| Area | Suggestion | Benefit |
|------|------------|---------|
| {Area} | {Suggestion} | {Expected benefit} |
```

### Revision Needed Output

```markdown
# Plan Review Result

**Status**: Revision Needed

## Request Summary

Plan review identified issues that need to be addressed before implementation. The plan does not fully comply with project standards defined in `.agent/rules/`. Please address the violations and consider the suggested improvements.

## Plan Reviewed

- **Title**: {plan title}
- **Source**: {PLAN_PATH | ARTIFACT_DIR_PATH | ISSUE_ID}

## Revision Checklist

- [ ] {Specific fix for violation 1}
- [ ] {Specific fix for violation 2}
- [ ] {Consider improvement 1}

## Rule Violations

| Step | File Path | Rule | Issue | Recommended Fix |
|------|-----------|------|-------|-----------------|
| 2 | `internal/service/user.go` | `go-struct.md` | Optional field `Email` uses value type | Change to `*string` with `omitempty` tag |
| 3 | `internal/handler/http.go` | `go-inbound.md` | Handler imports from another service | Use platform domain or Core service |

## Suggested Improvements

### Architecture

| Current Approach | Suggested Alternative | Rationale |
|-----------------|----------------------|-----------|
| {Current} | {Alternative} | {Why it's better} |

### Package Selection

| Proposed Package | Alternative | Consideration |
|-----------------|-------------|---------------|
| {Package} | {Alternative} | {Why to consider} |

### Structure

| Step | File | Suggestion |
|------|------|------------|
| {N} | `path/to/file.go` | {Structural improvement} |

## Quality Score

| Category | Score | Notes |
|----------|-------|-------|
| Rule Compliance | Fail | {N} violations found |
| Architecture | {Pass/Warn/Fail} | {Notes} |
| Test Coverage | {Pass/Warn} | {Notes} |
| Package Selection | {Pass/Warn} | {Notes} |

## Task Alignment (ISSUE_ID only)

| Category | Score | Notes |
|----------|-------|-------|
| Acceptance Criteria Coverage | {Pass/Fail} | {Notes} |
| Scope Alignment | {Pass/Fail} | {Notes} |

## Rules Applied

- `.agent/rules/common.md`
- `.agent/rules/workflow.md`
- `.agent/rules/go/go-struct.md`

## Next Steps

1. Address all items in the Revision Checklist
2. Update the plan document
3. Re-run plan-review to verify compliance
```

## Quality Checklist

Before submitting the review document, verify:

- [ ] All target files in the plan have been analyzed
- [ ] All applicable rules have been loaded and checked
- [ ] Violations include specific step and file references
- [ ] Recommended fixes are actionable and specific
- [ ] Improvements are prioritized (required vs optional)
- [ ] Approved/Revision Needed determination is clear and justified
- [ ] Quality scores reflect actual findings
- [ ] Output saved to correct destination (artifact or Linear)

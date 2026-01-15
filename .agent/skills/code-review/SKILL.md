---
name: code-review
description: |
  Use this skill after completing implementation to validate code against project rules. Validates implementations against project rules defined in .agent/rules/. Supports Artifact or Linear Issue as input source, outputs Pass or Changes Required document to Artifact directory or Linear Document.

  Args:
    Task Source (OneOf, Required):
      ARTIFACT_DIR_PATH=<path> - Artifact directory (e.g., .agent/artifacts/20260105-120000)
      ISSUE_ID=<id> - Linear Issue ID (e.g., TA-123)
    Output Destination (Optional, OneOf):
      USE_TEMP=true - Save to temp file (default)
      ARTIFACT_DIR_PATH=<path> - Save review to artifact directory
      ISSUE_ID=<id> - Save as Linear Document attached to issue

  Examples:
    /code-review ARTIFACT_DIR_PATH=.agent/artifacts/20260105-120000
    /code-review ISSUE_ID=TA-123
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Code-Review Skill

Validates that implementations follow all applicable project rules. Reviews changed files against rules in `.agent/rules/` and outputs either a Pass result or a Changes Required document.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify the review context:

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

### Output Destination (Optional, OneOf)

- `USE_TEMP=true` - Save to temp file (default behavior)
- `ARTIFACT_DIR_PATH` - Artifact directory path to save the review result (when provided as Task Source, it automatically becomes the Output Destination)
- `ISSUE_ID` - Save as Linear Document attached to the issue (when provided as Task Source, it automatically becomes the Output Destination)

**Output Priority**:
1. `USE_TEMP=true` → Temp file
2. `ARTIFACT_DIR_PATH` → Artifact
3. `ISSUE_ID` → Linear Document
4. Default (no option) → Temp file

## Process

### 1. Load Context

Load prior planning documents to understand what was supposed to be implemented:

- If `ARTIFACT_DIR_PATH` is provided → Read [Artifact Task Document]({baseDir}/references/artifact-task.md)
- If `ISSUE_ID` is provided → Read [Linear Task Document]({baseDir}/references/linear-task.md)

Understand:
- What was originally requested
- What was planned to be implemented
- Which files were targeted for changes

### 2. Get Changed Files

Use `git status` to identify files that have been modified (including uncommitted changes):

```bash
# Get all modified files (staged and unstaged)
git status --porcelain | awk '{print $2}'
```

This captures uncommitted changes from the `implement` skill. Do NOT use `git diff main...HEAD` as it only shows committed changes.

Focus review on these changed files only.

### 3. Load Applicable Rules

For each changed file, identify which rules apply based on:
- **File extension**: `.go` → `go/*.md`, `.tsx` → `react/*.md`, etc.
- **File path**: `internal/adapter/` → `go-port-adapter-pattern.md`, etc.
- **Always applicable**: `common.md`, `workflow.md`

Use the frontmatter `paths` field in rule files (if present) to determine applicability, or use file extension/path heuristics.

Load and read all applicable rule files before reviewing.

### 4. Review Each Changed File

For each changed file:

1. **Read the file content**
2. **Check against each applicable rule**:
   - Struct field types (pointer vs value)
   - Naming conventions
   - Architecture patterns
   - Code organization
   - Comment requirements
   - Dependency management

3. **Look for justifications**: If code appears to violate a rule, check for:
   - Comments explaining the deviation
   - Special circumstances documented in the code

4. **Record violations**: If a rule is violated AND no justification exists:
   - File path and line number
   - Rule violated (reference to `.agent/rules/{file}`)
   - Clear description of the issue
   - Specific suggested fix

### 5. Determine Result

**Pass Criteria:**
- All changed files follow applicable rules
- Any deviations have documented justifications

**Changes Required Criteria:**
- At least one rule violation without justification

### 6. Write Review Document

Once review is complete, create the final output:

Determine output destination based on parameters:

1. If `USE_TEMP=true` → Read [Temp Output]({baseDir}/references/temp-output.md) and follow its instructions
2. Else if `ARTIFACT_DIR_PATH` is provided → Read [Artifact Output]({baseDir}/references/artifact-output.md) and follow its instructions
3. Else if `ISSUE_ID` is provided → Read [Linear Output]({baseDir}/references/linear-output.md) and follow its instructions
4. Else (default) → Read [Temp Output]({baseDir}/references/temp-output.md) and follow its instructions

## Output Format

### Pass Output

```markdown
# Review Result

**Status**: Pass

All changes follow project rules correctly.

## Files Reviewed

- `path/to/file1.go`
- `path/to/file2.go`
- `path/to/file3.tsx`

## Rules Applied

- `.agent/rules/common.md`
- `.agent/rules/workflow.md`
- `.agent/rules/go/go-struct.md`
- `.agent/rules/react/react-web.md`
```

### Changes Required Output

When violations are found, output a requirements document:

```markdown
# Review Result

**Status**: Changes Required

## Request Summary

Code review identified rule violations that need to be addressed. The implementation does not follow project standards defined in `.agent/rules/`. Please address the violations listed below.

## Acceptance Criteria

- [ ] [Specific fix for violation 1]
- [ ] [Specific fix for violation 2]
- [ ] [Specific fix for violation 3]

## Scope

### In Scope
- Fix identified rule violations
- Ensure all changes follow applicable rules

### Out of Scope
- Any other refactoring or improvements not related to rule violations
- Feature additions beyond fixing violations

## Violations Found

| File              | Line | Rule              | Issue                                  | Suggested Fix                                                           |
| ----------------- | ---- | ----------------- | -------------------------------------- | ----------------------------------------------------------------------- |
| `path/to/file.go` | 42   | `go/go-struct.md` | Optional field should use pointer type | Change `Name string` to `Name *string` with `json:"name,omitempty"` tag |
| `path/to/file.go` | 78   | `common.md`       | Comment not in English                 | Translate comment to English                                            |

## Additional Context

- Task document: Referenced from input source
- Plan document: Referenced from input source
- Review triggered by changes to {N} files

## Rules References

The following rules were applied during this review:
- [`.agent/rules/common.md`](.agent/rules/common.md)
- [`.agent/rules/go/go-struct.md`](.agent/rules/go/go-struct.md)
```

## Quality Checklist

Before submitting the review document, verify:

- [ ] All changed files have been reviewed
- [ ] All applicable rules have been loaded and checked
- [ ] Violations include specific file:line references
- [ ] Suggested fixes are actionable and specific
- [ ] Pass/fail determination is clear and justified
- [ ] If violations found, they are documented in requirements format
- [ ] If pass, all reviewed files and applied rules are listed
- [ ] Output saved to correct destination (artifact or Linear)

## Constraints

**This skill is READ-ONLY. You MUST NOT modify repository state:**

- Do NOT modify any source files
- Do NOT run `git checkout`, `git branch`, or any branch-changing commands
- Do NOT run `git add`, `git commit`, `git push`, or any staging/committing commands
- Do NOT run `git stash`, `git reset`, or any commands that alter working directory state

If `git status` shows no changes, report "No Changes to Review" - do NOT attempt to fix this by switching branches or other workarounds.

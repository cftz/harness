---
name: suggest-improvements
description: |
  Use this skill to analyze code against specific checklists and generate improvement suggestions. Each checklist focuses on a specific area (repository layer, service layer, security, etc.).

  Args:
    TARGET (Required) - Checklist target to analyze:
      repository - Repository layer code analysis
      all - Run all available checklists
    Output Destination (OneOf, Optional):
      USE_TEMP=true - Save to temp file (default)
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      ISSUE_ID=<id> - Save as Linear Document attached to issue
      PROJECT_ID=<id> - Create Linear issues in project

  Examples:
    /suggest-improvements repository
    /suggest-improvements repository ISSUE_ID=TA-123
    /suggest-improvements all ARTIFACT_DIR_PATH=.agent/artifacts/20260117
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Description

Analyzes code against specific checklists and generates improvement suggestions. Each checklist defines check items for a specific area. This skill is READ-ONLY and safe to run at any time without modifying the codebase.

# Parameters

## Required

- `TARGET` - Checklist target to analyze
  - `repository` - Repository layer code analysis
  - `all` - Run all available checklists

## Output Destination (OneOf, Optional)

Provide one to specify where output is saved:

- `USE_TEMP=true` - Save to temp file (default behavior)
- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260117`)
- `ISSUE_ID` - Linear Issue ID to attach document (e.g., `TA-123`)
- `PROJECT_ID` - Linear Project ID to create issues (e.g., `cops`)

**Output Priority**:
1. `USE_TEMP=true` -> Temp file
2. `ARTIFACT_DIR_PATH` -> Artifact
3. `ISSUE_ID` -> Linear Document
4. `PROJECT_ID` -> Linear Issues
5. Default (no option) -> Temp file

# Available Checklists

| TARGET       | Checklist File            | Description                   |
| ------------ | ------------------------- | ----------------------------- |
| `repository` | `checklist-repository.md` | Repository layer code quality |

# Process

## 1. Validate TARGET

Check if TARGET is valid:

- If TARGET is `all` -> Go to Step 2
- If TARGET matches an available checklist -> Go to Step 3
- Otherwise -> Report error: "Unknown target: {TARGET}. Available: repository, all"

## 2. Handle `all` Target

When TARGET is `all`:

1. List all checklist files: `{baseDir}/references/checklist-*.md`
2. For each checklist file:
   - Extract target name from filename (e.g., `checklist-repository.md` -> `repository`)
   - Recursively execute this skill with that target
3. Combine all results into single output
4. Go to Step 5 (Write Output)

## 3. Load Checklist

Load the checklist file:

```
Read {baseDir}/references/checklist-{TARGET}.md
```

The checklist contains:
- Check items with severity levels
- Description of what to look for

## 4. Execute Checklist

For each check item in the checklist:

1. Search the codebase for relevant code patterns
2. Analyze against the check criteria
3. Record findings:
   - Location (file path and line)
   - Check item name
   - Severity (from checklist)
   - Issue description
   - Suggested fix

**Analysis Output Format**:

```markdown
# Improvement Suggestions: {TARGET}

**Analysis Date**: {date}
**Total Issues Found**: {N}

## Summary

{2-3 sentence overview of findings}

## Issues by Severity

### Critical
{Issues that need immediate attention}

### High
{Issues that should be addressed soon}

### Medium
{Issues to address when convenient}

### Low
{Nice-to-have improvements}

## Detailed Findings

| #   | Location    | Check Item | Severity | Issue   | Suggested Fix |
| --- | ----------- | ---------- | -------- | ------- | ------------- |
| 1   | {path:line} | {item}     | {sev}    | {issue} | {fix}         |
```

## 5. Write Output

Determine output destination and save:

1. If `USE_TEMP=true` -> Read `{baseDir}/references/temp-output.md` and follow instructions
2. Else if `ARTIFACT_DIR_PATH` -> Read `{baseDir}/references/artifact-output.md` and follow instructions
3. Else if `ISSUE_ID` -> Read `{baseDir}/references/linear-document-output.md` and follow instructions
4. Else if `PROJECT_ID` -> Read `{baseDir}/references/linear-issues-output.md` and follow instructions
5. Else (default) -> Read `{baseDir}/references/temp-output.md` and follow instructions

# Severity Definitions

| Severity | Criteria                                 | Examples                                  |
| -------- | ---------------------------------------- | ----------------------------------------- |
| Critical | Security risk or will cause failures     | SQL injection, connection leak            |
| High     | Significant quality or maintenance issue | N+1 queries, business logic in repository |
| Medium   | Quality improvement recommended          | Hardcoded queries, missing pagination     |
| Low      | Nice-to-have enhancement                 | Missing logging                           |

# Quality Checklist

Before completing, verify:

- [ ] Checklist file was loaded
- [ ] All check items were evaluated
- [ ] Issues are categorized by severity
- [ ] Suggestions include actionable fixes
- [ ] Output saved to correct destination

# Constraints

**This skill is READ-ONLY. You MUST NOT modify the codebase:**

- Do NOT modify any source files
- Do NOT delete or move files
- Do NOT install packages
- Do NOT run potentially destructive commands

Analysis should be non-invasive and safe to run at any time.

# Output

SUCCESS:
- RESULT: Analysis completion status (COMPLETE or PARTIAL)
- ISSUES_COUNT: Number of issues found (by severity: Critical/High/Medium/Low)
- OUTPUT_PATH: Path where suggestions document was saved

ERROR: Error message string (e.g., "Unknown target: {TARGET}. Available: repository, all")

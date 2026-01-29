# Validation Skill Template

<!--
PHILOSOPHY REMINDER:
- Keep process steps brief (1-3 sentences each)
- Focus on WHAT, not HOW
- Constraints section is critical for guardrails
-->

Use this template for analysis and reporting tools.

## Characteristics

- Read-only operation
- Analysis and inspection
- Report generation
- No modifications to codebase

## Directory Structure

```
{skill-name}/
├── SKILL.md       # Main skill definition
└── README.md      # Intent documentation
```

Note: Validation skills typically don't need `references/` or `scripts/` directories.

## SKILL.md Template

```markdown
---
name: {skill-name}
description: |
  Use this skill to {analysis purpose}.

  {What it analyzes and reports on.}

  Args:
    TARGET (Required) - {What to analyze}
    Output Destination (OneOf, Optional):
      USE_TEMP=true - Save to temp file (default)
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      ISSUE_ID=<id> - Save as Linear Document

  Examples:
    /{skill-name} TARGET=path/to/analyze
    /{skill-name} TARGET=all ARTIFACT_DIR_PATH=.agent/artifacts/20260117
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Description

{Detailed description of what the skill analyzes and reports.}

## Parameters

### Required

- `TARGET` - {What to analyze}
  - Specific value: {Description}
  - `all`: Analyze all applicable targets

### Output Destination (OneOf, Optional)

- `USE_TEMP=true` - Save to temp file (default)
- `ARTIFACT_DIR_PATH` - Artifact directory path
- `ISSUE_ID` - Linear Issue ID to attach document

## Process

### 1. Validate TARGET

Check if TARGET is valid:
- If `all` -> Process all targets
- If specific value -> Validate it exists
- Otherwise -> Report error

### 2. Load Analysis Criteria

Load the criteria for analysis:
- Rules from `.agent/rules/`
- Checklist items
- Pattern definitions

### 3. Execute Analysis

For each item to analyze:
1. Search for relevant code/content
2. Check against criteria
3. Record findings with:
   - Location (file path and line)
   - Severity level
   - Issue description
   - Suggested fix

### 4. Generate Report

Create the analysis report:

```markdown
# {Analysis} Report

**Analysis Date**: {date}
**Total Issues Found**: {N}

## Summary

{2-3 sentence overview}

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

| # | Location | Issue | Severity | Fix |
|---|----------|-------|----------|-----|
| 1 | {path:line} | {issue} | {sev} | {fix} |
```

### 5. Write Output

Determine output destination and save:
1. `USE_TEMP=true` -> Save to temp file
2. `ARTIFACT_DIR_PATH` -> Save to artifact directory
3. `ISSUE_ID` -> Save as Linear Document
4. Default -> Save to temp file

## Severity Definitions

| Severity | Criteria | Examples |
|----------|----------|----------|
| Critical | {Definition} | {Examples} |
| High | {Definition} | {Examples} |
| Medium | {Definition} | {Examples} |
| Low | {Definition} | {Examples} |

## Output

SUCCESS:
- RESULT: Analysis completion status (COMPLETE or PARTIAL)
- ISSUES_COUNT: Number of issues found (by severity)
- OUTPUT_PATH: Path where report was saved

ERROR: Error message string

## Quality Checklist

Before completing, verify:

- [ ] **Target validated**: Input is valid
- [ ] **Criteria loaded**: All applicable rules/checklists loaded
- [ ] **Analysis complete**: All items analyzed
- [ ] **Issues categorized**: Properly sorted by severity
- [ ] **Fixes actionable**: Suggestions are clear and specific
- [ ] **Output saved**: Report saved to correct destination

## Constraints

**This skill is READ-ONLY. You MUST NOT modify the codebase:**

- Do NOT modify any source files
- Do NOT delete or move files
- Do NOT install packages
- Do NOT run potentially destructive commands

Analysis should be non-invasive and safe to run at any time.
```

## README.md Template

```markdown
# {Skill Name}

## Intent

{What this skill analyzes and why it's useful.}

## Motivation

{Why automated analysis is beneficial for this area.}

## Design Decisions

- **Read-only operation**: Safe to run at any time
- **Severity categorization**: Helps prioritize fixes
- **Actionable suggestions**: Each issue has a clear fix

## Constraints

- Must never modify source files
- Must categorize issues by severity
- Must provide actionable fixes for each issue
```

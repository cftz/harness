---
name: clarify-review
description: |
  Reviews clarified task documents to ensure they follow draft-clarify rules and properly address the original request.

  Args:
    Task Source (OneOf, Required):
      PROMPT_PATH=<path> + DRAFT_PATHS=<paths> - Direct file paths
      ISSUE_ID=<id> - Linear Issue (parent description = prompt, sub-issues = drafts)
    Output Destination (Optional, OneOf):
      USE_TEMP=true - Save to temp file (default)
      ARTIFACT_DIR_PATH=<path> - Save review to artifact directory

  Examples:
    /clarify-review PROMPT_PATH=.agent/tmp/prompt DRAFT_PATHS=.agent/tmp/task1,.agent/tmp/task2
    /clarify-review ISSUE_ID=TA-123
    /clarify-review ISSUE_ID=TA-123 ARTIFACT_DIR_PATH=.agent/artifacts/20260111
model: claude-opus-4-5
---

# Clarify Review Skill

Reviews clarified task documents to ensure:
1. **Rule Compliance**: Documents follow `draft-clarify` rules (behavior-level criteria, no implementation details, etc.)
2. **Prompt Alignment**: Documents properly address the original request without scope creep or omissions

Outputs either an "Approved" result or a "Revision Needed" document with detailed findings.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following:

- `PROMPT_PATH` + `DRAFT_PATHS` - Direct file paths
  - `PROMPT_PATH`: Path to the original prompt file
  - `DRAFT_PATHS`: Comma-separated paths to draft task documents
- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)
  - Parent issue description = original prompt
  - Sub-issues = clarified task documents

### Output Destination (Optional, OneOf)

- `USE_TEMP=true` - Save to temp file (default behavior)
- `ARTIFACT_DIR_PATH` - Artifact directory path to save the review result

**Output Priority**:
1. `USE_TEMP=true` → Temp file
2. `ARTIFACT_DIR_PATH` → Artifact
3. Default (no option) → Temp file

> **Note**: ISSUE_ID is for input only (task source). Linear Document output is not supported since issues are not yet created at clarify stage.

## Process

### 1. Load Task Source

Load the prompt and draft documents from the specified source:

- If `PROMPT_PATH` + `DRAFT_PATHS` provided -> Read [Prompt Path Task Document]({baseDir}/references/prompt-path-task.md)
- If `ISSUE_ID` provided -> Read [Linear Task Document]({baseDir}/references/linear-task.md)

### 2. Perform Rule Compliance Review (Category A)

For each draft task document, verify the following checklists:

#### Checklist A1: Behavior-Level Acceptance Criteria

- [ ] Criteria describe observable behavior, not implementation
- [ ] No code-level terms (classes, functions, variables)

**Good Examples:**
- "User is redirected to dashboard after login"
- "Error message displays for invalid credentials"
- "Search results update within 2 seconds"

**Bad Examples:**
- "JWT token stored in localStorage"
- "AuthContext uses useReducer"
- "POST /api/auth/login endpoint is called"

#### Checklist A2: No Implementation Details

- [ ] No file/directory paths (e.g., `src/auth.ts`)
- [ ] No class/function names (e.g., `UserService class`)
- [ ] No technology stack decisions (unless user explicitly specified)
- [ ] No API endpoint paths (e.g., `POST /api/v1/users`)
- [ ] No database schema details

#### Checklist A3: Decisions Finalized

- [ ] No "A or B" ambiguities left unresolved
- [ ] Questions Resolved section contains all Q&A

#### Checklist A4: Required Sections Present

- [ ] Task Summary
- [ ] Acceptance Criteria
- [ ] Scope (In Scope / Out of Scope)
- [ ] Constraints (can be empty if none)

#### Checklist A5: Dependency Logic

- [ ] blockedBy relationships are logical
- [ ] No circular dependencies

### 3. Perform Prompt Alignment Review (Category B)

Compare drafts against the original prompt:

1. **Completeness**
   - All aspects of the original request are addressed
   - No requirements are omitted

2. **Scope Alignment**
   - No scope creep (features not in original request)
   - In Scope / Out of Scope matches original request intent

### 4. Determine Result

**Approved Criteria:**
- All drafts pass Category A (rule compliance)
- All drafts pass Category B (prompt alignment)
- Any minor suggestions are informational only

**Revision Needed Criteria:**
- At least one Category A violation found
- At least one Category B issue found
- Critical problems that must be addressed

### 5. Write Review Document

Use `mktemp` skill to create temporary file:

```
skill: mktemp
args: clarify-review
```

Write the review result following the [Output Format](#output-format).

### 6. Create Final Output

Determine output destination based on parameters:

1. If `USE_TEMP=true` -> Read [Temp Output]({baseDir}/references/temp-output.md)
2. Else if `ARTIFACT_DIR_PATH` provided -> Read [Artifact Output]({baseDir}/references/artifact-output.md)
3. Else (default) -> Read [Temp Output]({baseDir}/references/temp-output.md)

## Output Format

### Approved Output

```markdown
# Clarify Review Result

**Status**: Approved

The task documents follow draft-clarify rules and properly address the original request.

## Original Request Summary

- **Source**: {REQUEST | ISSUE_ID}
- **Key Requirements**: [Brief summary of key requirements]

## Tasks Reviewed

| Task | Rule Compliance | Prompt Alignment | Notes |
|------|-----------------|------------------|-------|
| {task_name} | Pass | Complete | {optional notes} |

## Quality Score

### A. draft-clarify Rule Compliance

| Category | Score | Notes |
|----------|-------|-------|
| Behavior-level Criteria | Pass | No implementation details in acceptance criteria |
| No Implementation Details | Pass | Clean separation from implementation |
| Decisions Finalized | Pass | All questions resolved |
| Required Sections | Pass | All sections present |
| Dependency Logic | Pass | No circular dependencies |

### B. PROMPT -> Clarify Alignment

| Category | Score | Notes |
|----------|-------|-------|
| Completeness | Pass | All requirements addressed |
| Scope Alignment | Pass | No scope creep |

## Optional Improvements

{If any non-blocking suggestions exist}

| Area | Suggestion | Benefit |
|------|------------|---------|
| {Area} | {Suggestion} | {Expected benefit} |
```

### Revision Needed Output

```markdown
# Clarify Review Result

**Status**: Revision Needed

## Request Summary

Review identified issues that need to be addressed before finalization. The task documents do not fully comply with draft-clarify standards.

## Original Request Summary

- **Source**: {REQUEST | ISSUE_ID}
- **Key Requirements**: [Brief summary]

## Revision Checklist

- [ ] {Specific fix for issue 1}
- [ ] {Specific fix for issue 2}
- [ ] {Consider improvement 1}

## Issues Found

### A. draft-clarify Rule Violations

| Task | Rule | Issue | Recommendation |
|------|------|-------|----------------|
| {task_name} | Behavior-level Criteria | Contains file path "src/auth.ts" | Remove implementation details from acceptance criteria |
| {task_name} | Decisions Finalized | Contains "A or B" option | Resolve with user and document decision |

### B. PROMPT -> Clarify Alignment Issues

| Task | Category | Issue | Recommendation |
|------|----------|-------|----------------|
| {task_name} | Completeness | Missing "error handling" from original request | Add acceptance criteria for error cases |
| {task_name} | Scope Alignment | Added "notifications" not in original request | Move to Out of Scope or confirm with user |

## Quality Score

### A. draft-clarify Rule Compliance

| Category | Score | Notes |
|----------|-------|-------|
| Behavior-level Criteria | Fail | {N} violations found |
| No Implementation Details | {Pass/Fail} | {Notes} |
| Decisions Finalized | {Pass/Fail} | {Notes} |
| Required Sections | {Pass/Fail} | {Notes} |
| Dependency Logic | {Pass/Fail} | {Notes} |

### B. PROMPT -> Clarify Alignment

| Category | Score | Notes |
|----------|-------|-------|
| Completeness | {Pass/Fail} | {Notes} |
| Scope Alignment | {Pass/Fail} | {Notes} |

## Next Steps

1. Address all items in the Revision Checklist
2. Update the draft task documents
3. Re-run clarify-review to verify compliance
```

## Quality Checklist

Before submitting the review document, verify:

- [ ] All draft documents have been analyzed
- [ ] draft-clarify rules have been checked against each draft
- [ ] Original prompt has been compared for completeness
- [ ] Violations include specific task and issue references
- [ ] Recommendations are actionable and specific
- [ ] Approved/Revision Needed determination is clear and justified
- [ ] Quality scores reflect actual findings
- [ ] Output saved to correct destination

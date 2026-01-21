# Linear Task Document

This document defines how to retrieve plan and requirements from a Linear issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `TA-123`)

> **Note**: In the examples below, `{ISSUE_ID}` and `{DOCUMENT_ID}` are placeholders. Replace them with actual values (e.g., `ID=TA-123`).

## Process

### 1. Fetch Requirements (from Issue Description)

1. Use the `linear-issue` skill to fetch issue details:
   ```
   skill: linear:linear-issue
   args: get ID={ISSUE_ID}
   ```
2. Extract the issue description as the requirements document
3. Parse the requirements structure:
   - Task Summary
   - Acceptance Criteria
   - Scope (In/Out)
   - Constraints

### 2. Fetch Plan (from Attached Document)

1. Use the `linear-document` skill to find documents attached to the issue:
   ```
   skill: linear:linear-document
   args: list ISSUE_ID={ISSUE_ID}
   ```
2. Select the plan document (typically the most recent or titled "Plan: ...")
3. Use `linear-document get` to retrieve the full content:
   ```
   skill: linear:linear-document
   args: get ID={DOCUMENT_ID}
   ```
4. Parse the plan structure:
   - YAML frontmatter (title, issueId if present)
   - Overview section
   - Package Changes section (if present)
   - Implementation Steps section

## Output

Both plan and requirements ready for implementation:

**Plan**:
- Clear implementation steps
- File paths to create/modify
- Function signatures and algorithms
- Success criteria (if defined)

**Requirements**:
- Acceptance Criteria to verify implementation against
- Scope boundaries to stay within
- Constraints to respect

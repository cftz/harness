# Linear Task Document

This document defines how to gather requirements from a Linear issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `ABC-123`, `TA-456`)

## Process

1. Use the `linear-issue` skill to fetch ticket details:
   ```
   skill: linear-issue
   args: get ID={ISSUE_ID}
   ```
2. Use the `linear-comment` skill to get additional context:
   ```
   skill: linear-comment
   args: list ISSUE_ID={ISSUE_ID}
   ```
3. Extract the following information:
   - Title
   - Description
   - Acceptance criteria (if defined)
   - Labels
   - Assignee
   - Any attached documents or links

## Output

Requirements gathered from the Linear issue, ready for the planning process.

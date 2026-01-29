# Linear Task Document

This document defines how to gather requirements from a Linear issue.

## Input

- `ISSUE_ID` - Linear Issue ID (e.g., `ABC-123`, `TA-456`)

## Process

### 1. Fetch Issue Details

Use the `linear-issue` skill to fetch ticket details:
```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

### 2. Fetch Comments

Use the `linear-comment` skill to get additional context:
```
skill: linear:linear-comment
args: list ISSUE_ID={ISSUE_ID}
```

### 3. Fetch Relations

Use the `linear-issue-relation` skill to get blocking relationships:
```
skill: linear:linear-issue-relation
args: list ISSUE_ID={ISSUE_ID}
```

### 4. Fetch Blocking Issue Context

For each relation where `type="blocks"` and `relatedIssue` is the current issue (meaning another issue blocks this one):

1. **Fetch blocking issue details:**
   ```
   skill: linear:linear-issue
   args: get ID={blocking_issue_id}
   ```

2. **Fetch Plan document (if exists):**
   ```
   skill: linear:linear-document
   args: list ISSUE_ID={blocking_issue_id}
   ```

   If a Plan document is found:
   ```
   skill: linear:linear-document
   args: get ID={plan_doc_id}
   ```

**Edge Case Handling:**
- Process up to 5 blocking issues, ordered by status (In Progress > Todo > Done)
- If no Plan document exists, include issue description only with note "No plan document found"
- Detect circular dependencies (A blocks B, B blocks A) and skip with warning
- Only fetch direct blockers (depth=1), not transitive dependencies

### 5. Extract Information

From the responses, extract:
- Title
- Description
- Acceptance criteria (if defined)
- Labels
- Assignee
- Any attached documents or links
- **Blocking issue context** (see Output format below)

## Output

Requirements gathered from the Linear issue, ready for the planning process.

Include the following section if blocking issues exist:

```markdown
## Blocking Issue Context

### {BLOCKING_ISSUE_ID}: {title}
- **Status**: {state.name}
- **Description**: {description summary}
- **Plan Document**: {extracted interfaces/APIs if available, or "No plan document found"}
```

Repeat for each blocking issue (up to 5).

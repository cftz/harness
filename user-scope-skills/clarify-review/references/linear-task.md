# Linear Task Loading

Instructions for loading task source from Linear Issue.

## When to Use

Use this reference when `ISSUE_ID` parameter is provided.

## Process

### 1. Get Parent Issue Details

Fetch the parent issue to get the original prompt:

```
skill: linear:linear-issue
args: get ID={ISSUE_ID}
```

Extract:
- **Title**: Issue title
- **Description**: Issue description (this is the original prompt/request)
- **Labels**: Any labels on the issue
- **State**: Current state

### 2. Get Sub-Issues

List sub-issues under the parent issue:

```
skill: linear:linear-issue
args: list PARENT_ID={ISSUE_ID}
```

Each sub-issue represents a clarified task document.

### 3. Get Sub-Issue Details

For each sub-issue, get the full details:

```
skill: linear:linear-issue
args: get ID={sub_issue_id}
```

Extract for each:
- **Task name**: Issue title
- **Description**: Issue description (contains the task requirements)
- **Dependencies**: Check `blockedBy` relationships

### 4. Get Comments (Optional Context)

Optionally get comments on the parent issue for additional context:

```
skill: linear:linear-comment
args: list ISSUE_ID={ISSUE_ID}
```

### 5. Return Loaded Data

Provide the loaded data for review:

```
Prompt:
  Source: ISSUE_ID
  Issue ID: {ISSUE_ID}
  Title: {parent_issue_title}
  Original Request: {parent_issue_description}
  Context: {comments summary if any}

Drafts:
  - Name: {sub_issue_1_title}
    Issue ID: {sub_issue_1_id}
    Dependencies: {blockedBy issue IDs}
    Description: {sub_issue_1_description}

  - Name: {sub_issue_2_title}
    Issue ID: {sub_issue_2_id}
    ...
```

## Parsing Sub-Issue Descriptions

Sub-issue descriptions may follow the draft-clarify output format:

```markdown
# Task Summary
...

# Acceptance Criteria
- [ ] ...

# Scope
## In Scope
...
## Out of Scope
...

# Constraints
...
```

Parse these sections to extract:
- Acceptance Criteria (checklist items)
- Scope definitions
- Constraints

## Error Handling

- If parent issue does not exist, report error and stop
- If parent issue has no sub-issues, report that there are no drafts to review
- If sub-issue has empty description, note it as incomplete

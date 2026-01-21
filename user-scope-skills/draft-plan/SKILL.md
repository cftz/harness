---
name: draft-plan
description: |
  Use this skill to create or modify draft execution plans in temporary files. Atomic skill for Phase A of planning workflow.

  Commands:
    create - Create new draft plan
      Task Source (OneOf, Required):
        TASK_PATH=<path> - Task document path
        ISSUE_ID=<id> - Issue ID (e.g., PROJ-123)
      Options:
        PROVIDER=linear|jira - Issue tracker provider (default: linear)
        OUTPUT_PATH=<path> - Output file path (uses mktemp if omitted)
    modify - Revise existing draft plan
      DRAFT_PATH=<path> (Required) - Existing draft to revise
      Feedback (OneOf, Required):
        FEEDBACK="<text>" - Feedback text
        FEEDBACK_PATH=<path> - Feedback file path

  Examples:
    /draft-plan create ISSUE_ID=TA-123
    /draft-plan create ISSUE_ID=PROJ-123 PROVIDER=jira
    /draft-plan create TASK_PATH=.agent/tmp/task.md
    /draft-plan modify DRAFT_PATH=.agent/tmp/plan.md FEEDBACK="Add error handling"
    /draft-plan modify DRAFT_PATH=.agent/tmp/plan.md FEEDBACK_PATH=.agent/tmp/review.md
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Description

Creates or modifies draft execution plans and writes them to temporary files. This is an atomic skill that handles Phase A (research and drafting) of the planning workflow, without user review or final output creation.

## Commands

| Command  | Description                             | Docs                             |
| -------- | --------------------------------------- | -------------------------------- |
| `create` | Create new draft plan from requirements | `{baseDir}/references/create.md` |
| `modify` | Revise existing draft based on feedback | `{baseDir}/references/modify.md` |

## Plan Document Format

Each plan document must include YAML frontmatter followed by the content sections.

### YAML Frontmatter

```yaml
---
title: Plan title based on requirements
issueId: Issue-ID  # Optional
---
```

- `title`: Plan title (used for issue title and dependency references)
- `issueId` (Optional): Linear issue ID this plan is associated with. Required only when `ISSUE_ID` parameter was provided.

### Overview

Brief description of the implementation goal (what problem is being solved).

### Package Changes (Optional)

If external packages need to be added or removed:

| Action | Problem               | Package                   | Reason    |
| :----- | :-------------------- | :------------------------ | :-------- |
| Add    | [Problem Description] | `github.com/some/package` | [Reason ] |
| Remove | [Problem Description] | `github.com/old/package`  | [Reason ] |

### Implementation Steps

For each step:

#### Step N: Implement [Feature Name] Logic

**Files to Read**:
- `.agent/rules/[relevant_rule].md`: [Reason for reading]
- `path/to/related/file.go`: [Reason for reading]

##### `path/to/target_file.go`

**Description**:
Brief approach for this file (e.g., "Add validation logic and DB update function").

```go
const (
    // ConstantName description
    ConstantName = "value"
)

type StructName struct {
    // FieldName description
    FieldName string
}

// FunctionName performs [Specific Action] based on [Logic].
func FunctionName(ctx context.Context, input string) (ResultType, error) {
    // Implementation outline:
    // 1. Validate the input parameter.
    // 2. Retrieve data from external source.
    // 3. Iterate through the retrieved items:
    //    a. If item meets Condition A:
    //       - Perform Logic A (e.g. update state).
    //    b. Else if item meets Condition B:
    //       - Perform Logic B (e.g. skip or log).
    // 4. If critical failure occurred during iteration:
    //    - Return specific error.
    // 5. Update repository with final results.
    // 6. Return success.
}
```

**Test Scenarios**:

| Scenario               | Input | Expected Output | Branch Covered        |
| :--------------------- | :---- | :-------------- | :-------------------- |
| Valid input            | `...` | Success with X  | Happy path            |
| Invalid param1         | `...` | Error: "..."    | Validation branch     |
| External service fails | `...` | Error: "..."    | Error handling branch |

### Summary of Changes

File changes summary with action types:

| File Path                       | Action | Description                 |
| ------------------------------- | ------ | --------------------------- |
| `internal/service/user/user.go` | Create | User service implementation |
| `internal/handler/http.go`      | Modify | Add user endpoints          |
| `internal/legacy/old.go`        | Delete | Remove deprecated code      |

**Action Types:**
- `Create` - New file
- `Modify` - Update existing file
- `Delete` - Remove file

## Quality Checklist

Before completing the draft, verify:

- [ ] Every function has a concrete signature (not "something like X")
- [ ] Detailed algorithm explanation is included as comments in the body of every function (no actual implementation code)
- [ ] Every function has test scenarios covering all branches
- [ ] No "or" statements leaving choices to Implementation Agent
- [ ] All packages are selected (not "candidate A or B")
- [ ] Execution order is clear and dependencies are explicit
- [ ] Summary of Changes table includes all target files with correct action types

## Notice

### Strict Decision Making

The execution plan must not contain vague content such as "Do A or B" or "needs investigation". All necessary details must be investigated and decided before creating the plan. If uncertain:

1. Research using available tools (Context7, codebase exploration)
2. Ask the user using `AskUserQuestion` if multiple valid approaches exist
3. Document the decision in the plan

### No User Review in This Skill

This skill only creates/modifies the draft. User review and final output creation should be handled by a separate workflow or the caller.

## Output

SUCCESS:
- DRAFT_PATH: Path to the created/modified draft plan file

ERROR: Error message string (e.g., "Task file not found: {path}", "Linear issue not found: {id}")

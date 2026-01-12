---
name: draft-clarify
description: |
  Creates or modifies draft task documents from requirements in temporary files. Atomic skill for Phase A of clarify workflow.

  Commands:
    create - Create new task documents
      Task Source (OneOf, Required):
        REQUEST="<text>" - Free-form user requirement text
        ISSUE_ID=<id> - Linear Issue ID (e.g., TA-123)
      Output (Optional):
        OUTPUT_DIR=<path> - Directory for temporary files (uses mktemp if omitted)
      Returns: PROMPT_PATH (original request file), DRAFT_PATHS (task documents)
    modify - Revise existing task documents
      DRAFT_PATHS=<paths> (Required) - Comma-separated paths to existing drafts
      Feedback (OneOf, Required):
        FEEDBACK="<text>" - Feedback text
        FEEDBACK_PATH=<path> - Feedback file path
      Optional:
        PROMPT_PATH=<path> - Original request file for context

  Examples:
    /draft-clarify create ISSUE_ID=TA-123
    /draft-clarify create REQUEST="Add user authentication feature"
    /draft-clarify modify DRAFT_PATHS=.agent/tmp/task1.md,.agent/tmp/task2.md FEEDBACK="Split auth into separate tasks"
    /draft-clarify modify DRAFT_PATHS=.agent/tmp/task1.md FEEDBACK_PATH=.agent/tmp/review.md PROMPT_PATH=.agent/tmp/prompt
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Draft Clarify Skill

Creates or modifies draft task documents and writes them to temporary files. This is an atomic skill that handles Phase A (requirements gathering and clarification) of the clarify workflow, without final output creation to artifacts or Linear.

## Commands

| Command  | Description                                 | Docs                             |
| -------- | ------------------------------------------- | -------------------------------- |
| `create` | Create new task documents from requirements | `{baseDir}/references/create.md` |
| `modify` | Revise existing drafts based on feedback    | `{baseDir}/references/modify.md` |

## Prompt File Format

The `create` command generates a prompt file that captures the original request for traceability. This file is used by `clarify-review` to validate that task documents properly address the original request.

```markdown
---
source: REQUEST | ISSUE_ID
issue_id: TA-123  # Only if source is ISSUE_ID
created_at: 2026-01-11T10:30:00Z
---

# Original Request

[Original REQUEST text or Linear Issue title + description]

# Context

[Additional context if source is ISSUE_ID: comments, labels, etc.]
```

## Output Format

Each task document must include YAML frontmatter followed by the content sections.

### YAML Frontmatter

```yaml
---
name: Task name
blockedBy:
  - Prerequisite task name
---
```

- `name`: Task identifier (used for issue title and dependency references)
- `blockedBy`: List of task names this task depends on (empty array `[]` if no dependencies)

### Task Summary

Provide a 2-3 sentence summary of what problem needs to be solved and what behavior is expected. Focus on the goal and context, not the implementation approach.

### Acceptance Criteria

List specific, testable requirements as checklist items. Each criterion should be verifiable and define what "done" means.

**Focus on behavior, not implementation:**

Good (behavior-level):
- "User is redirected to dashboard after successful login"
- "Password input is masked"
- "Error message is displayed for invalid credentials"
- "Search results update within 2 seconds"

Bad (implementation-level):
- "JWT token is stored in localStorage"
- "AuthContext uses useReducer for state management"
- "POST /api/auth/login endpoint is called"
- "UserRepository implements IUserRepository interface"

### Scope

Clearly define boundaries to prevent scope creep:

#### In Scope
- What will be built in this iteration
- What features will be included

#### Out of Scope
- What will NOT be built in this iteration
- What features are explicitly excluded

### Constraints

Document any technical, business, or timeline constraints that affect the implementation.

### Additional Context

Include any other relevant information:
- Prerequisite tasks that must be completed first
- Links to related documentation or tickets
- Dependencies on other work
- Background information

### Questions Resolved

Record all clarifying questions and user answers in a table format. This documents decisions made during clarification.

## Output Example

```markdown
---
name: User authentication
blockedBy: []
---

# Task Summary

[Provide 2-3 sentence summary explaining what problem needs to be solved and what behavior is expected]

# Acceptance Criteria

- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

# Scope

## In Scope
- [Feature or component to be built]
- [Another feature to be included]

## Out of Scope
- [Feature explicitly excluded from this iteration]
- [Another out-of-scope item]

# Constraints
- [Technical constraint if applicable]
- [Business constraint if applicable]
- [Timeline constraint if applicable]

# Additional Context
- [Link to related documentation]
- [Dependencies on other work]
- [Any other relevant background]

# Questions Resolved

| Question                      | Answer            |
| ----------------------------- | ----------------- |
| [Question asked to user]      | [User's answer]   |
| [Another clarifying question] | [User's response] |
```

## What NOT to Include

This skill produces **requirements documents**, not implementation plans. Do NOT include:

- **File/directory paths**: "Implement in src/components/Auth.tsx"
- **Class/function names**: "Create UserService class", "Add handleAuth function"
- **Technology stack decisions**: "Use Redux", "Implement with JWT tokens"
- **API endpoint paths**: "POST /api/v1/users"
- **Database schema details**: "Add user_tokens table with columns..."

**Exception**: Include implementation details ONLY if the user explicitly specified them as a requirement (e.g., "We must use PostgreSQL" -> include as a Constraint).

## Quality Checklist

Before completing the draft, verify:

- [ ] **User confirmation obtained**: Even if requirements seem complete, show summary and ask for confirmation
- [ ] **Specific requirements**: Avoid vague requirements like "make it better" - drill down to specifics
- [ ] **Testable criteria**: Each acceptance criterion should be verifiable at the behavior level
- [ ] **Clear scope**: Explicitly state what's in and out of scope to prevent scope creep
- [ ] **Documented decisions**: Record all clarifying questions and answers in "Questions Resolved" section
- [ ] **No implementation details**: Focus on WHAT/WHY, not HOW (unless user explicitly specified)
- [ ] **All decisions finalized**: No vague "A or B" options left unresolved

## Notice

### Strict Decision Making

All decisions must be finalized before output. Do not leave vague content such as "Do A or B" or "needs investigation". If multiple options exist:

1. Use `AskUserQuestion` to get user selection
2. Document the decision in the "Questions Resolved" section
3. Write the final decision to the task document

### No Final Output in This Skill

This skill only creates/modifies draft task documents in temporary files. User review and final output creation (to artifacts or Linear) should be handled by the `finalize-clarify` skill or the parent `clarify-workflow` workflow.

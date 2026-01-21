# `create` Command

Creates new draft task documents from requirements.

## Parameters

### Task Source (OneOf, Required)

Provide one of the following to specify where requirements come from:

- `REQUEST` - User's requirement text (free-form description)
- `ISSUE_ID` - Issue ID (e.g., `PROJ-123`)

### Options

- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`. Only used with ISSUE_ID.

### Output (Optional)

- `OUTPUT_DIR` - Directory path for temporary files. If not provided, uses `mktemp` skill to create files in `.agent/tmp/`.

## Process

### 0. Resolve Provider (if ISSUE_ID provided)

If `ISSUE_ID` is provided:
- If `PROVIDER` parameter is explicitly provided, use it
- If not provided, get from project-manage:
  ```
  skill: project-manage
  args: provider
  ```
  Use the returned provider value (or `linear` if project-manage not initialized)

### 1. Load Task Source

**If REQUEST provided:**
- Use the REQUEST text directly as the initial requirements

**If ISSUE_ID provided:**

Route based on resolved PROVIDER:

| PROVIDER           | Reference Document                     |
| ------------------ | -------------------------------------- |
| `linear` (default) | `{baseDir}/references/linear-task.md`  |
| `jira`             | `{baseDir}/references/jira-task.md`    |

Extract from issue:
- Title: Use as task context
- Description: Use as initial requirements text
- Labels: Note any relevant categorization
- Acceptance criteria (if defined in description)

### 2. Analyze Request Completeness

Check if all necessary information is present:
- Clear task description
- Acceptance criteria (what defines "done")
- Scope boundaries (what's included/excluded)
- Any constraints or dependencies

### 3. Ask Clarifying Questions

If information is missing or unclear, prepare structured questions focusing on:

- **What**: What exactly needs to be built/changed?
- **Why**: What problem does this solve?
- **Done**: How will we know it's complete? (Acceptance Criteria)
- **Scope**: What's in scope? What's out of scope?
- **Constraints**: Any technical constraints, deadlines, or dependencies?
- **Integration**: If multiple components involved, how do they interact?

> **CRITICAL**: Do NOT ask about implementation details (file locations, class names, code-level technology choices) unless the user explicitly mentions them. This skill focuses on **what** and **why**, not **how**.

> **IMPORTANT**: DO ask about scope-affecting architectural decisions:
> - If scope includes "request/communication from A to B" -> Ask: "Use existing gRPC or add new mechanism?"
> - If scope includes "data storage" -> Ask: "Add to existing DB schema? New storage?"
> - These are NOT implementation details - they define the scope boundary.

#### Checkpoint: Save Context if User Input Needed

When you need to ask clarifying questions, **save context and return** instead of using AskUserQuestion directly.

Use the `checkpoint` skill to save state and return AWAIT:

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

**ALWAYS confirm with user**, even if requirements seem complete:
- Show summary of understood requirements
- Ask: "Is this understanding correct?"
- Ask: "Are there any additional requirements or constraints?"

### 4. Break Down into Tasks

Based on the clarified requirements, break down the work into individual tasks. Tasks represent work units that can be executed in parallel.

Consider:
- Dependencies between tasks
- Logical groupings of related work
- Optimal parallelization opportunities

For example, if the requirement involves implementing an API server and its client, you might define tasks as: (1) API interface definition (prerequisite), then (2) client implementation and (3) server implementation (parallelizable).

### 5. Save Original Prompt

Create a prompt file to capture the original request for traceability:

```
skill: mktemp
args: prompt
```

Write the prompt file following the Prompt File Format defined in `{baseDir}/SKILL.md`:

- **If source is REQUEST**: Save the original REQUEST text in the "Original Request" section
- **If source is ISSUE_ID**: Save the Linear issue title + description in the "Original Request" section, and any additional context (comments, labels) in the "Context" section

This file is used by `clarify-review` to validate that task documents properly address the original request.

### 6. Create Output Files

- If `OUTPUT_DIR` is provided -> Write files to that directory with pattern `{OUTPUT_DIR}/task-{n}.md`
- If `OUTPUT_DIR` is not provided -> Use the `mktemp` skill:
  ```
  skill: mktemp
  args: task1 task2 task3
  ```

### 7. Write Draft Task Documents

Write each task's requirements document to a separate file following the Task Document Format defined in `{baseDir}/SKILL.md`.

## Output

SUCCESS:
- PROMPT_PATH: Path to the generated prompt file
- DRAFT_PATHS: Comma-separated list of task document paths

ERROR: Error message string

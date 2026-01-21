---
name: run-parallelly
description: |
  Executes multiple independent tasks in parallel. Use when user requests parallel execution or when tasks have no dependencies.

  Args:
    TASKS="..." (Required) - Comma-separated list of tasks to execute in parallel

  Examples:
    /run-parallelly TASKS="TA-123 plan creation, TA-124 plan creation, TA-125 plan creation"
    /run-parallelly TASKS="code review, run tests, lint check"
model: claude-opus-4-5
---

# Description

> **CRITICAL ROLE CONSTRAINT**
>
> You are an **ORCHESTRATOR**, not an implementer.
> You delegate work to SubAgents and coordinate their parallel execution.

Executes multiple independent tasks in parallel, collecting results and handling user interactions across all agents.

## When to Use

This skill should be invoked when:

1. **User explicitly requests parallel execution**: Keywords like "병렬로", "동시에", "한번에", "in parallel"
2. **AI determines tasks are independent**: Multiple tasks with no dependencies between them

## Parameters

### Required

- `TASKS` - Comma-separated list of tasks to execute in parallel

## Subagent Selection

Select the appropriate subagent based on task type:

| Task Type | Subagent | Reason |
|-----------|----------|--------|
| Can be handled by a Skill | `step-by-step-agent` | Execute skill with TodoWrite tracking |
| General tasks | `general-purpose` (Task tool) | Flexible execution for non-skill tasks |

### How to Determine Task Type

1. **Check if a skill exists**: Review available skills that match the task
   - If task mentions planning → `draft-plan`, `plan-workflow`
   - If task mentions review → `code-review`, `plan-review`
   - If task mentions Linear → `linear-issue`, `linear-document`
   - etc.

2. **If skill exists**: Use `step-by-step-agent` with skill invocation
3. **If no skill exists**: Use `general-purpose` Task agent

## Behavior Rules

### 1. Parallel Execution (NOT Background)

```
┌──────────────────────────────────────────────────────────────┐
│  CRITICAL: Unless explicitly instructed to run in background,│
│  tasks MUST run in PARALLEL (not background).                │
│                                                              │
│  Parallel = All tasks in ONE message, wait for ALL results   │
│  Background = Fire and forget, check later                   │
└──────────────────────────────────────────────────────────────┘
```

**Correct - Parallel execution:**
```
// Single message with multiple Task tool calls
Task(subagent_type: "step-by-step-agent", prompt: "Task A")
Task(subagent_type: "step-by-step-agent", prompt: "Task B")
Task(subagent_type: "general-purpose", prompt: "Task C")
// Wait for ALL results together
```

**Wrong - Background execution (unless explicitly requested):**
```
Task(..., run_in_background: true)  // NEVER do this unless user says "background"
```

### 2. Dependency-Free Design

Before parallel execution, gather all required information first:

```
┌─────────────────────────────────────────────┐
│ Phase 1: Information Gathering (Sequential) │
├─────────────────────────────────────────────┤
│ - Collect context for Task A                │
│ - Collect context for Task B                │
│ - Collect context for Task C                │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ Phase 2: Parallel Execution                 │
├─────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│ │ Task A  │ │ Task B  │ │ Task C  │        │
│ └────┬────┘ └────┬────┘ └────┬────┘        │
│      │          │          │              │
│      └──────────┴──────────┘              │
│                 │                          │
│            All Complete                    │
└─────────────────────────────────────────────┘
```

### 3. User Interaction Handling

When a SubAgent requires user input and returns with a question:

```
┌─────────────────────────────────────────────────────────────┐
│ SubAgent paused with question                               │
│                                                             │
│ 1. Detect the question in SubAgent's response               │
│ 2. Forward question to user via AskUserQuestion             │
│ 3. Receive user's answer                                    │
│ 4. Resume SubAgent with the answer using resume parameter   │
│                                                             │
│ Example:                                                    │
│   Task(resume: "agent-id-123", prompt: "User answered: X")  │
└─────────────────────────────────────────────────────────────┘
```

**Important**: Track all agent IDs returned from Task tool calls for potential resume.

### 4. Result Aggregation

Always synthesize and present combined results:

```markdown
## Parallel Execution Results

### Summary
- Total Tasks: {N}
- Completed: {M}
- Failed: {F}

### Task Results

#### Task 1: {description}
- Status: {Success/Failed}
- Result: {summary}

#### Task 2: {description}
- Status: {Success/Failed}
- Result: {summary}

...
```

## Process

### Step 1: Parse and Analyze Tasks

1. Parse the `TASKS` parameter into individual task descriptions
2. For each task:
   - Determine if it can be handled by a skill
   - Identify any information that needs to be gathered first
   - Check for dependencies between tasks

### Step 2: Gather Required Context

If tasks require shared context or information:

1. Collect all necessary information **before** parallel execution
2. This may include:
   - Reading relevant files
   - Fetching issue details
   - Understanding project structure

### Step 3: Launch Parallel Execution

1. Prepare all Task tool calls in a **single message**:

   ```
   // For skill-based tasks:
   Task(
     subagent_type: "step-by-step-agent",
     prompt: "Execute the following skill:\n/skill-name ARGS...\n\nContext: ...",
     description: "Task description"
   )

   // For general tasks:
   Task(
     subagent_type: "general-purpose",
     prompt: "Task description with full context",
     description: "Task description"
   )
   ```

2. Send all Task calls **simultaneously** (not sequentially)

3. Wait for all results

### Step 4: Handle Interactions

For each agent that requires user interaction:

1. Identify the question from agent's response
2. Ask user using AskUserQuestion:
   ```
   question: "[Agent N] {original question}"
   header: "Agent Input"
   options: {original options if available}
   ```
3. Resume agent with user's answer:
   ```
   Task(
     resume: "{agent-id}",
     prompt: "User responded: {answer}",
     subagent_type: "step-by-step-agent"
   )
   ```

### Step 5: Aggregate and Report

1. Collect all final results
2. Synthesize into a comprehensive summary
3. Report to user with clear status for each task

## Example Scenarios

### Scenario 1: Multiple Plan Creation

User: "Create plans for TA-123, TA-124, TA-125 in parallel"

```
Step 1: Parse tasks → 3 planning tasks
Step 2: No shared context needed
Step 3: Launch parallel
  - Task(step-by-step-agent, "/plan-workflow ISSUE_ID=TA-123")
  - Task(step-by-step-agent, "/plan-workflow ISSUE_ID=TA-124")
  - Task(step-by-step-agent, "/plan-workflow ISSUE_ID=TA-125")
Step 4: Handle any approval requests
Step 5: Report all plan results
```

### Scenario 2: Mixed Task Types

User: "Run code review and update README"

```
Step 1: Parse tasks → code-review (skill), README update (general)
Step 2: Gather context for both
Step 3: Launch parallel
  - Task(step-by-step-agent, "/code-review ...")
  - Task(general-purpose, "Update README with ...")
Step 4: Handle interactions
Step 5: Report combined results
```

## Error Handling

| Error Type | Action |
|------------|--------|
| Single task fails | Continue others, report failure in summary |
| All tasks fail | Report comprehensive error with details |
| Agent timeout | Report which agent timed out, include partial results |
| Resume fails | Ask user how to proceed (retry/skip/abort) |

## Output Format

```markdown
## Parallel Execution Complete

### Summary
| Metric | Value |
|--------|-------|
| Total Tasks | {N} |
| Succeeded | {M} |
| Failed | {F} |
| Required Interaction | {I} |

### Results

#### 1. {Task Description}
- **Agent**: {step-by-step-agent / general-purpose}
- **Status**: {Success / Failed / Partial}
- **Output**: {Brief summary or error message}

#### 2. {Task Description}
...

### Notes
{Any important observations or follow-up suggestions}
```

## Output

SUCCESS:
- TOTAL_TASKS: Number of tasks executed
- SUCCEEDED: Number of successful tasks
- FAILED: Number of failed tasks
- RESULTS: Array of task results (task, status, output summary)

ERROR: Error message string (e.g., "No tasks provided", "All tasks failed")

## Quality Checklist

Before completing, verify:

- [ ] **All tasks parsed correctly**: Each task identified and categorized
- [ ] **Correct subagents selected**: Skill tasks use step-by-step, general use general-purpose
- [ ] **Parallel execution used**: All independent tasks launched in ONE message
- [ ] **No background unless requested**: `run_in_background` only if user explicitly asked
- [ ] **Interactions handled**: All agent questions forwarded to user and resumed
- [ ] **Results aggregated**: Comprehensive summary provided to user

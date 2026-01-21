# Orchestrator Skill Template

Use this template for skills that coordinate SubAgents/Skills in parallel.

## Characteristics

- Parallel execution of independent tasks
- SubAgent delegation via Task tool
- Result aggregation
- User interaction forwarding

## Directory Structure

```
{skill-name}/
├── SKILL.md       # Main skill definition
└── README.md      # Intent documentation
```

Note: Orchestrators typically don't need `references/` or `scripts/` directories.

## SKILL.md Template

```markdown
---
name: {skill-name}
description: |
  {Purpose description}. Use when {usage context}.

  Args:
    TASKS="..." (Required) - {Description of tasks parameter}

  Examples:
    /{skill-name} TASKS="task1, task2, task3"
model: claude-opus-4-5
---

# Description

> **CRITICAL ROLE CONSTRAINT**
>
> You are an **ORCHESTRATOR**, not an implementer.
> You delegate work to SubAgents and coordinate their parallel execution.

{Detailed description of what the skill orchestrates.}

## When to Use

This skill should be invoked when:

1. **{Trigger 1}**: {Description}
2. **{Trigger 2}**: {Description}

## Parameters

### Required

- `TASKS` - {Description of tasks parameter}

## Subagent Selection

Select the appropriate subagent based on task type:

| Task Type | Subagent | Reason |
|-----------|----------|--------|
| Can be handled by a Skill | `step-by-step-agent` | Execute skill with TodoWrite tracking |
| General tasks | `general-purpose` | Flexible execution for non-skill tasks |

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

### 2. Dependency-Free Design

Before parallel execution, gather all required information first.

### 3. User Interaction Handling

When a SubAgent requires user input:
1. Detect the question in SubAgent's response
2. Forward question to user via AskUserQuestion
3. Receive user's answer
4. Resume SubAgent with the answer using resume parameter

### 4. Result Aggregation

Always synthesize and present combined results.

## Process

### Step 1: Parse and Analyze Tasks

1. Parse the `TASKS` parameter into individual task descriptions
2. Determine subagent type for each task
3. Check for dependencies between tasks

### Step 2: Gather Required Context

If tasks require shared context:
1. Collect all necessary information before parallel execution
2. This includes reading files, fetching issue details, etc.

### Step 3: Launch Parallel Execution

1. Prepare all Task tool calls in a **single message**
2. Send all Task calls simultaneously
3. Wait for all results

### Step 4: Handle Interactions

For each agent that requires user interaction:
1. Identify the question
2. Ask user using AskUserQuestion
3. Resume agent with user's answer

### Step 5: Aggregate and Report

1. Collect all final results
2. Synthesize into comprehensive summary
3. Report to user with clear status for each task

## Error Handling

| Error Type | Action |
|------------|--------|
| Single task fails | Continue others, report failure in summary |
| All tasks fail | Report comprehensive error with details |
| Agent timeout | Report which agent timed out, include partial results |
| Resume fails | Ask user how to proceed |

## Output

SUCCESS:
- TOTAL_TASKS: Number of tasks executed
- SUCCEEDED: Number of successful tasks
- FAILED: Number of failed tasks
- RESULTS: Array of task results

ERROR: Error message string

## Quality Checklist

Before completing, verify:

- [ ] **All tasks parsed correctly**: Each task identified and categorized
- [ ] **Correct subagents selected**: Skill tasks use step-by-step, general use general-purpose
- [ ] **Parallel execution used**: All independent tasks launched in ONE message
- [ ] **No background unless requested**: `run_in_background` only if user explicitly asked
- [ ] **Interactions handled**: All agent questions forwarded to user and resumed
- [ ] **Results aggregated**: Comprehensive summary provided to user
```

## README.md Template

```markdown
# {Skill Name}

## Intent

{What parallel coordination this skill provides.}

## Motivation

{Why parallel execution is beneficial for this use case.}

## Design Decisions

- **Parallel, not background**: Ensures all results are collected together
- **SubAgent delegation**: Leverages specialized agents for different task types
- **User interaction forwarding**: Maintains user control over decisions

## Constraints

- Must not run tasks in background unless explicitly requested
- Must aggregate all results before reporting
- Must forward user questions from SubAgents
```

# Run Parallelly Skill

## Intent

Provide a standardized way to execute multiple independent tasks in parallel using SubAgents. This skill acts as an orchestrator that delegates work to appropriate subagents (step-by-step-agent for skill-based tasks, general-purpose for other tasks) and coordinates their parallel execution.

The skill solves the problem of efficiently handling multiple independent tasks by:
1. Parsing comma-separated task lists
2. Determining the appropriate subagent for each task type
3. Executing all tasks simultaneously in a single message
4. Handling user interactions across all agents
5. Aggregating and presenting combined results

## Motivation

When users have multiple independent tasks (e.g., creating plans for multiple issues, running code review and tests simultaneously), sequential execution is inefficient. This skill enables parallel execution while maintaining proper result aggregation and user interaction handling.

## Design Decisions

- **Orchestrator pattern**: The skill does not implement tasks itself; it delegates to SubAgents
- **Parallel, not background**: Tasks run in parallel (wait for all) rather than background (fire and forget) unless explicitly requested
- **Two subagent types**: step-by-step-agent for skill-invocable tasks, general-purpose for everything else
- **Information gathering first**: Shared context is collected before parallel execution to avoid dependencies between tasks

## Constraints

- Should NOT execute tasks sequentially when they are independent
- Should NOT use background execution unless user explicitly requests it
- Should NOT implement task logic directly; always delegate to SubAgents
- Should NOT launch tasks with dependencies in parallel

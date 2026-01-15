# Plan Issues Skill

## Intent

Provide batch planning capability for multiple Linear issues in parallel. This skill automates the process of finding eligible issues, creating plans for each in parallel, running auto-reviews, and registering approved plans back to Linear.

## Motivation

When a project has many issues needing plans, processing them one by one is time-consuming. This skill enables efficient batch processing by:
1. Finding issues in specified states (e.g., Todo, Backlog)
2. Running plan creation in parallel for multiple issues
3. Auto-reviewing all plans before user approval
4. Attaching approved plans to their respective issues

## Design Decisions

1. **Orchestrator pattern**: Delegates to step-by-step-agent for plan creation and review
2. **Parallel execution**: Processes multiple issues simultaneously to save time
3. **Configurable limits**: LIMIT parameter prevents overwhelming the system
4. **State filtering**: STATE parameter allows targeting specific workflow states

## Constraints

- Should NOT implement planning logic directly (delegate to plan-workflow/draft-plan)
- Should NOT skip user approval for final plan attachment
- Should NOT process more than LIMIT issues simultaneously

# Finalize Implement Skill

## Intent

Finalize an implementation cycle by performing git operations (commit, push, PR creation) and optionally updating Linear issue state. This skill serves as the final step in the implementation workflow, ensuring code changes are properly committed, pushed to remote, and tracked in project management.

Key design goals:
- Idempotent operations - safe to re-run without side effects
- Branch-aware behavior - different flow for feature vs default branches
- Optional Linear integration - works with or without issue tracking

## Motivation

Implementation workflows need a consistent way to finalize code changes. Previously, git operations were scattered across different skills or manually performed. This skill consolidates:
- Commit creation with proper messaging
- Push to remote with upstream tracking
- PR creation for feature branches
- Linear state updates for issue tracking

## Design Decisions

1. **No branch creation**: This skill works on the current branch only. Branch decisions are made before this skill runs.
2. **Idempotent by design**: Each operation checks state before acting, making it safe to retry or re-run.
3. **Optional Linear integration**: The `ISSUE_ID` parameter is optional, allowing this skill to work in non-Linear workflows.
4. **Branch-aware PR behavior**: Only creates PRs on feature branches. Default branch mode pushes directly.

## Constraints

- NEVER creates new branches (works on current branch only)
- NEVER switches branches
- Does NOT perform code review (handled by upstream skills)
- Does NOT make implementation decisions

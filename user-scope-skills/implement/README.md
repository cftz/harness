# Implement Skill

## Intent

Execute implementation plans exactly as specified without adding extra features or making unauthorized changes. This skill handles both initial implementation from plans and iterative fixes based on code review feedback.

## Motivation

Implementation should be separated from planning and review to ensure:
- Plans are executed faithfully without scope creep
- Review feedback is addressed systematically
- Clear separation of concerns between creation and validation

## Design Decisions

- **Two commands**: `execute` for initial implementation, `fix` for addressing review feedback
- **Strict adherence**: Implements exactly what the plan specifies, no "improvements"
- **Multiple input sources**: Supports both artifact files and Linear issues as sources

## Constraints

- Should NOT add features beyond what the plan specifies
- Should NOT refactor unrelated code during implementation
- Should NOT make architectural decisions (those belong in planning)
- Should NOT skip any planned changes

# Plan Review Skill

## Intent

Validate plan documents against project rules defined in `.agent/rules/` before implementation begins. This skill ensures that proposed changes follow coding standards, architectural patterns, and dependency guidelines, catching rule violations early in the development process.

## Motivation

Without pre-implementation review, developers may implement plans that violate project standards, leading to:
- Code review rejections
- Refactoring after implementation
- Inconsistent codebase patterns

This skill automates the validation process to catch issues before code is written.

## Design Decisions

1. **Rule-based validation**: Reviews are based on `.agent/rules/` files, not subjective opinions
2. **Task alignment check**: When ISSUE_ID is provided, verifies plan covers all acceptance criteria
3. **Approved vs Revision Needed output**: Binary result with actionable fixes for failed reviews
4. **Multiple input sources**: Supports direct path, artifact directory, and Linear issue

## Constraints

- Does NOT modify plan documents (read-only analysis)
- Does NOT implement any code (review only)
- Does NOT approve plans that violate rules (strict compliance)

# Code Review Skill

## Intent

Validate implementations against project rules defined in `.agent/rules/`. This skill acts as an automated code review gate to ensure all changes comply with established project standards.

## Motivation

Manual code review for rule compliance is inconsistent and time-consuming. This skill:
- Ensures consistent application of project rules
- Catches violations before they reach main branch
- Provides actionable feedback with specific file:line references
- Reduces review burden on human reviewers

## Design Decisions

1. **Git-based change detection**: Reviews only modified files, not entire codebase
2. **Rule-based validation**: Uses `.agent/rules/` as single source of truth
3. **Requirements-format output**: Violations are documented as actionable requirements
4. **READ-ONLY operation**: Never modifies repository state during review

## Constraints

- This skill should NOT modify any source files
- This skill should NOT run git commands that alter state (commit, push, checkout, etc.)
- This skill should NOT review files that haven't changed
- This skill should NOT invent rules not documented in `.agent/rules/`

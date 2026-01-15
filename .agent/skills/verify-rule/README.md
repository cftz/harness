# Verify Rule Skill

## Intent

Analyze rule files in `.agent/rules/` directories to ensure consistency, eliminate conflicts, remove duplications, and clarify ambiguities. This skill helps maintain a clean and coherent rule set that agents can follow without encountering contradictory or confusing instructions.

## Motivation

As rule files accumulate over time, they can develop inconsistencies:
- Rules added in different files may contradict each other
- Common patterns may be duplicated across multiple files
- Vague language may lead to inconsistent agent behavior

This skill provides systematic analysis and correction of these issues.

## Design Decisions

- **Glob Pattern Hierarchy**: Uses glob patterns to determine rule precedence - more specific patterns override more general ones
- **Interactive by Default**: Presents findings to user for approval before making changes (unless AUTO_FIX=true)
- **Non-Destructive**: Creates references between files rather than deleting content where possible

## Constraints

- This skill should NOT modify code files - only `.md` rule files
- This skill should NOT create new rules - only reorganize existing ones
- This skill should NOT be used for initial rule creation - use for maintenance only

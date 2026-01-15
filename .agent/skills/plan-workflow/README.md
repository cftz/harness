# Plan Workflow Skill

## Intent

Orchestrate the complete planning workflow by combining draft-plan, plan-review, and finalize-plan skills with automated review loop and user approval gates.

## Motivation

The planning process involves multiple steps that must be coordinated:
1. Creating initial draft from requirements
2. Reviewing draft for rule compliance
3. Iterating on feedback until approved
4. Finalizing to artifacts or Linear documents

Manual coordination is error-prone. This workflow automates the loop while maintaining user control at approval points.

## Design Decisions

1. **Orchestrator pattern**: Delegates to atomic skills rather than implementing logic directly
2. **Auto-fix loop**: Automatically incorporates review feedback up to MAX_CYCLES
3. **User approval gate**: Always requires explicit user approval before finalization (unless AUTO_ACCEPT)
4. **Flexible output**: Supports both artifact directories and Linear document creation

## Constraints

- Should NOT skip user approval unless AUTO_ACCEPT=true
- Should NOT exceed MAX_CYCLES without user intervention
- Should NOT modify drafts directly - delegates to draft-plan for modifications

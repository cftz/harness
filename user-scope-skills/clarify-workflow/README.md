# Clarify Workflow Skill

## Intent

Orchestrate the complete clarification workflow by combining draft-clarify, clarify-review, and finalize-clarify skills with automated review loop and user approval gates.

## Motivation

The clarification process involves multiple steps that must be coordinated:
1. Creating initial drafts from requirements
2. Reviewing drafts for compliance
3. Iterating on feedback until approved
4. Finalizing to artifacts or Linear issues

Manual coordination is error-prone. This workflow automates the loop while maintaining user control at approval points.

## Design Decisions

1. **Orchestrator pattern**: Delegates to atomic skills rather than implementing logic directly
2. **Auto-fix loop**: Automatically incorporates review feedback up to MAX_CYCLES
3. **User approval gate**: Always requires explicit user approval before finalization
4. **Flexible output**: Supports both artifact directories and Linear issue creation

## Constraints

- This skill should NOT exceed MAX_CYCLES without user intervention
- This skill should NOT modify drafts directly - delegates to draft-clarify for modifications
- When AUTO_ACCEPT=true, user review step is skipped but auto-review loop still runs

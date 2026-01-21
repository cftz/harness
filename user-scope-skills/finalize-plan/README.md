# Finalize Plan Skill

## Intent

Convert approved temporary draft plan files to final outputs (Artifact files or Linear Documents). This skill handles the "finalization" phase of the planning workflow, ensuring that only approved plans are written to persistent storage.

## Motivation

The planning workflow separates draft creation from finalization to enable:
1. Safe iteration on drafts in temporary storage
2. Review and approval gates before writing final content
3. Consistent output format across different destinations (artifact vs Linear)

## Design Decisions

- **Two output modes**: Supports both artifact directory (file-based) and Linear Document (API-based) outputs
- **State update**: When saving to Linear, automatically updates issue state to "Todo" to indicate planning is complete
- **Single file operation**: Operates on one draft file at a time for clarity

## Constraints

- Should NOT create or modify draft files (that is `draft-plan`'s responsibility)
- Should NOT validate plans (that is `plan-review`'s responsibility)
- Should NOT be called without user approval (except when `AUTO_ACCEPT=true` in workflow)
- Expects draft files in the format produced by `draft-plan`

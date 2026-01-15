# Finalize Clarify Skill

## Intent

Provide a reliable way to convert approved draft task documents into their final output destinations (artifact files or Linear issues). This skill handles the "finalization" phase of the clarify workflow, ensuring that only approved content is written to persistent storage.

## Motivation

The clarify workflow separates draft creation from finalization to enable:
1. Safe iteration on drafts in temporary storage
2. Review and approval gates before writing final content
3. Consistent output format across different destinations (artifact vs Linear)

## Design Decisions

- **Two output modes**: Supports both artifact directory (file-based) and Linear (API-based) outputs
- **Dependency resolution**: When creating Linear issues, automatically resolves blocking relationships from task dependencies
- **Parent issue support**: Can create sub-issues under a specified parent issue
- **Atomic operation**: Converts all drafts in a single invocation to ensure consistency

## Constraints

- Should NOT create or modify draft files (that is `draft-clarify`'s responsibility)
- Should NOT validate content (that is `clarify-review`'s responsibility)
- Should NOT be called without user approval (except when `AUTO_ACCEPT=true` in workflow)
- Expects draft files in the format produced by `draft-clarify`

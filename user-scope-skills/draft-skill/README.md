# Draft Skill

## Intent

Create skill drafts in temporary files for review and validation before finalization. This is the atomic "Phase 1" skill in the edit-skill-workflow pattern (draft-* → *-review → finalize-*).

## Motivation

Skill creation/modification should follow the workflow pattern used by other skills (plan, clarify, implement). By separating draft creation from validation and finalization:
- Drafts can be reviewed before committing to the final location
- The skill-review skill can validate drafts independently
- Failed validations can trigger automatic fixes
- Users can approve changes before finalization

## Design Decisions

1. **Outputs to temp files only**: Never writes directly to final skill location
2. **Two commands (create/modify)**: Separate flows for new skills vs editing existing ones
3. **Type-based templates**: Five skill types (workflow, orchestrator, utility, integration, validation) with specific templates
4. **Intent preservation in modify**: Checks README.md to understand original intent before making changes
5. **Returns DRAFT_PATH**: Standardized output for workflow integration

## Constraints

- Does NOT validate skills - use skill-review for validation
- Does NOT finalize skills - use finalize-skill to write to final location
- Does NOT execute the created/modified skills - only creates drafts
- Should NOT skip user confirmation for structural changes (within the skill)

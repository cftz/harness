# Draft Plan Skill

## Intent

Create and modify draft execution plans in temporary files. This is the atomic planning skill that handles Phase A (research and drafting) of the planning workflow, designed to be composed with review and finalization skills.

## Motivation

Planning should be separated from review and finalization to enable:
- Automated review loops that can iterate on drafts without user intervention
- Clear separation of concerns between creation, validation, and persistence
- Reusable atomic skill that can be called by orchestrators

## Design Decisions

- **Temporary files only**: This skill writes to temp files, never to final destinations
- **Two commands**: `create` for new plans, `modify` for revisions based on feedback
- **Strict decisions**: Plans must not contain vague content like "A or B" - all choices are made during planning

## Constraints

- Does NOT perform user review (handled by orchestrator)
- Does NOT save to final destinations (handled by finalize-plan)
- Does NOT validate plans (handled by plan-review)

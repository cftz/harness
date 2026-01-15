# Draft Clarify Skill

## Intent

Create and modify draft task documents from user requirements, focusing on the clarification phase of the workflow. This skill transforms vague or incomplete requirements into well-defined, testable task specifications through structured questioning and documentation.

The skill produces **requirements documents**, not implementation plans. It focuses on WHAT and WHY (behavior-level requirements), not HOW (implementation details).

## Motivation

Requirements clarification is a critical first step before implementation. Poorly defined requirements lead to wasted effort, scope creep, and misaligned implementations. This skill ensures that:

1. Requirements are captured in a consistent, structured format
2. Ambiguities are resolved through explicit user questions
3. Acceptance criteria are behavior-focused and testable
4. Scope boundaries are clearly defined

## Design Decisions

- **Atomic Skill**: Handles only draft creation/modification. Final output to artifacts or Linear is delegated to `finalize-clarify`.
- **Temporary Files**: All output is written to temporary files (`.agent/tmp/`) until approved by the user.
- **Two Commands**: `create` for new requirements, `modify` for revisions based on feedback.
- **Prompt File**: A prompt file is generated to capture the original request for traceability during review and revision cycles.

## Constraints

This skill should NOT:
- Include implementation details (file paths, class names, API endpoints) unless explicitly specified by the user
- Write directly to artifact directories or Linear (use `finalize-clarify` for that)
- Leave decisions unresolved (all "A or B" options must be resolved via user questions)
- Skip user confirmation even when requirements seem complete

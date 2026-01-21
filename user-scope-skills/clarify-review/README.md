# Clarify Review Skill

## Intent

Validate clarified task documents before finalization to ensure they follow draft-clarify rules and properly address the original request. This skill acts as a quality gate between clarification and finalization phases.

## Motivation

Task documents created during clarification must meet quality standards before being converted to final artifacts or Linear issues. This review ensures:
- Rule compliance: Documents follow behavior-level specification standards
- Prompt alignment: No scope creep or omissions from original request
- Consistency: All required sections are present and properly formatted

## Design Decisions

1. **Two-category review**: Separates rule compliance (A) from prompt alignment (B) for clarity
2. **Checklist-based**: Explicit checklists ensure consistent review quality
3. **Binary outcome**: Either "Approved" or "Revision Needed" - no partial states
4. **Temp file default**: Allows iteration before finalizing to permanent storage

## Constraints

- This skill should NOT modify the draft documents being reviewed
- This skill should NOT auto-fix issues - only report them
- This skill should NOT create Linear issues (clarify stage precedes issue creation)

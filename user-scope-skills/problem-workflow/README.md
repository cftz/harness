# Problem Workflow

## Intent

Provides a structured workflow for analyzing problems and generating solution ideas. This skill helps users move from a vague problem statement to concrete, actionable solution recommendations.

## Motivation

Problem-solving is often ad-hoc and unstructured. This workflow ensures:
- Problems are properly analyzed before jumping to solutions
- The appropriate ideation approach is selected based on problem characteristics
- Solutions are grounded in real-world examples and documented approaches
- Users review and approve both analysis and solutions before finalization

## Design Decisions

- **Two-phase workflow**: Analysis before solution ensures the right approach is used
- **User review at each phase**: Creative work requires human judgment, not automated validation
- **No auto-review loop**: Unlike implementation workflows, problem-solving benefits from human review rather than rule-based validation
- **Approach-based ideation**: Matches problem specificity to the right solution strategy

## Constraints

- Must not skip user review at either phase
- Must not proceed to solution without approved analysis
- Must not finalize without explicit user approval
- Analysis approach (best-practice/analogous/cross-domain) determines solution strategy

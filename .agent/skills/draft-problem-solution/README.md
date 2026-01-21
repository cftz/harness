# Draft Problem Solution Skill

## Intent

Create and modify draft solution documents in temporary files. This is the atomic ideation skill that handles the solution generation phase of problem-solving workflow, designed to be composed with analysis and finalization skills.

## Motivation

Solution generation should be separated from analysis and finalization to enable:
- Clear problem analysis before jumping to solutions
- Focused ideation using the most appropriate approach
- Automated review loops that can iterate on drafts without user intervention
- Reusable atomic skill that can be called by orchestrators

## Design Decisions

- **Temporary files only**: This skill writes to temp files, never to final destinations
- **Two commands**: `create` for new solutions, `modify` for revisions based on feedback
- **Analysis-based**: Requires a problem analysis as input to ensure appropriate approach selection
- **WebSearch-based exploration**: Uses web search to find real-world examples and references rather than generating ideas purely from LLM knowledge
- **Structured output format**: Ideas are presented with clear attribution, principles, and actionable next steps
- **Ranked recommendations**: Top 3 ideas are highlighted with rationale to help users prioritize

## Constraints

- Does NOT perform user review (handled by orchestrator)
- Does NOT save to final destinations (handled by finalize-problem-solution)
- Does NOT make implementation decisions (this is ideation only)
- Requires user validation for cross-domain ideas due to potential applicability gaps

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

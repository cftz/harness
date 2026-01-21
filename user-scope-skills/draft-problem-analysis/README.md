# Draft Problem Analysis Skill

## Intent

Create and modify draft problem analysis documents in temporary files. This is the atomic analysis skill that handles the first phase of problem-solving workflow, designed to be composed with solution generation and finalization skills.

## Motivation

Problem analysis should be separated from solution generation to enable:
- Clear problem understanding before jumping to solutions
- Appropriate approach selection based on problem characteristics
- Reusable atomic skill that can be called by orchestrators or directly by users

## Design Decisions

- **Temporary files only**: This skill writes to temp files, never to final destinations
- **Two commands**: `create` for new analyses, `modify` for revisions based on feedback
- **Specificity-based recommendations**: Analyzes problem characteristics to recommend the best ideation approach
- **WebSearch-based exploration**: Uses web search to understand problem context before recommending approaches

## Constraints

- Does NOT perform user review (handled by orchestrator)
- Does NOT save to final destinations (handled by finalize-problem-solution)
- Does NOT generate solutions (handled by draft-problem-solution)

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

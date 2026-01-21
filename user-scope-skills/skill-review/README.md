# Skill Review

## Intent

Provide automated verification of skill documentation to ensure standards compliance, catch inconsistencies, and prevent maintenance issues before they cause problems. This is the "Phase 2" skill in the edit-skill-workflow pattern (draft-* → *-review → finalize-*).

This skill serves as a quality gate for skill development by:
- Detecting structural violations (non-standard directories, missing files)
- Validating frontmatter fields and description quality
- Checking parameter name consistency across documentation
- Verifying dependent skill interfaces are valid
- Finding documentation duplication that creates maintenance burden

## Motivation

As the number of skills grows, maintaining consistency and quality becomes challenging. Manual review is error-prone and time-consuming. This skill automates the verification process to catch issues early.

In the workflow pattern, skill-review enables:
- Auto-fix loops where draft-skill creates drafts and skill-review validates them
- Iterative improvement until validation passes
- Quality gate before finalization

## Design Decisions

1. **Severity levels**: Issues are categorized as Critical (will fail), High (causes confusion), or Medium (quality issues) to help prioritize fixes
2. **Self-contained checks**: Each check is independent and produces clear, actionable findings
3. **Multi-scope support**: Can verify skills in user scope (`~/.claude/skills/`) or project scope (`.agent/skills/`)
4. **Pass/Fail output**: Returns clear Pass or Fail status for workflow integration

## Constraints

- This skill only verifies documentation structure and consistency
- It does NOT execute skills or test runtime behavior
- It does NOT modify files directly (only suggests fixes)

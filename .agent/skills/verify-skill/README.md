# Verify Skill

## Intent

Provide automated verification of skill documentation to ensure standards compliance, catch inconsistencies, and prevent maintenance issues before they cause problems.

This skill serves as a quality gate for skill development by:
- Detecting structural violations (non-standard directories, missing files)
- Validating frontmatter fields and description quality
- Checking parameter name consistency across documentation
- Verifying dependent skill interfaces are valid
- Finding documentation duplication that creates maintenance burden

## Motivation

As the number of skills grows, maintaining consistency and quality becomes challenging. Manual review is error-prone and time-consuming. This skill automates the verification process to catch issues early.

## Design Decisions

1. **Severity levels**: Issues are categorized as Critical (will fail), High (causes confusion), or Medium (quality issues) to help prioritize fixes
2. **Self-contained checks**: Each check is independent and produces clear, actionable findings
3. **Optional fix suggestions**: The FIX=true parameter enables detailed remediation guidance without cluttering the default report

## Constraints

- This skill only verifies documentation structure and consistency
- It does NOT execute skills or test runtime behavior
- It does NOT modify files directly (only suggests fixes)

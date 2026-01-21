# suggest-improvements

## Intent

Provides checklist-based code analysis to identify issues in specific areas (repository layer, service layer, security, etc.). Each checklist defines check items for a specific domain, enabling targeted and consistent code quality reviews.

## Motivation

Manual code reviews are time-consuming and often inconsistent. Teams need a systematic way to:
- Check code against predefined quality criteria for specific layers/areas
- Ensure consistent review standards across the team
- Prioritize issues based on severity
- Generate actionable reports that can be tracked in existing tools (Linear)

## Design Decisions

1. **Checklist-based analysis**: Each target (repository, security, etc.) has its own checklist with specific check items and severity levels
2. **Targeted execution**: Run analysis on specific areas rather than scanning everything - more focused and actionable
3. **`all` option**: Can run all available checklists at once when comprehensive review is needed
4. **Multiple output destinations**: Supports temp files, artifacts, and Linear integration for flexibility
5. **Read-only operation**: Ensures safe, non-invasive analysis that can run anytime without risk
6. **Severity-based categorization**: Clear severity levels help teams triage and prioritize issues

## Constraints

- **Read-only**: Must never modify the codebase
- **Non-exhaustive**: May not catch all possible issues; human review still recommended
- **Checklist-dependent**: Analysis quality depends on checklist completeness

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

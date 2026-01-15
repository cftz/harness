# Edit Skill

## Intent

Provide a standardized way to create new skills or modify existing ones, ensuring proper structure, naming conventions, and validation. This skill guides users through type selection, parameter design, and structure generation rather than allowing manual ad-hoc creation.

## Motivation

Skills have specific structural requirements (directory layout, frontmatter fields, path references) that are easy to violate when created manually. This skill enforces consistency and quality by:
- Validating skill names follow kebab-case convention
- Ensuring required files (SKILL.md, README.md) are created
- Using templates appropriate for each skill type
- Running verify-skill after creation/modification

## Design Decisions

1. **Two-mode operation (create/modify)**: Separate flows for new skills vs editing existing ones to provide appropriate guidance for each case
2. **Type-based templates**: Five skill types (workflow, orchestrator, utility, integration, validation) with specific templates to match common patterns
3. **Temporary draft workflow**: Uses mktemp to create drafts for user review before finalizing
4. **Intent preservation**: Modify mode checks README.md to understand original intent before making changes
5. **Validation integration**: Always runs verify-skill after operations to catch issues early

## Constraints

- Does NOT execute the created/modified skills - only creates/modifies documentation and structure
- Does NOT handle skill deletion - users must manually remove skill directories
- Does NOT support batch operations - one skill at a time
- Should NOT create skills in locations other than `.agent/skills/`
- Should NOT skip user confirmation for structural changes

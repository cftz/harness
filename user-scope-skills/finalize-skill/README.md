# Finalize Skill

## Intent

Write approved skill drafts from temporary files to their final location. This is the "Phase 3" skill in the edit-skill-workflow pattern (draft-* → *-review → finalize-*).

## Motivation

Skill creation should follow the workflow pattern:
1. **draft-skill**: Creates drafts in temp files
2. **skill-review**: Validates drafts against standards
3. **finalize-skill**: Writes approved drafts to final location

This separation ensures:
- Drafts can be reviewed and fixed before committing
- Failed validations don't leave partial files
- Users approve the final output location and scope

## Design Decisions

1. **Scope selection**: Supports both user scope (`~/.claude/skills/`) and project scope (`.agent/skills/`)
2. **Overwrite confirmation**: Asks before overwriting existing skills
3. **Temp file cleanup**: Automatically removes temp files after successful finalization
4. **Multi-file support**: Handles SKILL.md, README.md, references/, and scripts/

## Constraints

- Does NOT create skill content - use draft-skill for that
- Does NOT validate skills - use skill-review for validation
- Requires draft files to exist before finalization
- Only writes to standard skill locations (user or project scope)

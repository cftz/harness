# Edit Skill Workflow

## Intent

Provide a complete, automated workflow for creating and modifying skills with built-in review, auto-fix, and finalization. This is the primary entry point for skill management, replacing direct use of individual atomic skills.

## Motivation

Creating skills manually is error-prone:
- Easy to violate structural standards
- No automatic validation
- Manual file management

The workflow pattern (draft-* → *-review → finalize-*) provides:
- Automated validation with skill-review
- Auto-fix loops to resolve issues
- User approval before committing changes
- Clean separation of concerns

## Design Decisions

1. **Orchestrator pattern**: Coordinates atomic skills rather than implementing logic directly
2. **Auto-fix loop**: Automatically attempts to fix issues up to MAX_CYCLES times
3. **User approval gate**: Requires explicit approval before finalization (unless AUTO_ACCEPT=true)
4. **Scope selection**: Supports user scope and project scope targets
5. **Cycle tracking**: Reports progress through each review cycle

## Constraints

- Does NOT implement skill content directly - delegates to draft-skill
- Does NOT validate directly - delegates to skill-review
- Does NOT write files directly - delegates to finalize-skill
- Must respect MAX_CYCLES limit
- Must allow user to cancel at approval phase

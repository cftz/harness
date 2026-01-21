# Finalize Problem Solution Skill

## Intent

Convert approved temporary draft solution files to final outputs (Artifact files, Linear Documents, or Linear Issues). This skill handles the "finalization" phase of the problem-solving workflow, ensuring that only approved solutions are written to persistent storage.

## Motivation

The problem-solving workflow separates draft creation from finalization to enable:
1. Safe iteration on drafts in temporary storage
2. Review and approval gates before writing final content
3. Consistent output format across different destinations (artifact vs Linear)
4. Flexibility in how solutions are recorded (as documents or actionable issues)

## Design Decisions

- **Three output modes**: Supports artifact directory (file-based), Linear Document (attached to issue), and Linear Issue/Document (in project)
- **NEW_ISSUE flag**: When using PROJECT_ID, allows creating either an actionable Issue or a reference Document
- **Single file operation**: Operates on one draft file at a time for clarity

## Constraints

- Should NOT create or modify draft files (that is `draft-problem-solution`'s responsibility)
- Should NOT be called without user approval (except when AUTO_ACCEPT=true in workflow)
- Expects draft files in the format produced by `draft-problem-solution`

*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

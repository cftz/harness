# mktemp Skill

## Intent

Provide a consistent, project-local temporary file creation mechanism for skills that need to exchange data or store intermediate work products.

This skill exists to:
1. Ensure all temporary files are created in `.agent/tmp/` (project-local) rather than system temp directories
2. Provide sortable timestamp prefixes for easier debugging and cleanup
3. Standardize temp file creation across all skills for consistency

## Motivation

Different skills need to pass data to each other (e.g., draft files, review results). Using system `mktemp` would scatter files across `/tmp/` making them hard to find and manage. A project-local temp directory makes debugging easier and allows git to ignore these files.

## Design Decisions

- **YYYYMMDD-HHMMSS prefix**: Files sort chronologically by default, making it easy to find recent files
- **Project-local directory**: `.agent/tmp/` is gitignored but visible during development
- **Multiple suffix support**: Skills can create multiple related files in one call
- **user-invocable: false**: This is a utility skill for other skills, not for direct user invocation

## Constraints

- Should NOT create directories, only files
- Should NOT accept path arguments - always uses `.agent/tmp/`
- Should NOT be used by users directly (it's for skill-to-skill communication)

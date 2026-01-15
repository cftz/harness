# Artifact Skill

## Intent

Provide a standardized way to create and manage artifact directories and sequential artifact files. This skill ensures consistent directory structure and file naming conventions across all artifact-related operations.

## Motivation

Manual creation of artifact directories leads to inconsistent naming patterns and timestamp formats. This skill centralizes artifact management to ensure:
- Consistent timestamp-based directory names (YYYYMMDD-HHMMSS)
- Sequential file numbering within directories
- Predictable output paths for dependent skills

## Design Decisions

1. **Timestamp-based directory names**: Ensures chronological sorting and uniqueness
2. **Two-digit zero-padded file numbers**: Supports up to 99 files per directory while maintaining sort order
3. **Files in same call share number**: Multiple files created together get the same sequence number for grouping
4. **Default prefix `.agent/artifacts`**: Centralizes artifacts in a standard location

## Constraints

- This skill should NOT read or modify file contents - only create empty files
- This skill should NOT delete or rename existing artifacts
- This skill should NOT create nested directory structures beyond `{PREFIX}/{ARTIFACT_ID}/`

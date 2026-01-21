---
name: finalize-skill
description: |
  Use this skill to finalize skill drafts by writing them to their final location.

  Converts approved draft files from temporary location to final skill directory structure.

  Args:
    DRAFT_PATH=<path> (Required) - Path to temp draft file containing SKILL.md content
    NAME=<name> (Required) - Skill name
    SCOPE=user|project (Optional) - Target scope (default: user)

  Examples:
    /finalize-skill DRAFT_PATH=.agent/tmp/20260120-skill-draft NAME=my-skill
    /finalize-skill DRAFT_PATH=.agent/tmp/20260120-skill-draft NAME=my-skill SCOPE=project
---

# Description

Finalizes skill drafts by writing approved content from temporary files to the final skill directory structure. This is the "Phase 3" skill in the edit-skill-workflow pattern (draft-* → *-review → finalize-*).

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `DRAFT_PATH` | Yes | - | Path to temp draft file containing SKILL.md content |
| `NAME` | Yes | - | Skill name (kebab-case) |
| `SCOPE` | No | `user` | Target scope: `user` or `project` |

### Scope Options

| Scope | Target Directory | Description |
|-------|-----------------|-------------|
| `user` | `~/.claude/skills/{NAME}/` | User-scope skill, available across all projects |
| `project` | `.agent/skills/{NAME}/` | Project-scope skill, available only in current project |

## Process

### 1. Validate Parameters

1. Check `DRAFT_PATH` exists and is readable
2. Check `NAME` follows kebab-case convention
3. Check `SCOPE` is either `user` or `project`

If any validation fails, report error and exit.

### 2. Determine Target Directory

Based on `SCOPE`:

```bash
if [ "$SCOPE" = "user" ]; then
  TARGET_DIR="${HOME}/.claude/skills/${NAME}"
else
  TARGET_DIR=".agent/skills/${NAME}"
fi
```

### 3. Check for Existing Skill

If target directory already exists:
1. Use `AskUserQuestion` to confirm overwrite
2. Options: "Overwrite existing skill", "Cancel"
3. If cancel, exit without changes

### 4. Read Draft Content

Read the draft file at `DRAFT_PATH`:
1. Parse SKILL.md content
2. Look for additional draft files in same directory:
   - `*-readme-draft` → README.md
   - `*-ref-*` → references/*.md
   - `*-script-*` → scripts/*.sh

### 5. Create Skill Directory Structure

Create the skill directory and required files:

```bash
# Create main directory
mkdir -p "${TARGET_DIR}"

# Create subdirectories if needed
mkdir -p "${TARGET_DIR}/references"  # if reference files exist
mkdir -p "${TARGET_DIR}/scripts"     # if script files exist
```

### 6. Write Files

Write all skill files to the target directory:

1. **SKILL.md**: Write the main skill definition
2. **README.md**: Write the intent documentation
3. **references/*.md**: Write any reference documents
4. **scripts/*.sh**: Write any scripts with executable permission

### 7. Clean Up Temp Files

After successful write, remove the temp draft files:

```bash
rm -f "${DRAFT_PATH}"
rm -f "${DRAFT_PATH}-readme"
rm -f "${DRAFT_PATH}-ref-"*
rm -f "${DRAFT_PATH}-script-"*
```

## Output

SUCCESS:
- SKILL_NAME: Name of the finalized skill
- SKILL_DIR: Final skill location path
- FILES_CREATED: List of files written

ERROR: Error message string

## Error Handling

| Error | Action |
|-------|--------|
| Draft file not found | Report error, suggest running draft-skill first |
| Invalid skill name | Report error, show valid name format |
| Target exists (no overwrite) | Exit cleanly with message |
| Write permission denied | Report error, suggest checking permissions |

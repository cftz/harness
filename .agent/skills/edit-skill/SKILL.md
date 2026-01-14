---
name: edit-skill
description: |
  Use this skill to create new skills or modify existing ones.

  IMPORTANT: ALWAYS use this skill instead of manually creating skill files - it ensures proper structure and validation.

  Creates or modifies skills by guiding through type selection, parameter design, and structure generation.

  Args:
    NAME=<name> - Skill name (required)
    MODE=create|modify - Operation mode (required)
    PROMPT="<text>" - Request description (required)

  Examples:
    /edit-skill NAME=gofmt-runner MODE=create PROMPT="Format Go code using gofmt"
    /edit-skill NAME=plan MODE=modify PROMPT="Add batch processing support"
model: claude-opus-4-5
---

# Edit Skill

Creates new skills or modifies existing ones based on established patterns and rules.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `NAME` | Yes | Skill name (kebab-case). For create: new name. For modify: existing name. |
| `MODE` | Yes | `create` - create new skill, `modify` - edit existing skill |
| `PROMPT` | Yes | Description of what to create or modify |

## Rules

All skill operations must follow these rules. These apply to both create and modify modes.

### Skill Types

| Type            | Description                                        | Structure                          |
| --------------- | -------------------------------------------------- | ---------------------------------- |
| **workflow**    | Complex multi-step processes with user interaction | SKILL.md, references/              |
| **orchestrator**| Coordinates SubAgents/Skills in parallel           | SKILL.md only                      |
| **utility**     | Simple focused operations with shell scripts       | SKILL.md, scripts/                 |
| **integration** | API wrappers with multiple sub-commands            | SKILL.md, references/, scripts/    |
| **validation**  | Analysis and reporting tools                       | SKILL.md only                      |

### Directory Structure Standards

1. **Location**: All skills must be in `.agent/skills/{skill-name}/`
2. **Required Files**: Every skill must have `SKILL.md`
3. **Allowed Directories**: Only `scripts/`, `references/`, `assets/` are permitted
4. **Flat Structure**: No subdirectories within standard directories

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Skill name | kebab-case | `format-code`, `check-types` |
| Parameter name | UPPERCASE_WITH_UNDERSCORES | `OUTPUT_PATH`, `AUTO_ACCEPT` |
| Reference files | kebab-case.md | `workflow-template.md` |
| Script files | kebab-case.sh | `run-formatter.sh` |

### Path Reference Standards

Use the `{baseDir}` variable for portable path references within SKILL.md:

```markdown
Read `{baseDir}/references/documentation.md`
Run `{baseDir}/scripts/setup.sh`
```

This ensures skills work correctly regardless of installation location.

### Frontmatter Requirements

| Field            | Status       | Description                                                |
| ---------------- | ------------ | ---------------------------------------------------------- |
| `name`           | **Required** | Skill name (must match directory name)                     |
| `description`    | **Required** | YAML multiline (`\|`) recommended (max 1024 chars)         |
| `model`          | Optional     | Model to use (e.g., `claude-opus-4-5`)                     |
| `allowed-tools`  | Optional     | Tools allowed without asking permission                    |
| `context`        | Optional     | Set to `fork` for sub-agent context                        |
| `agent`          | Optional     | Agent type to use (e.g., `step-by-step-agent`)             |
| `hooks`          | Optional     | Lifecycle hooks configuration                              |
| `user-invocable` | Optional     | Set to `false` to hide from user invocation (default: true)|

**Description Format**: Use YAML multiline syntax (`|`) for readability. Include Args and Examples sections.

### Example Placement

Invocation examples must be placed **only in the frontmatter description**, not in the SKILL.md body.

| Location | Allowed | Reason |
|----------|---------|--------|
| Frontmatter `description` | Yes | Agent sees this before invoking the skill |
| SKILL.md body | No | Agent reads this after invocation - too late for invocation guidance |

**What belongs where:**
- **Frontmatter description**: How to invoke the skill (`/skill-name ARG=value`)
- **SKILL.md body**: Process steps, output formats, internal logic examples

### Quality Checklist

Before completing any skill operation, verify:

- [ ] **Name is valid**: Kebab-case, descriptive, unique in `.agent/skills/`
- [ ] **Type matches purpose**: Selected type is appropriate for the skill's function
- [ ] **Parameters are complete**: All parameters documented with format and description
- [ ] **Process is actionable**: Each step is clear and executable
- [ ] **Examples are valid**: Usage examples use correct parameter syntax
- [ ] **Template followed**: Structure matches the skill type template
- [ ] **Dependent skills exist**: Any referenced skills (e.g., `mktemp`, `linear`) exist
- [ ] **Validation passed**: verify-skill reports no Critical or High issues

## Process

Execute the appropriate process based on `MODE`:

### Mode: create

Follow the process in `{baseDir}/references/create-process.md`

### Mode: modify

Follow the process in `{baseDir}/references/modify-process.md`

## Templates

Templates for creating new skills are located in `{baseDir}/references/`:

- `{baseDir}/references/workflow-template.md` - For complex multi-step processes
- `{baseDir}/references/orchestrator-template.md` - For SubAgent/Skill coordination
- `{baseDir}/references/utility-template.md` - For simple focused operations
- `{baseDir}/references/integration-template.md` - For API wrappers
- `{baseDir}/references/validation-template.md` - For analysis tools

## Output

### Create Mode Output

```
Created skill: {NAME}
Location: .agent/skills/{NAME}/

Files created:
- SKILL.md
- [additional files based on type]

Validation: [PASSED | ISSUES FOUND]
```

### Modify Mode Output

```
Modified skill: {NAME}
Location: .agent/skills/{NAME}/

Files changed:
- [list of modified files]

Files created:
- [list of new files, if any]

Validation: [PASSED | ISSUES FOUND]
```

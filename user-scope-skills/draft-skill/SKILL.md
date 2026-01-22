---
name: draft-skill
description: |
  Use this skill to create or modify draft execution plans for skills in temporary files.

  Creates or modifies skill drafts by guiding through type selection, parameter design, and structure generation. Outputs to temporary files for review.

  Commands:
    create - Create new skill draft in temp
      NAME=<name> - Skill name (required)
      PROMPT="<text>" - Request description (required)
    modify - Modify existing skill, save changes to temp
      NAME=<name> - Existing skill name (required)
      PROMPT="<text>" - Modification description (required)

  Examples:
    /draft-skill create NAME=gofmt-runner PROMPT="Format Go code using gofmt"
    /draft-skill modify NAME=plan PROMPT="Add batch processing support"
model: claude-opus-4-5
---

# Description

Creates new skill drafts or modifies existing ones, outputting to temporary files for review before finalization.

## Parameters

### Command: create

| Parameter | Required | Description |
|-----------|----------|-------------|
| `NAME` | Yes | Skill name (kebab-case) for the new skill |
| `PROMPT` | Yes | Description of what to create |

### Command: modify

| Parameter | Required | Description |
|-----------|----------|-------------|
| `NAME` | Yes | Existing skill name (kebab-case) to modify |
| `PROMPT` | Yes | Description of what to modify |

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

1. **Location**: All skills must be in `.agent/skills/{skill-name}/` or `~/.claude/skills/{skill-name}/`
2. **Required Files**: Every skill must have `SKILL.md` and `README.md`
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

### Reference Document Independence

Reference documents (`references/*.md`) must be self-contained and **must not reference other reference documents**.

| Pattern | Issue |
|---------|-------|
| ✅ SKILL.md → references/jira-init.md | Correct: SKILL.md routes to reference |
| ❌ references/init.md → references/jira-provider.md | Wrong: Reference pointing to reference |

**Why This Matters:**
- Reference chains are hard to trace and debug
- Each reference should contain all information needed for its purpose
- Routing logic belongs in SKILL.md, not in reference documents

**Correct Approach:**
- SKILL.md handles routing: "If Jira, read `{baseDir}/references/jira-init.md`"
- Each reference document is self-contained with all necessary details

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

### AWAIT/Resume Documentation

AWAIT and resume patterns are handled by global rules. When creating skills that return AWAIT:

- **Do NOT** document resume command in SKILL.md
- **Do NOT** create references/*.md for resume handling
- **Do** document only SUCCESS and ERROR in the Output section
- The resume command is automatically available for all skills that return AWAIT

### Quality Checklist

Before completing any skill operation, verify:

- [ ] **Name is valid**: Kebab-case, descriptive, unique
- [ ] **Type matches purpose**: Selected type is appropriate for the skill's function
- [ ] **Parameters are complete**: All parameters documented with format and description
- [ ] **Process is actionable**: Each step is clear and executable
- [ ] **Examples are valid**: Usage examples use correct parameter syntax
- [ ] **Template followed**: Structure matches the skill type template
- [ ] **Dependent skills exist**: Any referenced skills (e.g., `mktemp`, `linear`) exist
- [ ] **References are self-contained**: No reference document points to another reference

## Process

Execute the appropriate process based on command:

### Command: create

1. Follow the process in `{baseDir}/references/create-process.md`
2. When loading template (Step 3), read the appropriate template based on skill type:

| Type | Template |
|------|----------|
| workflow | `{baseDir}/references/workflow-template.md` |
| orchestrator | `{baseDir}/references/orchestrator-template.md` |
| utility | `{baseDir}/references/utility-template.md` |
| integration | `{baseDir}/references/integration-template.md` |
| validation | `{baseDir}/references/validation-template.md` |

### Command: modify

Follow the process in `{baseDir}/references/modify-process.md`

## Output

SUCCESS:
- DRAFT_PATH: Path to the created/modified draft file

ERROR: Error message string (e.g., "Skill '{NAME}' not found for modify command")


<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>

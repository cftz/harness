# Create Process

Execute this process when `MODE=create`.

## 1. Parse Input

Analyze `PROMPT` to understand the skill requirement:
- Identify the core functionality
- Determine potential skill type
- Extract key features and constraints

## 2. Select Skill Type

Present the five skill types with their characteristics:

| Type            | When to Use                                                           |
| --------------- | --------------------------------------------------------------------- |
| **workflow**    | Complex processes requiring user confirmation, multiple I/O sources   |
| **orchestrator**| Coordinating multiple SubAgents/Skills in parallel, dynamic outputs   |
| **utility**     | Simple file operations, transformations, or single-purpose tools      |
| **integration** | External API integrations, multi-command interfaces                   |
| **validation**  | Code analysis, linting, verification tasks                            |

Use `AskUserQuestion` to confirm the skill type selection.

## 3. Define Skill Intent

Capture the skill's core purpose and design rationale for README.md:

1. **Intent**: What problem does this skill solve? (Required)
2. **Motivation**: Why was this skill created? What need drove its creation?
3. **Design Decisions**: What important architectural choices were made?
4. **Constraints**: What should this skill NOT do? What are its boundaries?

Use `AskUserQuestion` to gather this information from the user.

This information will be documented in README.md to preserve the skill's original intent across future modifications.

## 4. Validate Skill Name

1. Verify `NAME` follows kebab-case convention
2. Check that `.agent/skills/{NAME}/` does not exist
3. If name is invalid or exists, report error and ask for new name

## 5. Define Parameters

Based on the selected skill type, guide through parameter definition:

**For Workflow Skills:**
- Task Source parameters (input sources)
- Output Destination parameters
- Optional control parameters (e.g., `AUTO_ACCEPT`)

**For Orchestrator Skills:**
- Input collection parameters (what to orchestrate)
- Execution control parameters (e.g., `LIMIT`, `PARALLEL`)
- No fixed output destination (output is dynamic)

**For Utility Skills:**
- Required arguments
- Optional arguments with defaults

**For Integration Skills:**
- Commands and their parameters
- Environment variables required

**For Validation Skills:**
- Target to validate
- Report options (e.g., `FIX=true`)

Document each parameter with:
- Name (UPPERCASE_WITH_UNDERSCORES)
- Type/Format
- Description
- Whether required or optional

## 6. Define Process Steps

Guide the user through defining the execution process:

1. Ask: "What are the main steps this skill should perform?"
2. For each step, clarify:
   - What action is performed
   - What input is needed
   - What output is produced
   - Any decision points or user interactions

**For Workflow Skills:** Include numbered steps with detailed guidance, user confirmation points.

**For Orchestrator Skills:** Define:
- Subagent selection criteria (when to use step-by-step vs general-purpose)
- Behavior rules (parallel vs sequential, interaction handling)
- Result aggregation logic
- Error handling per-task vs all-tasks

**For Utility Skills:** Define script inputs, outputs, and error handling.

**For Integration Skills:** Define each command's process separately.

**For Validation Skills:** Define checks to perform and severity levels.

## 7. Create Temporary Draft

Use `mktemp` skill to create temporary files for drafting:

```
skill: mktemp
args: skill-draft
```

Write the generated SKILL.md content to the temp file for user review.

## 8. User Review

Present the draft to the user:
1. Show the SKILL.md content
2. List all files that will be created
3. Ask for approval or modifications
4. Iterate until approved

## 9. Generate Final Structure

Once approved, create the skill directory and files:

**Directory:** `.agent/skills/{NAME}/`

**Files by Type:**

| Type        | Files Created                                                        |
| ----------- | -------------------------------------------------------------------- |
| workflow    | `SKILL.md`, `README.md`, `references/*.md`                           |
| orchestrator| `SKILL.md`, `README.md`                                              |
| utility     | `SKILL.md`, `README.md`, `scripts/*.sh`                              |
| integration | `SKILL.md`, `README.md`, `references/*.md`, `scripts/*.sh` (optional)|
| validation  | `SKILL.md`, `README.md`                                              |

**README.md Template:**

```markdown
# {SKILL_NAME}

## Intent

{Purpose statement - what problem this skill solves}

## Motivation

{Why this skill was created - the driving need}

## Design Decisions

{Key architectural and design choices made}

## Constraints

{What this skill should NOT do - boundaries and limitations}

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*
```

**Note:** Use `{baseDir}` variable in SKILL.md to reference files: `{baseDir}/references/guide.md`

## 10. Validate Generated Skill

Run validation:

```
skill: verify-skill
args: {NAME}
```

Report any issues found and offer to fix them.

# Create Process

Execute this process when `MODE=create`.

## 1. Parse Input

Analyze `PROMPT` to understand the skill requirement:
- Identify the core functionality
- Determine potential skill type
- Extract key features and constraints

## 2. Select Skill Type

Present the four skill types with their characteristics:

| Type            | When to Use                                                         |
| --------------- | ------------------------------------------------------------------- |
| **workflow**    | Complex processes requiring user confirmation, multiple I/O sources |
| **utility**     | Simple file operations, transformations, or single-purpose tools    |
| **integration** | External API integrations, multi-command interfaces                 |
| **validation**  | Code analysis, linting, verification tasks                          |

Use `AskUserQuestion` to confirm the skill type selection.

## 3. Validate Skill Name

1. Verify `NAME` follows kebab-case convention
2. Check that `.agent/skills/{NAME}/` does not exist
3. If name is invalid or exists, report error and ask for new name

## 4. Define Parameters

Based on the selected skill type, guide through parameter definition:

**For Workflow Skills:**
- Task Source parameters (input sources)
- Output Destination parameters
- Optional control parameters (e.g., `AUTO_ACCEPT`)

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

## 5. Define Process Steps

Guide the user through defining the execution process:

1. Ask: "What are the main steps this skill should perform?"
2. For each step, clarify:
   - What action is performed
   - What input is needed
   - What output is produced
   - Any decision points or user interactions

**For Workflow Skills:** Include numbered steps with detailed guidance, user confirmation points.

**For Utility Skills:** Define script inputs, outputs, and error handling.

**For Integration Skills:** Define each command's process separately.

**For Validation Skills:** Define checks to perform and severity levels.

## 6. Create Temporary Draft

Use `mktemp` skill to create temporary files for drafting:

```
skill: mktemp
args: skill-draft
```

Write the generated SKILL.md content to the temp file for user review.

## 7. User Review

Present the draft to the user:
1. Show the SKILL.md content
2. List all files that will be created
3. Ask for approval or modifications
4. Iterate until approved

## 8. Generate Final Structure

Once approved, create the skill directory and files:

**Directory:** `.agent/skills/{NAME}/`

**Files by Type:**

| Type        | Files Created                                            |
| ----------- | -------------------------------------------------------- |
| workflow    | `SKILL.md`, `references/*.md`                            |
| utility     | `SKILL.md`, `scripts/*.sh`                               |
| integration | `SKILL.md`, `references/*.md`, `scripts/*.sh` (optional) |
| validation  | `SKILL.md`                                               |

**Note:** Use `{baseDir}` variable in SKILL.md to reference files: `{baseDir}/references/guide.md`

## 9. Validate Generated Skill

Run validation:

```
skill: verify-skill
args: {NAME}
```

Report any issues found and offer to fix them.

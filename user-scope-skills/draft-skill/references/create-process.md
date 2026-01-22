# `create` Command

Creates a new skill draft from a description.

## Parameters

### Required

- `NAME` - Skill name in kebab-case (e.g., `format-code`, `check-types`)
- `PROMPT` - Description of what the skill should do

## Process

### 1. Validate Skill Name

Verify the skill name:
- Is in kebab-case format
- Is descriptive and unique
- Does not conflict with existing skills

Check existing skills in:
- `~/.claude/skills/`
- `.claude/skills/`
- `.agent/skills/`

### 2. Determine Skill Type

Based on the `PROMPT`, determine the appropriate skill type:

| Type            | Indicators                                                  |
| --------------- | ----------------------------------------------------------- |
| **workflow**    | Multi-step process, user interactions, approval loops       |
| **orchestrator**| Parallel execution, SubAgent coordination, task delegation  |
| **utility**     | Simple operation, shell script wrapper, single command      |
| **integration** | API wrapper, multiple sub-commands, external service        |
| **validation**  | Analysis, reporting, read-only inspection, linting          |

If unclear, **save context and return** for user selection:

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

### 3. Load Template

Load the appropriate template based on skill type. See the template mapping in SKILL.md Process section.

### 4. Design Skill Structure

Based on the template and `PROMPT`:

1. **Define Parameters**
   - Identify required vs optional parameters
   - Use UPPERCASE_WITH_UNDERSCORES for names
   - Document format and examples for each

2. **Design Process Steps**
   - Break down the skill's function into clear steps
   - Identify any dependent skills (e.g., `mktemp`, `linear-issue`)
   - Determine output destinations if applicable

3. **Create Output Format**
   - Define SUCCESS output fields
   - Define ERROR message format
   - Do NOT document AWAIT (handled by global rules)

### 5. Create Output File

Use the `mktemp` skill to create a temporary file:

```
skill: mktemp
args: {NAME}-draft
```

### 6. Write Draft Content

Write the skill draft to the output file, including:

1. **SKILL.md** - Main skill definition following the template
2. **README.md** - Intent documentation with:
   - `## Intent` - What problem this skill solves
   - `## Motivation` - Why this skill was created
   - `## Design Decisions` - Key architectural choices

### 7. Verify Quality

Check the draft against the Quality Checklist in `{baseDir}/SKILL.md`:

- [ ] Name is valid kebab-case
- [ ] Type matches purpose
- [ ] Parameters are complete with format and description
- [ ] Process is actionable
- [ ] Examples are valid
- [ ] Template structure followed
- [ ] Dependent skills exist

## Output

**On Success:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: {temp_file_path}
```

**On User Input Needed:**
```
STATUS: AWAIT
CONTEXT_PATH: {context_file_path}
```

**On Error:**
```
STATUS: ERROR
OUTPUT: {error message}
```

# `modify` Command

Modifies an existing skill, saving changes to a temporary file.

## Parameters

### Required

- `NAME` - Existing skill name in kebab-case (e.g., `plan`, `clarify-workflow`)
- `PROMPT` - Description of what to modify

## Process

### 1. Locate Existing Skill

Search for the skill in this order:

1. `~/.claude/skills/{NAME}/SKILL.md` (user scope)
2. `.claude/skills/{NAME}/SKILL.md` (project scope)
3. `.agent/skills/{NAME}/SKILL.md` (project scope, legacy)

If not found, return error:
```
STATUS: ERROR
OUTPUT: Skill not found: {NAME}
```

### 2. Read Current Skill

Read all files in the skill directory:
- `SKILL.md` - Main skill definition
- `README.md` - Intent documentation
- `references/*.md` - Supporting documents
- `scripts/*.sh` - Shell scripts (if any)

Understand:
- Current skill type
- Existing parameters
- Current process flow
- Output format

### 3. Analyze Modification Request

Based on the `PROMPT`, determine what changes are needed:

| Change Type | Example |
|-------------|---------|
| Add parameter | "Add AUTO_ACCEPT option" |
| Modify process | "Add validation step before output" |
| Change output | "Include cycle count in output" |
| Add functionality | "Support batch processing" |
| Fix issue | "Fix parameter name mismatch" |

If the request is unclear or requires user decision, **save context and return**:

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

### 4. Create Output File

Use the `mktemp` skill to create a temporary file:

```
skill: mktemp
args: {NAME}-modified
```

### 5. Apply Modifications

Apply the requested changes to the skill files:

1. **Update Parameters** (if needed)
   - Add new parameters to frontmatter description
   - Add to Parameters section in body
   - Update examples

2. **Update Process** (if needed)
   - Add, modify, or remove process steps
   - Maintain logical flow
   - Update references to dependent skills

3. **Update Output** (if needed)
   - Add new output fields
   - Update format examples

4. **Update README** (if needed)
   - Update Intent if scope changes
   - Document Design Decisions for significant changes

### 6. Write Modified Draft

Write the complete modified skill to the output file:
- Include all files (SKILL.md, README.md, references/*, scripts/*)
- Clearly indicate which files were changed

### 7. Verify Quality

Check the modified draft against the Quality Checklist:

- [ ] Changes align with the modification request
- [ ] Parameter names are consistent across all sections
- [ ] Process flow is still logical
- [ ] Examples are updated to reflect changes
- [ ] README reflects any scope changes
- [ ] Dependent skills are still valid

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

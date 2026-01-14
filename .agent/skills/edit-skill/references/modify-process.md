# Modify Process

Execute this process when `MODE=modify`.

## 1. Load Existing Skill

1. Locate skill directory: `.agent/skills/{NAME}/`
2. Read and parse `SKILL.md` completely
3. Identify skill type from current structure
4. Load all supporting files (`references/*.md`, `scripts/*.sh`)

If skill does not exist, report error and exit.

## 2. Understand Modification Request

Parse `PROMPT` to understand what changes are needed:

| Modification Type    | Examples                                           |
| -------------------- | -------------------------------------------------- |
| Add parameter        | "Add support for OUTPUT_PATH parameter"            |
| Modify process       | "Add validation step before output"                |
| Fix issue            | "Fix the parameter name inconsistency"             |
| Add feature          | "Support Linear as additional output destination"  |
| Restructure          | "Split the process into phases"                    |
| Update documentation | "Improve examples section"                         |

If request is unclear, use `AskUserQuestion` to clarify.

## 3. Analyze Impact

Determine what files need to be changed:

1. **SKILL.md changes**: Frontmatter, sections, examples
2. **Reference file changes**: Add/modify/remove reference docs
3. **Script changes**: Add/modify/remove scripts
4. **Cross-reference updates**: Update any skills that depend on this one

Create a list of all files that will be affected.

## 4. Apply Rules Validation

Before making changes, verify they comply with Rules (from main SKILL.md):

- [ ] Parameter naming follows UPPERCASE_WITH_UNDERSCORES
- [ ] Path references use `{baseDir}` variable
- [ ] Frontmatter description uses YAML multiline syntax (`|`)
- [ ] Directory structure remains flat
- [ ] Skill name remains kebab-case

If proposed changes violate rules, inform user and suggest compliant alternatives.

## 5. Create Modification Draft

Use `mktemp` skill to create temporary files:

```
skill: mktemp
args: skill-edit
```

Write the modified content showing:
- Original content (for reference)
- Proposed changes with clear markers
- Summary of what changed

## 6. Present Changes for Review

Show the user:
1. Summary of changes
2. Files that will be modified
3. Files that will be created/deleted (if any)
4. Any dependent skills that may need updates

Use `AskUserQuestion` to get approval:
- "Approve changes"
- "Request modifications"
- "Cancel"

## 7. Apply Changes

Once approved:
1. Update `SKILL.md` with modifications
2. Create/update/delete reference files as needed
3. Create/update/delete scripts as needed

Use the Edit tool for modifications, Write tool for new files.

## 8. Validate Modified Skill

Run validation:

```
skill: verify-skill
args: {NAME} FIX=true
```

If issues found:
1. Report the issues
2. Offer to fix them automatically
3. Re-validate after fixes

## 9. Check Dependent Skills

Search for skills that reference this one:

```bash
grep -r "skill:\s*{NAME}" .agent/skills/ --include="*.md"
```

If found:
1. List the dependent skills
2. Notify user about potential impact
3. Suggest reviewing dependent skills if changes affect the interface (parameters, behavior)

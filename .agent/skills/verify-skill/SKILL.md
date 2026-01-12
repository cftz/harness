---
name: verify-skill
description: |
  Verifies skill documentation for standards compliance, consistency, accuracy, and completeness. Checks directory structure, frontmatter fields, path references, parameter names, and dependent skill interfaces.

  Args:
    SKILL_NAME (Required) - Name of the skill to verify (e.g., plan, linear)
    FIX=true (Optional) - Include specific fix suggestions in the report

  Examples:
    /verify-skill plan
    /verify-skill clarify-workflow FIX=true
context: fork
agent: step-by-step-agent
---

# Verify-Skill

Verifies skill documentation for standards compliance, consistency, and accuracy. This skill analyzes SKILL.md files and their supporting documents to find standards violations, contradictions, interface mismatches, and missing references.

## Parameters

### Required

- `SKILL_NAME` - Name of the skill to verify (e.g., `plan`, `linear`, `clarify`)

### Optional

- `FIX=true` - Include specific fix suggestions in the report. Omit for report only.

## Usage Examples

```bash
# Verify a single skill
skill: verify-skill
args: plan

# Verify with fix suggestions
skill: verify-skill
args: plan FIX=true
```

## Process

### 1. Locate Skill Files

```
SKILL_DIR=.agent/skills/$SKILL_NAME
```

Verify the skill directory exists. If not, report error and exit.

---

## Standards Compliance Checks

### 2. Standard Directory Structure Check

Verify the skill follows the standard directory structure.

**Allowed Directories:**

| Directory     | Purpose                                        |
| ------------- | ---------------------------------------------- |
| `scripts/`    | Executable script files                        |
| `references/` | Documentation loaded into context              |
| `assets/`     | Files used in output (not loaded into context) |

**Checks:**

| Check                         | Severity     | Description                                       |
| ----------------------------- | ------------ | ------------------------------------------------- |
| Standard directory names only | **High**     | Only `scripts/`, `references/`, `assets/` allowed |
| Flat structure                | **High**     | No subdirectories within standard directories     |
| Referenced files exist        | **Critical** | All referenced files must actually exist          |
| `SKILL.md` exists             | **Critical** | Main skill definition file must exist             |

**How to Verify:**

```bash
# Detect non-standard directories
find .agent/skills/$SKILL_NAME -mindepth 1 -maxdepth 1 -type d \
  ! -name scripts ! -name references ! -name assets

# Detect subdirectories (should be empty)
find .agent/skills/$SKILL_NAME/scripts -mindepth 1 -type d 2>/dev/null
find .agent/skills/$SKILL_NAME/references -mindepth 1 -type d 2>/dev/null
find .agent/skills/$SKILL_NAME/assets -mindepth 1 -type d 2>/dev/null
```

### 3. Standard Frontmatter Field Check

Verify only standard frontmatter fields are used.

**Standard Fields:**

| Field            | Status       | Description                                                                                                                                                   |
| ---------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`           | **Required** | Skill name. Lowercase letters, numbers, hyphens only (max 64 chars). Should match directory name.                                                             |
| `description`    | **Required** | What the Skill does and when to use it (max 1024 chars). Claude uses this to decide when to apply.                                                            |
| `allowed-tools`  | Optional     | Tools Claude can use without asking permission. If omitted, all tools are allowed. If specified, only listed tools are allowed. Comma-separated or YAML list. |
| `model`          | Optional     | Model to use when this Skill is active. Both short form (`claude-opus-4-5`) and full ID (`claude-opus-4-5-20251101`) are valid.                               |
| `context`        | Optional     | Set to `fork` to run the Skill in a forked sub-agent context with its own conversation history.                                                               |
| `agent`          | Optional     | Agent type to use when `context: fork` is set. Only applicable with `context: fork`.                                                                          |
| `hooks`          | Optional     | Define hooks scoped to this Skill's lifecycle. Supports `PreToolUse`, `PostToolUse`, `Stop`.                                                                  |
| `user-invocable` | Optional     | Controls whether the Skill appears in the slash command menu. Defaults to `true`.                                                                             |

**Checks:**

| Check                       | Severity     | Description            |
| --------------------------- | ------------ | ---------------------- |
| `name` field exists         | **Critical** | Required field missing |
| `description` field exists  | **Critical** | Required field missing |
| Non-standard field detected | **High**     | Remove unknown fields  |

**How to Verify:**
1. Parse YAML frontmatter
2. Check for required fields (`name`, `description`)
3. Flag any fields not in the standard list

### 4. Path Reference Check

Verify path references use `{baseDir}` variable for portability.

**Why This Matters:**
Skills may be installed in different locations. Using `{baseDir}` ensures paths resolve correctly regardless of installation location.

**Checks:**

| Pattern                  | Severity     | Issue                                             |
| ------------------------ | ------------ | ------------------------------------------------- |
| `./references/`          | **High**     | Should use `{baseDir}/references/`                |
| `./scripts/`             | **High**     | Should use `{baseDir}/scripts/`                   |
| `./assets/`              | **High**     | Should use `{baseDir}/assets/`                    |
| `../other-skill/`        | **Critical** | Cross-skill references should use skill interface |
| Hardcoded absolute paths | **Critical** | Portability issue                                 |

**How to Verify:**
1. Search SKILL.md for path patterns: `./`, `../`, `/Users/`, `/home/`
2. Check if references to internal files use `{baseDir}`
3. Flag any relative or absolute paths as issues

---

## Documentation Quality Checks

### 5. Description Quality Check

Verify the frontmatter description accurately represents the skill's behavior:

| Check                      | Description                                                                     |
| :------------------------- | :------------------------------------------------------------------------------ |
| Accurate behavior coverage | Description should accurately represent what the skill does                     |
| Invocation clarity         | Description should be detailed enough for LLM to know when to invoke this skill |
| Argument documentation     | If skill has Parameters, description MUST include invocation format             |

**Description Format:**

YAML multiline syntax (`|`) is supported and recommended for readability.

| Format                  | Status          | Example                                            |
| :---------------------- | :-------------- | :------------------------------------------------- |
| YAML literal block `\|` | **Recommended** | `description: \|`<br>`  First line.`               |
| Single-line with `\n`   | Supported       | `description: "First line.\n\nArgs:\n  ARG=value"` |
| YAML folded block `>`   | Not recommended | May cause unexpected whitespace handling           |

**Argument Documentation Check:**

If the skill has a "Parameters" section with defined arguments:

1. **Required Args in Description**: All required arguments must be listed in the description
2. **Format Specification**: Description must show the `key=value` format
3. **Example Invocation**: At least one usage example must be in the description

**Severity:**
- Missing required args in description → **High** (agent will invoke incorrectly)
- Missing format specification → **High** (agent won't know how to pass args)
- Missing example → **Medium** (less clarity but may still work)

### 6. Internal Consistency Check

Verify parameter names are consistent across all sections:

| Location           | Should Match        |
| :----------------- | :------------------ |
| Parameters section | Source of truth     |
| Process section    | Must use same names |
| Usage Examples     | Must use same names |
| Output Format      | Must use same names |

**Common Issues:**

| Issue         | Example                                                   |
| :------------ | :-------------------------------------------------------- |
| Name mismatch | Parameters: `TASK_PATH`, Process: `REQUIREMENTS_PATH`     |
| Typo          | Parameters: `ARTIFACT_DIR_PATH`, Example: `ARTIFACT_PATH` |
| Case mismatch | Parameters: `issueId`, Process: `issue_id`                |

**How to Verify:**
1. Extract all parameter names from "Parameters" section
2. Search entire document for each parameter
3. Flag any variations or mismatches

---

## Interface Checks

### 7. Dependent Skill Interface Check

Verify all skill references are valid:

**Valid Syntax:**
```
skill: {skill_name}
args: {command} {parameters}
```

**Invalid Patterns to Flag:**

| Pattern                     | Issue                                  |
| :-------------------------- | :------------------------------------- |
| `skill: linear-issue`       | Non-existent skill name                |
| `$(Skill tool: X, args: Y)` | Non-standard syntax                    |
| `skill: artifact args: ...` | Missing newline between skill and args |

**How to Verify:**
1. Find all `skill: {name}` patterns
2. Check `.agent/skills/{name}/SKILL.md` exists
3. Verify command names and parameters match the skill's interface

### 7.1. Direct Script Call Detection

Verify references/*.md files do not contain direct script calls to other skills.

**Why This Matters:**
Skills should be invoked using `skill:` + `args:` format, not by directly calling scripts. Direct script calls bypass the skill interface and create tight coupling.

**What to Flag:**

| Pattern                                  | Issue                                |
| ---------------------------------------- | ------------------------------------ |
| `.agent/skills/other-skill/scripts/*.sh` | Direct script call to external skill |

**Exceptions:**
- Internal implementation docs within the same skill
- Examples showing bash execution inside the current skill

**Severity:**
- Direct script call to external skill in references/*.md → **High**

**How to Verify:**
1. Find all `.agent/skills/.../scripts/*.sh` patterns in references/*.md
2. Check if the script path belongs to a different skill
3. Flag as High severity and suggest replacing with `skill:` + `args:` format

---

## Accuracy & Maintenance Checks

### 8. Example Accuracy Check

Verify examples match actual behavior:

**Script Output Format:**
1. Run the script (if safe)
2. Compare output with documented format
3. Flag discrepancies

**Invocation Syntax:**
```
# Correct
skill: mktemp
args: plan

# Incorrect (missing args line)
skill: mktemp plan
```

### 9. Documentation Duplication Check

Check for content overlap between SKILL.md and reference documents (references/*.md).

**Why This Matters:**
Duplicated content creates maintenance burden - when one copy is updated, the other becomes stale.

**What to Check:**

| Pattern                   | Issue                                               |
| :------------------------ | :-------------------------------------------------- |
| Same tables in both files | Content should live in one place only               |
| Same code examples        | Consolidate or reference, don't duplicate           |
| Same process descriptions | SKILL.md should be self-contained or reference docs |

**How to Verify:**
1. List all `references/*.md` files in the skill directory
2. For each doc, compare section headings and content with SKILL.md
3. Flag significant overlap (>50% similar content) as Medium severity

**Resolution Options:**

| Option                          | When to Use                                                          |
| :------------------------------ | :------------------------------------------------------------------- |
| Merge into SKILL.md             | When docs add little beyond SKILL.md                                 |
| Keep docs, remove from SKILL.md | When docs have rich detail, SKILL.md should just reference           |
| Keep both with clear separation | When docs serve different audience (e.g., API reference vs tutorial) |

### 10. Reverse Dependency Check

Find and verify skills that depend on the target skill.

**Why This Matters:**
When a skill changes (e.g., output path changes from `/tmp/` to `.agent/tmp/`), dependent skills may have hardcoded references that become outdated.

**How to Find Dependent Skills:**

```bash
grep -r "skill:\s*$SKILL_NAME" .agent/skills/ --include="*.md"
```

**What to Check:**

| Check                  | Description                                          |
| :--------------------- | :--------------------------------------------------- |
| Output path references | Hardcoded paths that match the skill's output format |
| Interface usage        | Commands and parameters still valid                  |
| Example accuracy       | Examples use current output format                   |

**Common Issues:**

| Issue              | Example                                                    |
| :----------------- | :--------------------------------------------------------- |
| Outdated path      | Dependent uses `/tmp/` but skill now outputs `.agent/tmp/` |
| Deprecated command | Dependent uses old command name                            |
| Changed parameter  | Dependent passes parameter that no longer exists           |

**How to Verify:**
1. Search for `skill: {SKILL_NAME}` in all skill directories
2. For each dependent skill, extract hardcoded paths from examples
3. Compare with target skill's documented output format
4. Flag mismatches as High severity

---

### 11. Generate Report

Output a verification report:

```markdown
# Skill Verification Report: {SKILL_NAME}

## Summary
- Total Issues: N
- Critical: X
- High: Y
- Medium: Z

## Issues

### Critical
{Issues that will cause failures}

### High
{Issues that cause confusion or maintenance problems}

### Medium
{Documentation quality issues}

## Suggested Fixes (if FIX=true)
{Specific edit suggestions with file:line references}
```

## Severity Definitions

| Severity | Criteria                        | Examples                                                                                                  |
| :------- | :------------------------------ | :-------------------------------------------------------------------------------------------------------- |
| Critical | Skill will fail to execute      | Non-existent skill reference, wrong command name, missing required field, portability issue               |
| High     | Confusion or incorrect behavior | Parameter name mismatch, outdated path references, non-standard directory, non-standard frontmatter field |
| Medium   | Documentation quality issue     | Missing error handling docs, incomplete descriptions, missing examples, content duplication               |

## Output

Verification report as markdown, listing all found issues by severity.

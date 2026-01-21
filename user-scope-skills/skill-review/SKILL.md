---
name: skill-review
description: |
  Use this skill to verify skill documentation for standards compliance.

  Verifies skill documentation for standards compliance, consistency, accuracy, and completeness. Checks directory structure, frontmatter fields, path references, parameter names, and dependent skill interfaces.

  Args:
    SKILL_NAME (Required) - Name of the skill to verify (e.g., plan, linear)

  Examples:
    /skill-review plan
    /skill-review clarify-workflow
---

# Description

Verifies skill documentation for standards compliance, consistency, and accuracy. This skill analyzes SKILL.md files and their supporting documents to find standards violations, contradictions, interface mismatches, and missing references.

# Parameters

## Required

- `SKILL_NAME` - Name of the skill to verify (e.g., `plan`, `linear`, `clarify`)

# Process

## Phase 1: Locate Skill Files

**Search Order:**

```bash
# Search in order: User Scope → Project Scope (.claude) → Project Scope (.agent)
SEARCH_PATHS=(
  "${HOME}/.claude/skills/${SKILL_NAME}"
  ".claude/skills/${SKILL_NAME}"
  ".agent/skills/${SKILL_NAME}"
)

# Use first found location
SKILL_DIR=""
for path in "${SEARCH_PATHS[@]}"; do
  if [ -d "$path" ]; then
    SKILL_DIR="$path"
    break
  fi
done
```

**If not found:**

Use AskUserQuestion to ask the user for the skill location:
- Question: "Cannot find skill '{SKILL_NAME}'. Where is it located?"
- Options:
  1. "Enter path manually"
  2. "Skip this skill"

**Variables Set:**
- `SKILL_DIR` - Full path to skill directory
- `SKILL_SCOPE` - Detected scope (user|project)

## Phase 2: Standards Compliance

### 2.1 Directory Structure Check

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
| `README.md` exists            | **High**     | Intent documentation file must exist              |

**How to Verify:**

```bash
# Detect non-standard directories
find $SKILL_DIR -mindepth 1 -maxdepth 1 -type d \
  ! -name scripts ! -name references ! -name assets

# Detect subdirectories (should be empty)
find $SKILL_DIR/scripts -mindepth 1 -type d 2>/dev/null
find $SKILL_DIR/references -mindepth 1 -type d 2>/dev/null
find $SKILL_DIR/assets -mindepth 1 -type d 2>/dev/null
```

### 2.2 README Content Check

Verify the skill has proper intent documentation in README.md.

**Required Sections:**

| Section               | Required | Description                    |
| --------------------- | -------- | ------------------------------ |
| `## Intent`           | **Yes**  | What problem this skill solves |
| `## Motivation`       | No       | Why this skill was created     |
| `## Design Decisions` | No       | Key architectural choices      |
| `## Constraints`      | No       | What this skill should NOT do  |

**Checks:**

| Check                 | Severity   | Description                                                   |
| --------------------- | ---------- | ------------------------------------------------------------- |
| README.md exists      | **High**   | Every skill must have intent documentation                    |
| Intent section exists | **High**   | README.md must have "## Intent" section                       |
| Intent is non-empty   | **Medium** | Intent section must have meaningful content (not placeholder) |

**Why This Matters:**

README.md preserves the skill's original purpose. Without it, future modifications may drift from the intended design. The Intent section is critical for understanding what the skill should and should not do.

**How to Verify:**

1. Check `$SKILL_DIR/README.md` exists
2. Parse for `## Intent` heading
3. Verify Intent section has content (not just placeholder text like `{Purpose statement...}`)

### 2.3 Frontmatter Field Check

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

### 2.4 Path Reference Check

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

## Phase 3: Documentation Quality

### 3.1 Description Quality Check

Verify the frontmatter description accurately represents the skill's behavior:

| Check                      | Description                                                                                              |
| :------------------------- | :------------------------------------------------------------------------------------------------------- |
| Accurate behavior coverage | Description should accurately represent what the skill does                                              |
| Invocation clarity         | Description should be detailed enough for LLM to know when to invoke this skill                          |
| Usage context              | Description should specify when/why to use this skill (e.g., "Use this when...", "Use this skill to...") |
| Directive phrasing         | Description should include directive phrases ("ALWAYS", "Use this", "IMPORTANT") to guide LLM behavior   |
| Argument documentation     | If skill has Parameters, description MUST include invocation format                                      |

**Severity:**
- Missing usage context → **High** (LLM may not recognize when to use the skill)
- Missing directive phrasing → **High** (LLM may choose alternatives instead of this skill)

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

### 3.2 Internal Consistency Check

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

### 3.3 Header Hierarchy Check

Verify the document has a clear, consistent header hierarchy.

**Checks:**

| Check | Severity | Description |
| :---- | :------- | :---------- |
| Redundant top-level heading | **High** | `# Skill Name` that duplicates frontmatter `name` field |
| Inconsistent hierarchy | **High** | Sibling sections that should be nested (e.g., steps scattered across same-level headers) |
| Non-sequential numbering | **Medium** | Decimal numbers like `2.5`, `7.1` instead of proper sequential numbering |
| Unnecessary dividers | **Medium** | `---` horizontal rules between sections (headers provide sufficient structure) |
| Inappropriate heading depth | **Medium** | Starting with `#` when `# Description` pattern is recommended |

**Valid Structure Pattern:**

```
# Description
# Parameters
## Required
## Optional
# Process
## Phase 1: ...
### 1.1 ...
### 1.2 ...
## Phase 2: ...
# Output
```

**Invalid Patterns:**

| Pattern | Issue |
| :------ | :---- |
| `# Skill Name` matching frontmatter name | Redundant - use `# Description` instead |
| `## Process` → `### Step 1` → `## Category A` → `### Step 2` | Steps 2+ should be under Process, not separate `##` |
| `### 2.5 New Check` | Should renumber to `### 3` or use proper sub-numbering |
| `---` between `## Phase 1` and `## Phase 2` | Headers already provide visual separation |

**How to Verify:**

1. Check if first `#` heading matches frontmatter `name` (flag if so)
2. Parse all headings and verify logical nesting:
   - All steps/phases under `# Process` should use `##`
   - Sub-items should use `###`
3. Check for decimal numbering patterns (e.g., `/\d+\.\d+/` in headings)
4. Search for `^---$` lines outside of code blocks and frontmatter

### 3.4 Language Requirement Check

Verify all agent-referenced documentation files are written in English.

**Scope:**

| File Type | Check Required | Reason |
| :-------- | :------------- | :----- |
| `SKILL.md` | **Yes** | Core skill definition loaded into agent context |
| `README.md` | **Yes** | Intent documentation referenced by agent |
| `references/*.md` | **Yes** | Supporting docs loaded into agent context |
| `scripts/*` | No | Execution artifacts, not agent context |
| `assets/*` | No | Output artifacts, not agent context |

**Why English:**

- Agent context is processed in English for consistency
- Enables broader collaboration and reusability
- Aligns with `.agent/rules/common.md` code comment standard

**Checks:**

| Check | Severity | Description |
| :---- | :------- | :---------- |
| Non-English SKILL.md | **High** | Core skill definition must be in English |
| Non-English README.md | **High** | Intent documentation must be in English |
| Non-English references/*.md | **High** | Reference docs must be in English |
| Mixed language content | **Medium** | Inconsistent language within a single file |

**Detection Patterns:**

Look for non-ASCII character blocks that indicate non-English text:
- Korean: `[\uAC00-\uD7AF]` (Hangul syllables)
- Chinese: `[\u4E00-\u9FFF]` (CJK unified ideographs)
- Japanese: `[\u3040-\u309F\u30A0-\u30FF]` (Hiragana, Katakana)

**Exceptions:**

| Pattern | Acceptable |
| :------ | :--------- |
| Code examples with i18n strings | Yes - code may contain localized strings |
| File paths or identifiers | Yes - may include non-ASCII characters |
| Quoted user input examples | Yes - demonstrating input handling |

**How to Verify:**

1. Read `SKILL.md`, `README.md`, and all `references/*.md` files
2. For each file, detect significant non-English text blocks (>10 consecutive non-ASCII chars outside code blocks)
3. Flag files with non-English prose as High severity
4. Exclude content within code fences (``` blocks) from language check

## Phase 4: Interface Validation

### 4.1 Dependent Skill Interface Check

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
2. Check skill exists in any scope (search order: user → project):
   - `~/.claude/skills/{name}/SKILL.md`
   - `.claude/skills/{name}/SKILL.md`
   - `.agent/skills/{name}/SKILL.md`
3. Verify command names and parameters match the skill's interface

### 4.2 Direct Script Call Detection

Verify references/*.md files do not contain direct script calls to other skills.

**Why This Matters:**
Skills should be invoked using `skill:` + `args:` format, not by directly calling scripts. Direct script calls bypass the skill interface and create tight coupling.

**What to Flag:**

| Pattern                                     | Issue                                     |
| ------------------------------------------- | ----------------------------------------- |
| `~/.claude/skills/other-skill/scripts/*.sh` | Direct script call to user-scope skill    |
| `.claude/skills/other-skill/scripts/*.sh`   | Direct script call to project-scope skill |
| `.agent/skills/other-skill/scripts/*.sh`    | Direct script call to project-scope skill |

**Exceptions:**
- Internal implementation docs within the same skill
- Examples showing bash execution inside the current skill

**Severity:**
- Direct script call to external skill in references/*.md → **High**

**How to Verify:**
1. Find all skill script path patterns in references/*.md:
   - `~/.claude/skills/.../scripts/*.sh`
   - `.claude/skills/.../scripts/*.sh`
   - `.agent/skills/.../scripts/*.sh`
2. Check if the script path belongs to a different skill
3. Flag as High severity and suggest replacing with `skill:` + `args:` format

## Phase 5: Accuracy & Maintenance

### 5.1 Example Accuracy Check

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

**Example Placement Check:**

Invocation examples must be in the frontmatter description only, not in the SKILL.md body.

| Pattern to Flag                                              | Severity | Issue                                     |
| ------------------------------------------------------------ | -------- | ----------------------------------------- |
| `## Usage Examples` section in body                          | **High** | Invocation examples belong in frontmatter |
| `## Examples` section with `/skill-name` patterns            | **High** | Move to frontmatter description           |
| `skill:` + `args:` examples showing how to call *this* skill | **High** | Redundant - already in frontmatter        |

**Why This Matters:**
- Agent reads frontmatter description **before** invoking the skill
- Agent reads SKILL.md body **after** invoking - too late for invocation guidance
- Duplicating examples creates maintenance burden

**How to Verify:**
1. Search SKILL.md body for sections like "Usage Examples", "Examples", "How to Use"
2. Check if they contain invocation patterns (`/skill-name`, `skill:` + `args:`)
3. Flag as High severity - suggest moving to frontmatter description

### 5.2 Documentation Duplication Check

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

### 5.3 Reverse Dependency Check

Find and verify skills that depend on the target skill.

**Why This Matters:**
When a skill changes (e.g., output path changes from `/tmp/` to `.agent/tmp/`), dependent skills may have hardcoded references that become outdated.

**How to Find Dependent Skills:**

```bash
# Search all skill locations
SEARCH_DIRS=(
  "${HOME}/.claude/skills"
  ".claude/skills"
  ".agent/skills"
)

for dir in "${SEARCH_DIRS[@]}"; do
  grep -r "skill:\s*${SKILL_NAME}" $dir --include="*.md" 2>/dev/null
done
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

## Phase 6: Skill Type-Specific

### 6.1 Orchestrator Pattern Check

If skill contains "CRITICAL ROLE CONSTRAINT" block, verify orchestrator-specific requirements.

**Detection:**

Search for `> **CRITICAL ROLE CONSTRAINT**` or `CRITICAL ROLE CONSTRAINT` pattern in SKILL.md.

**Required Sections for Orchestrator Skills:**

| Section            | Severity | Description                           |
| ------------------ | -------- | ------------------------------------- |
| Subagent Selection | **High** | Must document how to choose subagents |
| Behavior Rules     | **High** | Must define behavior rules            |

**How to Verify:**
1. Search for "CRITICAL ROLE CONSTRAINT" in SKILL.md
2. If found, check for "## Subagent Selection" or "Subagent Selection" heading
3. If found, check for "## Behavior Rules" or "Behavior Rules" heading
4. Flag missing sections as High severity

**Note:** This check only applies when the CRITICAL ROLE CONSTRAINT pattern is detected. Skills without this pattern are not validated as orchestrators.

### 6.2 Task Invocation Pattern Check

Verify Task tool invocations follow best practices for reliability and performance.

**Detection:**

Search for `Task(` or `Task tool` patterns in SKILL.md, particularly in orchestrator skills.

**Checks:**

| Check                         | Severity     | Description                                                                        |
| ----------------------------- | ------------ | ---------------------------------------------------------------------------------- |
| Missing subagent_type         | **Critical** | Task invocation without `subagent_type` parameter                                  |
| Direct Task in recursive call | **Critical** | Using Task tool in subagent to call another skill (subagents don't have Task tool) |
| Wrong subagent for skill      | **High**     | Not using `step-by-step-agent` when invoking a skill via Task                      |
| Sequential parallel tasks     | **High**     | Independent Task calls made sequentially instead of in one message                 |
| Missing description           | **Medium**   | Task invocation without `description` parameter                                    |

**Required Task Parameters:**

| Parameter       | Status          | Description                                                             |
| --------------- | --------------- | ----------------------------------------------------------------------- |
| `subagent_type` | **Required**    | Must specify agent type (e.g., `step-by-step-agent`, `general-purpose`) |
| `prompt`        | **Required**    | Task instructions                                                       |
| `description`   | **Recommended** | 3-5 word summary for progress tracking                                  |

**Recursive Call Pattern:**

Subagents do NOT have access to the Task tool. If a skill needs to invoke another skill from within a subagent:

✅ **Correct:** Use `Skill` tool
```markdown
Use the Skill tool to invoke the dependent skill:
skill: dependent-skill
args: {parameters}
```

❌ **Wrong:** Use Task tool in subagent
```markdown
Use Task tool with subagent_type="step-by-step-agent" to run dependent-skill
(This will fail - subagents don't have Task tool)
```

**Parallel Invocation Pattern:**

✅ **Correct:** All independent Tasks in ONE message
```markdown
Launch all tasks in parallel with a single message containing multiple Task calls
```

❌ **Wrong:** Sequential Task calls for independent work
```markdown
First, launch Task for item 1...
Then, launch Task for item 2...
```

**How to Verify:**

1. Search SKILL.md for `Task(`, `Task tool`, `subagent_type`
2. For each Task invocation:
   - Check `subagent_type` is specified
   - Check `description` is provided
   - If invoking a skill, verify `step-by-step-agent` is used
3. For orchestrator skills, verify parallel Task pattern is documented
4. Check for anti-patterns suggesting Task use in subagent context

### 6.3 Standard Output Format Check

Verify skill output follows the standard resumable format defined in `.agent/rules/skill/output-format.md`.

**Output Format Checklist:**

- [ ] Does `## Output` section exist in SKILL.md?
- [ ] Does it document the standard format (SUCCESS/AWAIT/ERROR)?
- [ ] Does SUCCESS include OUTPUT field definitions, or explicitly state none?
- [ ] If skill supports AWAIT, does it reference context skill usage?
- [ ] Does ERROR format specify error message string?

**Valid Output Section Examples:**

```markdown
# OUTPUT 필드가 있는 경우
## Output

SUCCESS:
- DRAFT_PATH: 생성된 드래프트 경로

ERROR: 에러 메시지 문자열

# OUTPUT 필드가 없는 경우
## Output

SUCCESS: (no output fields)

ERROR: 에러 메시지 문자열
```

**Severity:**

| Check                              | Severity   | Description                                   |
| ---------------------------------- | ---------- | --------------------------------------------- |
| No `## Output` section in SKILL.md | **High**   | Output section missing from document          |
| AWAIT with custom OUTPUT           | **High**   | Using custom OUTPUT instead of context skill  |
| Missing ERROR format               | **Medium** | ERROR format description missing              |

**How to Verify:**

1. Check for `## Output` section in SKILL.md
2. Verify SUCCESS format includes OUTPUT field definitions (if applicable)
3. Verify AWAIT format references context skill usage
4. Verify ERROR format specifies error message string

# Severity Definitions

| Severity | Criteria                        | Examples                                                                                                  |
| :------- | :------------------------------ | :-------------------------------------------------------------------------------------------------------- |
| Critical | Skill will fail to execute      | Non-existent skill reference, wrong command name, missing required field, portability issue               |
| High     | Confusion or incorrect behavior | Parameter name mismatch, outdated path references, non-standard directory, non-standard frontmatter field |
| Medium   | Documentation quality issue     | Missing error handling docs, incomplete descriptions, missing examples, content duplication               |

# Output

SUCCESS:
- RESULT: PASS or ISSUES_FOUND
- ISSUES_COUNT: Number of issues found (by Critical/High/Medium)
- REPORT: Verification report in markdown format

ERROR: Error message string (e.g., "Skill not found: {SKILL_NAME}")

## Report Format

```markdown
# Skill Verification Report: {SKILL_NAME}

**Scope:** {SKILL_SCOPE}
**Path:** {SKILL_DIR}

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
```

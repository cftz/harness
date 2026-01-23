---
name: agent-review
description: |
  Use this skill to verify agent files for standards compliance.

  Verifies agent documentation for standards compliance, persona definition, process clarity, and decision criteria. Checks frontmatter fields, body structure, and quality checklist items.

  Args:
    AGENT_NAME (Required) - Name of the agent to verify (e.g., step-by-step-agent, code-reviewer)

  Examples:
    /agent-review step-by-step-agent
    /agent-review code-reviewer
---

# Description

Verifies agent files for standards compliance, persona definition, and process clarity. This skill analyzes agent markdown files to find standards violations, missing sections, and quality issues.

# Parameters

## Required

- `AGENT_NAME` - Name of the agent to verify (e.g., `step-by-step-agent`, `code-reviewer`)

# Process

## Phase 1: Locate Agent File

**Search Order:**

```bash
# Search in order: User Scope → Project Scope
SEARCH_PATHS=(
  "${HOME}/.claude/agents/${AGENT_NAME}.md"
  ".claude/agents/${AGENT_NAME}.md"
)

# Use first found location
AGENT_FILE=""
for path in "${SEARCH_PATHS[@]}"; do
  if [ -f "$path" ]; then
    AGENT_FILE="$path"
    break
  fi
done
```

**If not found:**

Return ERROR: "Agent not found: {AGENT_NAME}"

**Variables Set:**
- `AGENT_FILE` - Full path to agent file
- `AGENT_SCOPE` - Detected scope (user|project)

## Phase 2: Frontmatter Compliance

### 2.1 Required Fields Check

Verify required frontmatter fields exist.

**Required Fields:**

| Field | Description |
|-------|-------------|
| `name` | kebab-case, must match filename |
| `description` | Multi-line YAML (`\|`) recommended |

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| `name` field exists | **Critical** | Required field missing |
| `description` field exists | **Critical** | Required field missing |
| `name` matches filename | **High** | name field should match `{AGENT_NAME}` |

### 2.2 Optional Fields Validation

Verify optional fields have valid values.

**Optional Fields:**

| Field | Valid Values | Default |
|-------|--------------|---------|
| `tools` | Tool names (e.g., Read, Grep, Glob, Bash) | Inherit all |
| `disallowedTools` | Tool names | None |
| `model` | `inherit`, `sonnet`, `opus`, `haiku` | `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | `default` |
| `skills` | Skill names array | None |
| `hooks` | PreToolUse, PostToolUse, Stop | None |

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| Unknown field detected | **Medium** | Non-standard frontmatter field |
| Invalid `model` value | **High** | Model must be valid alias |
| Invalid `permissionMode` value | **High** | Must be valid mode |

## Phase 3: Body Structure

### 3.1 Persona Definition Check

Verify the agent has a clear persona/role definition.

**What to Look For:**
- Opening statement defining role (e.g., "You are a...", "You execute...", "Your role is...")
- Clear expertise or specialization mentioned

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| No persona statement | **High** | Agent lacks role definition |
| Vague persona | **Medium** | Role not specific enough |

**How to Verify:**
1. Check first paragraph after frontmatter
2. Look for phrases: "You are", "You execute", "Your role", "You specialize"
3. Flag if no clear role statement found

### 3.2 Process Section Check

Verify the agent has a defined process.

**Required:**
- `## Process` section exists
- Contains numbered steps or clear workflow

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| No `## Process` section | **High** | Agent lacks defined workflow |
| Process has no steps | **High** | Empty or unclear process |
| Steps not numbered | **Medium** | Steps should be clearly numbered |

### 3.3 Error Handling Check

Verify error handling is defined.

**What to Look For:**
- `## Error Handling` section
- Mentions of `AskUserQuestion` for user decisions
- Fallback strategies

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| No `## Error Handling` section | **Medium** | Error handling not documented |
| No AskUserQuestion usage | **Medium** | May cause silent failures |

### 3.4 Constraints Check

Verify constraints/rules are defined.

**What to Look For:**
- `## Constraints` section
- Clear rules the agent must follow

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| No `## Constraints` section | **Medium** | Agent lacks explicit rules |

## Phase 4: Quality Assessment

### 4.1 Description Quality

Verify description is clear for delegation decisions.

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| Description too short (<50 chars) | **High** | Claude can't decide when to delegate |
| No usage context | **High** | Missing "Use when...", "Use for..." |
| Missing "proactively" for auto-use | **Medium** | If agent should be auto-invoked |

### 4.2 Tools Minimality

Verify only necessary tools are allowed.

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| All tools allowed (default) | **Medium** | Consider restricting tools |
| Write/Edit for read-only agent | **High** | Reviewer agents shouldn't write |

### 4.3 Decision Criteria

Verify decision-making criteria are clear.

**What to Look For:**
- Clear criteria for choices agent makes
- Prioritization rules
- Trade-off guidelines

**Checks:**

| Check | Severity | Description |
|-------|----------|-------------|
| No decision criteria | **Medium** | Agent may make inconsistent choices |

# Severity Definitions

| Severity | Criteria | Examples |
|----------|----------|----------|
| Critical | Agent will fail to load | Missing required field, invalid YAML |
| High | Confusion or incorrect behavior | No persona, no process, bad description |
| Medium | Quality issue | Missing error handling, no constraints |

# Output

SUCCESS:
- RESULT: PASS or ISSUES_FOUND
- ISSUES_COUNT: Number of issues found (by Critical/High/Medium)
- REPORT: Verification report in markdown format

ERROR: Error message string (e.g., "Agent not found: {AGENT_NAME}")

## Report Format

```markdown
# Agent Verification Report: {AGENT_NAME}

**Scope:** {AGENT_SCOPE}
**Path:** {AGENT_FILE}

## Summary
- Total Issues: N
- Critical: X
- High: Y
- Medium: Z

## Frontmatter
{Frontmatter field checks}

## Body Structure
{Section existence and quality checks}

## Quality Assessment
{Description, tools, decision criteria checks}

## Recommendations
{Suggestions for improvement}
```

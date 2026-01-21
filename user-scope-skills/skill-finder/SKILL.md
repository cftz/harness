---
name: skill-finder
description: |
  Analyzes user prompts and recommends relevant Skills, Tools, and Agents.

  IMPORTANT: System prompt may truncate skill list due to token limits. This skill scans
  all skill directories to find the complete list.

  Args:
    PROMPT="..." (Required) - User's request text to analyze

  Examples:
    /skill-finder PROMPT="Linear 이슈를 생성하고 싶어"
    /skill-finder PROMPT="코드 리뷰를 받고 싶어"
    /skill-finder PROMPT="플랜을 작성해야 해"
model: claude-sonnet-4-20250514
context: fork
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
  - MCPSearch
---

# Description

Analyzes user prompts and recommends the most relevant Skills, Tools, and Agents. This skill solves the problem of truncated skill lists in the system prompt by scanning all skill directories to find the complete list.

# Parameters

## Required

- `PROMPT` - User's request text to analyze

# Process

## 1. Collect All Available Skills

The system prompt may show truncated skill list (e.g., "Showing 2 of 48 skills due to token limits").
You MUST scan the file system to find ALL available skills.

### 1.1 Local Skills Directories

Scan these directories for `*/SKILL.md` files:

```bash
# Current directory and parent directories up to root
find . -name ".claude" -type d 2>/dev/null | while read d; do echo "$d/skills"; done
# Also check .agent/skills for legacy structure
ls -d .agent/skills 2>/dev/null

# Home directory
ls -d ~/.claude/skills 2>/dev/null
```

### 1.2 Plugin Skills

**Step 1: Find enabled plugins from settings files**

Check these files for `enabledPlugins` array:
- `./settings.json`, `./settings.local.json`
- Parent directories' settings files (up to root)
- `~/.claude/settings.json`

**Step 2: Find installed plugins**

Read `~/.claude/plugins/installed_plugins.json` to get plugin directories.

**Step 3: Scan plugin skill directories**

For each enabled/installed plugin directory:
```bash
ls {plugin_dir}/skills/*/SKILL.md 2>/dev/null
```

### 1.3 Read Skill Definitions

For each found `SKILL.md`:
- Read the frontmatter to extract `name` and `description`
- Note the skill's location (local vs plugin, namespace if any)

## 2. Collect Tools and Agents from System Context

**Tools (from your `<functions>` block):**

Read the available functions from your system context. Common tools include:
- Bash, Glob, Grep, Read, Edit, Write
- WebFetch, WebSearch, NotebookEdit
- TodoWrite, Skill, MCPSearch

**Agents (from Task tool's "Available agent types"):**

If the Task tool is available, check its documentation for available agent types.

### 2.1 Search MCP Tools

Use MCPSearch to find available MCP tools. Extract keywords from the user's `PROMPT` and search:

```
MCPSearch with query: "{extracted keywords}"
```

MCP tools follow the naming pattern `mcp__{server}__{tool}` (e.g., `mcp__slack__read_channel`, `mcp__filesystem__list_directory`).

Search with multiple relevant keywords to discover all potentially useful MCP tools.

## 3. Analyze User Prompt

Parse the `PROMPT` to identify:
- Intent (what the user wants to accomplish)
- Domain (Linear, git, code, planning, documentation, etc.)
- Action type (create, read, update, delete, analyze, review, etc.)

## 4. Match and Rank Tools

For each collected tool, evaluate relevance based on:
- Keyword matching with user prompt
- Domain alignment (e.g., "Linear" -> linear:* skills)
- Action type compatibility (e.g., "create" -> creation-focused tools)
- Workflow stage (e.g., planning vs implementation vs review)

## 5. Generate Recommendations

Output a ranked list of recommended tools following the Output format below.

# Output

SUCCESS:
- SKILLS_SCANNED: Number of skills scanned
- MCP_TOOLS_FOUND: Number of MCP tools found
- RECOMMENDATIONS: Number of recommendations made
- REPORT: Markdown formatted recommendation report

ERROR: Error message string (e.g., "No skills found in any location")

## Report Format

```markdown
## Recommended Tools for: "{PROMPT}"

### Skills
1. **{skill-name}** - {reason why this is relevant}
   - Usage: `/{skill-name} ARG=value`
   - Location: {local | plugin-name}

### Tools
1. **{tool-name}** - {reason why this is relevant}
   - Usage: {brief usage description}

### MCP Tools
1. **{mcp__server__tool}** - {reason why this is relevant}
   - Usage: `MCPSearch "select:{tool-name}"` then call the tool

### Agents
1. **{agent-type}** - {reason why this is relevant}
   - Usage: `Task tool with subagent_type={agent-type}`

---
Total: {N} skills scanned, {M} MCP tools found, {O} recommendations
```

# Constraints

- **DO NOT execute any tools** - Only recommend, let user decide what to use
- **DO NOT modify any files** - This is purely analysis
- **Be comprehensive** - Better to over-recommend than miss relevant tools
- **Always scan file system** - Never rely solely on system prompt's truncated skill list

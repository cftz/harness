---
name: verify-rule
description: "Analyzes rule files for conflicts, duplications, and ambiguities, then fixes them.\n\nArgs:\n  RULES_DIR=<path> (Required) - Directory containing rule files\n  AUTO_FIX=true (Optional) - Apply recommended fixes without confirmation\n\nExamples:\n  /verify-rule RULES_DIR=.agent/rules/python\n  /verify-rule RULES_DIR=.agent/rules/go AUTO_FIX=true"
model: claude-opus-4-5
---

# Verify Rule Skill

Analyzes rule files in a directory for conflicts, duplications, and ambiguities. After analysis, presents findings to the user and applies approved fixes.

## Parameters

### Required

- `RULES_DIR` - Directory path containing rule files to analyze (e.g., `.agent/rules/python`)

### Optional

- `AUTO_FIX` - If `true`, apply recommended fixes without user confirmation. Defaults to `false`.

## Usage Examples

```bash
# Analyze Python rules and fix interactively
/verify-rule RULES_DIR=.agent/rules/python

# Analyze Go rules with auto-fix
/verify-rule RULES_DIR=.agent/rules/go AUTO_FIX=true
```

## Process

### 1. Collect and Parse Rule Files

Read all `.md` files in `RULES_DIR`:

- Extract YAML frontmatter (`trigger`, `globs`, `paths`)
- Parse markdown content for rules and examples

Output: List of rule files with their glob patterns and content.

### 2. Analyze Glob Pattern Hierarchy

Build a hierarchy tree based on glob patterns:

- `**/*.py` is parent of `**/src/**/*.py`
- `**/src/**/*.py` is parent of `**/src/platform/**/*`

This determines which file's rules should take precedence (more specific overrides more general).

Example hierarchy:
```
**/*.py (backend.md)
└── **/src/**/*.py (hexagonal-layout.md, logging-conventions.md)
    ├── **/src/platform/**/* (platform.md)
    │   └── **/src/platform/domain/*.py (platform-domain.md)
    └── **/src/service/**/*.py (service.md)
        └── **/src/service/*/inbound/**/* (inbound.md)
```

### 3. Detect Conflicts

Find rules that contradict each other:

- Same topic with opposite instructions
- Different default values for same setting
- Conflicting code examples

For each conflict, record:
- File A: path, line number, content
- File B: path, line number, content
- Conflict description

See [Analysis Criteria]({baseDir}/references/analysis-criteria.md) for detailed conflict detection rules.

### 4. Detect Duplications

Find duplicate content across files:

**Type A - Hierarchical Duplicates:**
- Same content in parent and child files (by glob pattern)
- Recommendation: Keep in parent file, remove from child

**Type B - Unrelated Path Duplicates:**
- Same content in files with non-overlapping glob patterns
- Recommendation: Extract to new shared file with appropriate glob pattern

For each duplication, record:
- Files involved
- Duplicated content
- Recommended action

### 5. Detect Ambiguities

Find rules that lack specificity:

- Missing concrete examples
- Vague quantifiers ("some", "few", "many", "etc.")
- Missing numeric thresholds
- Undefined terms

For each ambiguity, record:
- File and line number
- Ambiguous content
- Suggestion for clarification

### 6. Present Findings and Get User Approval

> If `AUTO_FIX=true`, skip this step and apply recommended fixes.

Present findings in organized sections:

#### Conflicts
For each conflict, use `AskUserQuestion` to ask:
- Which rule should be kept?
- Should rules be merged?
- Is this not actually a conflict?

#### Duplications
For each duplication, use `AskUserQuestion` to ask:
- Keep in parent file (for hierarchical)?
- Create new shared file (for unrelated paths)?
- Keep both (intentional duplication)?

#### Ambiguities
For each ambiguity, use `AskUserQuestion` to ask:
- Should this be clarified?
- What specific values/examples should be added?

### 7. Apply Fixes

Based on user decisions (or recommended defaults if `AUTO_FIX=true`):

**For Conflicts:**
- Remove contradicting rule from one file
- Or merge rules with clear precedence

**For Duplications:**
- Edit files to remove duplicate content
- Add references like `See [file.md](./file.md) for details`
- Create new shared files if needed (with appropriate glob pattern)

**For Ambiguities:**
- Add specific examples or thresholds
- Replace vague terms with concrete values

## Output Format

After completion, display summary:

```markdown
## Verify Rule Summary

### Conflicts Resolved: N
- [file1.md vs file2.md] - Kept rule from file1.md

### Duplications Fixed: N
- [content] - Moved to parent file (file.md)
- [content] - Extracted to new file (new-file.md)

### Ambiguities Clarified: N
- [file.md:line] - Added specific examples

### Files Modified
- file1.md
- file2.md
- new-file.md (created)
```

## Quality Checklist

Before completing, verify:

- [ ] All rule files in directory were analyzed
- [ ] Glob pattern hierarchy is correctly determined
- [ ] All conflicts are identified and resolved
- [ ] All duplications are handled appropriately
- [ ] Critical ambiguities are clarified
- [ ] Modified files maintain valid YAML frontmatter
- [ ] References between files use correct relative paths

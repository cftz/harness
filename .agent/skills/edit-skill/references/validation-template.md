# Validation Skill Template

Use this template for skills that:
- Analyze code, documentation, or configurations
- Report issues with severity levels
- Optionally suggest fixes
- Use LLM capabilities for complex analysis

## Frontmatter Structure

```yaml
---
name: {skill-name}
description: |
  {One-line summary of what is validated}.

  Args:
    {TARGET} (Required) - {What to validate}
    FIX=true (Optional) - Include fix suggestions

  Examples:
    /{skill-name} {target-value}
    /{skill-name} {target-value} FIX=true
---
```

**Note:** Use YAML multiline syntax (`|`) for better readability.

Note: Validation skills may include `model: claude-opus-4-5` if they require complex LLM analysis.

## Required Sections

### # {Skill Name}

Brief description of what is validated and why.

### ## Parameters

```markdown
## Parameters

### Required

- `{TARGET}` - {What to validate, e.g., skill name, file path, PR number}

### Optional

- `FIX=true` - Include specific fix suggestions in the report. Omit for report only.
```

### ## Usage Examples

```markdown
## Usage Examples

\`\`\`bash
# Basic validation
skill: {skill-name}
args: {target-value}

# With fix suggestions
skill: {skill-name}
args: {target-value} FIX=true
\`\`\`
```

### ## Process

Numbered steps describing validation checks:

```markdown
## Process

### 1. Locate Target

{How to find what will be validated}

Verify the target exists. If not, report error and exit.

### 2. {Check Category 1}

| Check | Description |
|-------|-------------|
| {check-name} | {What is checked} |
| {check-name} | {What is checked} |

**How to Verify:**
{Steps to perform the check}

### 3. {Check Category 2}

{Similar structure}

### N. Generate Report

Output a verification report:

\`\`\`markdown
# {Report Title}: {TARGET}

## Summary
- Total Issues: N
- Critical: X
- High: Y
- Medium: Z

## Issues

### Critical
{Issues that will cause failures}

### High
{Issues that cause confusion or incorrect behavior}

### Medium
{Documentation quality issues}

## Suggested Fixes (if FIX=true)
{Specific edit suggestions with file:line references}
\`\`\`
```

### ## Severity Definitions

```markdown
## Severity Definitions

| Severity | Criteria | Examples |
|----------|----------|----------|
| Critical | {When to use} | {Examples of critical issues} |
| High | {When to use} | {Examples of high issues} |
| Medium | {When to use} | {Examples of medium issues} |
```

### ## Output

```markdown
## Output

Verification report as markdown, listing all found issues by severity.
```

## Optional Sections

### ## Common Issues

```markdown
## Common Issues

| Issue | Example | How to Fix |
|-------|---------|------------|
| {issue-type} | {example} | {fix} |
```

## Directory Structure

Validation skills typically have the simplest structure:

```
.agent/skills/{skill-name}/
├── SKILL.md
├── references/              # Optional: if additional docs needed
└── scripts/                 # Optional: if scripts needed
```

No scripts or supporting documents are usually needed since validation logic is implemented through LLM reasoning.

**Note:** If references or scripts are needed, use `{baseDir}` variable: `{baseDir}/references/rules.md`

## Reference Examples

- `.agent/skills/verify-skill/SKILL.md` - Skill documentation validator

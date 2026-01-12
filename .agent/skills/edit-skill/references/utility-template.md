# Utility Skill Template

Use this template for skills that:
- Perform simple, focused operations
- Execute shell scripts
- Return file paths or simple outputs
- Require no user interaction during execution

## Frontmatter Structure

```yaml
---
name: {skill-name}
description: |
  {One-line summary of what the skill does}.

  Args:
    {PARAM1} (Required) - {Description}
    {PARAM2} (Optional) - {Description}. Defaults to {default}

  Examples:
    /{skill-name}
    /{skill-name} {value1} {value2}
---
```

**Note:** Use YAML multiline syntax (`|`) for better readability.

Note: Utility skills typically do NOT include `model` in frontmatter.

## Required Sections

### # {skill-name} Skill

Brief description. Mention any special capabilities or side effects.

### ## Parameters

```markdown
## Parameters

### Required

- `{PARAM1}` - Description of required parameter

### Optional

- `{PARAM2}` - Description. Defaults to `{default}` if not provided.
```

### ## Usage Examples

```markdown
## Usage Examples

\`\`\`bash
# Default usage
skill: {skill-name}
# -> {expected output}

# With parameters
skill: {skill-name}
args: {value1} {value2}
# -> {expected output}
\`\`\`
```

### ## Process

Simple numbered steps referencing scripts:

```markdown
## Process

1. Run `{baseDir}/scripts/{script}.sh [args]`
2. Return {output description}
```

### ## Output

```markdown
## Output

\`\`\`
{output-format}
{another-line}
\`\`\`
```

## Directory Structure

```
.agent/skills/{skill-name}/
├── SKILL.md
└── scripts/                     # Flat structure
    └── {operation}.sh
```

**Note:** Use `{baseDir}` variable to reference scripts: `{baseDir}/scripts/{operation}.sh`

## Script Template

```bash
#!/bin/bash
set -e

# Parse arguments
PARAM1="${1:-default}"

# Ensure directory exists
mkdir -p "{target-dir}"

# Perform operation
{operation}

# Output result
echo "{result}"
```

## Reference Examples

- `.agent/skills/mktemp/SKILL.md` - Creates temporary files
- `.agent/skills/artifact/SKILL.md` - Manages artifact directories

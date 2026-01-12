# Integration Skill Template

Use this template for skills that:
- Wrap external APIs (GitHub, Linear, Slack, etc.)
- Have multiple sub-commands
- Require authentication/environment variables
- Cache settings for repeated use

## Frontmatter Structure

```yaml
---
name: {skill-name}
description: |
  {One-line summary of the integration}.

  Commands:
    {command-1} {ARGS} - {Description}
    {command-2} {ARGS} - {Description}

  Examples:
    /{skill-name} {command-1} ARG=value
    /{skill-name} {command-2} ARG1=value ARG2=value
---
```

**Note:** Use YAML multiline syntax (`|`) for better readability.

Note: Integration skills typically do NOT include `model` unless they perform complex LLM-based operations.

## Required Sections

### # {Skill Name} Skill

Brief description of the integration and its capabilities.

### ## Commands

Table linking to individual command documentation:

```markdown
## Commands

| Command | Description | Docs |
|---------|-------------|------|
| `{command-1}` | {Description} | `{baseDir}/references/{command-1}.md` |
| `{command-2}` | {Description} | `{baseDir}/references/{command-2}.md` |
```

### ## Cache File Format

```markdown
## Cache File Format

**Location:** `.agent/memory/{skill-name}`

\`\`\`yaml
{key1}: {value1}
{key2}: {value2}
\`\`\`

- {Description of what is cached}
- {How cache is used}
```

### ## Error Handling

```markdown
## Error Handling

### {Error Category 1}

{How to detect and handle}

### {Error Category 2}

{How to detect and handle}
```

### ## Environment Variables

```markdown
## Environment Variables

- `{ENV_VAR_NAME}` - {Description and when required}
```

## Command File Template

Each command has its own documentation in `references/`:

```markdown
# {command-name}

{Description of what this command does}

## Parameters

### Required

- `{PARAM1}` - Description

### Optional

- `{PARAM2}` - Description. Defaults to {default}.

## Process

1. {Step 1}
2. {Step 2}
3. {Step 3}

## Output

{Description of output format}

## Examples

\`\`\`bash
skill: {skill-name}
args: {command-name} PARAM1=value
\`\`\`
```

## Directory Structure

```
.agent/skills/{skill-name}/
├── SKILL.md
├── references/                  # Flat structure for command docs
│   ├── {command-1}.md
│   └── {command-2}.md
└── scripts/                     # Optional: for API operations
    └── {api-operation}.sh
```

**Note:** Use `{baseDir}` variable to reference files: `{baseDir}/references/{command-1}.md`

## Script Template (for API calls)

```bash
#!/bin/bash
set -euo pipefail

# Check environment variables
if [[ -z "${API_KEY:-}" ]]; then
  echo "Error: API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# Parse arguments
PARAM1="$1"
PARAM2="${2:-}"

# Build request
ESCAPED_PARAM1=$(echo -n "$PARAM1" | escape_json)

# Execute API call
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"param\": $ESCAPED_PARAM1}" \
  "https://api.example.com/endpoint")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.error.message')" >&2
  exit 1
fi

# Output result
echo "$RESPONSE" | jq -r '.data'
```

## Reference Examples

- `.agent/skills/linear-issue/SKILL.md` - Linear Issue API integration

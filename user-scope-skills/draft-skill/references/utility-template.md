# Utility Skill Template

Use this template for simple, focused operations with shell scripts.

## Characteristics

- Single-purpose operation
- Shell script execution
- Simple input/output
- No user interaction required

## Directory Structure

```
{skill-name}/
├── SKILL.md       # Main skill definition
├── README.md      # Intent documentation
└── scripts/       # Executable scripts
    └── {operation}.sh
```

## SKILL.md Template

```markdown
---
name: {skill-name}
description: |
  {Purpose description}. Use when {usage context}.

  IMPORTANT: {Usage directive if needed}.

  Args:
    {PARAM_1} (Required) - {Description}
    {PARAM_2} (Optional) - {Description}

  Examples:
    /{skill-name} {PARAM_1}=value
    /{skill-name} {PARAM_1}=value {PARAM_2}=option
model: claude-sonnet-4-20250514
---

# Description

{Detailed description of what the skill does.}

## Parameters

### Required

- `{PARAM_1}` - {Description with format and examples}

### Optional

- `{PARAM_2}` - {Description} (default: {default_value})

## Process

### 1. Validate Input

Verify parameters:
- {PARAM_1} is provided and valid
- {PARAM_2} has valid value if provided

### 2. Execute Operation

Run the script:

```bash
{baseDir}/scripts/{operation}.sh "{PARAM_1}" "{PARAM_2}"
```

### 3. Parse Output

Parse the script output:
- Extract relevant information
- Format for return

## Scripts Reference

### {operation}.sh

**Purpose**: {What the script does}

**Input**: Arguments passed from skill invocation
**Output**: {Output format description}

**Example**:
```bash
{baseDir}/scripts/{operation}.sh "input_value" "option"
# Output: result_value
```

## Output

SUCCESS:
- {OUTPUT_FIELD}: {Description}

ERROR: Error message string (e.g., "{example error}")

## Quality Checklist

Before completing, verify:

- [ ] **Parameters validated**: Input is valid before script execution
- [ ] **Script exists**: Referenced script is present in scripts/
- [ ] **Output parsed**: Script output is properly extracted
- [ ] **Errors handled**: Script failures are reported clearly
```

## README.md Template

```markdown
# {Skill Name}

## Intent

{What simple operation this skill provides.}

## Motivation

{Why a dedicated skill is needed for this operation.}

## Design Decisions

- **Shell script execution**: Leverages existing tools
- **Simple interface**: Single purpose, clear parameters
- **No interaction**: Fully automated operation

## Constraints

- Must not modify files outside its scope
- Must validate input before execution
- Must handle script failures gracefully
```

## Script Template

### scripts/{operation}.sh

```bash
#!/bin/bash
set -euo pipefail

# {Script description}
# Usage: {operation}.sh <param1> [param2]

PARAM1="${1:?Error: PARAM1 is required}"
PARAM2="${2:-default_value}"

# Validate input
if [[ -z "$PARAM1" ]]; then
    echo "Error: PARAM1 cannot be empty" >&2
    exit 1
fi

# Execute operation
# ...

# Output result
echo "$result"
```

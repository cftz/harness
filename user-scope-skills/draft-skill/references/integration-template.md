# Integration Skill Template

<!--
PHILOSOPHY REMINDER:
- Keep process steps brief (1-3 sentences each)
- Focus on WHAT, not HOW
- Constraints section is critical for guardrails
-->

Use this template for API wrappers with multiple sub-commands.

## Characteristics

- Multiple sub-commands (get, list, create, update, delete)
- External API integration
- Consistent interface across commands
- Shell scripts for API calls

## Directory Structure

```
{skill-name}/
├── SKILL.md       # Main skill definition
├── README.md      # Intent documentation
├── references/    # Command-specific docs
│   ├── {command1}.md
│   └── {command2}.md
└── scripts/       # API call scripts
    └── api.sh
```

## SKILL.md Template

```markdown
---
name: {skill-name}
description: |
  {Service description}. Use this skill to {purpose}.

  Commands:
    get ID=<id> - Get {resource} by ID
    list [{FILTER}=...] - List {resources}
    create {PARAMS} - Create {resource}
    update ID=<id> [{PARAMS}] - Update {resource}

  Examples:
    /{skill-name} get ID=abc-123
    /{skill-name} list
    /{skill-name} create TITLE="..." CONTENT="..."
model: claude-sonnet-4-20250514
---

# Description

{Detailed description of the integration.}

## Commands

### get

Get a single {resource} by ID.

**Parameters**:
- `ID` (Required) - {Resource} ID

**Example**:
```
skill: {skill-name}
args: get ID=abc-123
```

### list

List {resources} with optional filters.

**Parameters**:
- `{FILTER}` (Optional) - Filter by {field}

**Example**:
```
skill: {skill-name}
args: list {FILTER}=value
```

### create

Create a new {resource}.

**Parameters**:
- `TITLE` (Required) - {Resource} title
- `CONTENT` (Optional) - {Resource} content

**Example**:
```
skill: {skill-name}
args: create TITLE="My Title" CONTENT="Content here"
```

### update

Update an existing {resource}.

**Parameters**:
- `ID` (Required) - {Resource} ID to update
- `TITLE` (Optional) - New title
- `CONTENT` (Optional) - New content

**Example**:
```
skill: {skill-name}
args: update ID=abc-123 TITLE="Updated Title"
```

## Process

### 1. Parse Command

Extract command and parameters from args.

### 2. Validate Parameters

Check required parameters for the command.

### 3. Execute API Call

Run the appropriate script:

```bash
{baseDir}/scripts/api.sh {command} {params}
```

### 4. Parse Response

Parse API response and format output.

## Scripts Reference

### api.sh

**Purpose**: Execute API calls to {service}

**Commands**:
- `get <id>` - Fetch single resource
- `list [filters]` - List resources
- `create <params>` - Create resource
- `update <id> <params>` - Update resource

**Authentication**: Uses `{AUTH_ENV_VAR}` environment variable

## Output

**get command**:
SUCCESS:
- ID: Resource ID
- TITLE: Resource title
- CONTENT: Resource content

**list command**:
SUCCESS:
- COUNT: Number of resources
- ITEMS: Array of resources

**create command**:
SUCCESS:
- ID: Created resource ID
- URL: Resource URL

**update command**:
SUCCESS:
- ID: Updated resource ID
- UPDATED_FIELDS: List of updated fields

ERROR: Error message string (e.g., "API error: 404 Not Found")

## Quality Checklist

Before completing, verify:

- [ ] **Command parsed correctly**: Command and parameters extracted
- [ ] **Parameters validated**: Required params present for each command
- [ ] **API call successful**: Script executed without error
- [ ] **Response parsed**: API response formatted correctly
- [ ] **Errors handled**: API errors reported clearly
```

## README.md Template

```markdown
# {Skill Name}

## Intent

{What API this skill integrates with and why.}

## Motivation

{Why a dedicated skill is needed for this integration.}

## Design Decisions

- **Sub-command pattern**: CRUD operations with consistent interface
- **Shell script backend**: Leverages existing CLI tools
- **Error handling**: API errors translated to user-friendly messages

## Constraints

- Must not expose API keys in output
- Must validate parameters before API calls
- Must handle rate limits gracefully
```

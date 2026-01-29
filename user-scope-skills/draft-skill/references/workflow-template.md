# Workflow Skill Template

<!--
PHILOSOPHY REMINDER:
- Keep process steps brief (1-3 sentences each)
- Focus on WHAT, not HOW
- Constraints section is critical for guardrails
-->

Use this template for complex multi-step processes with user interaction.

## Characteristics

- Multiple phases (draft, review, finalize)
- User approval loops
- Auto-fix cycles
- Checkpoint support for AWAIT

## Directory Structure

```
{skill-name}/
├── SKILL.md       # Main skill definition
├── README.md      # Intent documentation
└── references/    # Supporting documents
    ├── {phase}-process.md    # Phase-specific process docs
    └── {output}-output.md    # Output destination docs
```

## SKILL.md Template

```markdown
---
name: {skill-name}
description: |
  Use this skill to {purpose description}.

  Orchestrates {process description} by combining {dependent-skill-1}, {dependent-skill-2}, and {dependent-skill-3} skills with automated review loop and user approval.

  Args:
    {Category} (OneOf, Required):
      {PARAM_1}=<value> - Description
      {PARAM_2}=<id> - Description
    Output Destination (OneOf, Optional):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      ISSUE_ID=<id> - Save as Linear Document
    Options:
      AUTO_ACCEPT=true - Skip user review (default: false)
      MAX_CYCLES=<n> - Maximum auto-fix cycles (default: 10)

  Examples:
    /{skill-name} PARAM_1=value
    /{skill-name} PARAM_2=ABC-123
model: claude-opus-4-5
---

# Description

**IMPORTANT: Use this workflow when {usage context}.**

Orchestrates {process} by combining dependent skills. This skill runs automated validation, auto-fixes any issues, and then presents the approved results to the user for final confirmation.

## Parameters

### {Category} (OneOf, Required)

Provide one of the following:

- `{PARAM_1}` - Description
- `{PARAM_2}` - Description

### Output Destination (OneOf, Optional)

- `ARTIFACT_DIR_PATH` - Artifact directory path
- `ISSUE_ID` - Linear Issue ID

### Optional

- `AUTO_ACCEPT` - Skip user review (default: false)
- `MAX_CYCLES` - Maximum auto-fix cycles (default: 10)

## Workflow Overview

```
Step 1: Validate Parameters
    │
    ↓
Step 2: Call draft-{phase} (with resume loop)
    │
    ↓
Step 3: Auto-review Loop (automated)
    │
    ↓
Step 4: User Review Loop (skip if AUTO_ACCEPT=true)
    │
    ↓
Step 5: Finalize (only after approval)
```

## Process

### 1. Validate Parameters

1. Verify required parameters
2. Initialize `cycle_count = 0` and `cycle_history = []`

### 2. Call Draft Skill (with Resume Loop)

Invoke the draft skill:

```
skill: draft-{phase}
args: create {parameters}
```

Handle return status:
- SUCCESS -> Proceed to Step 3
- AWAIT -> Enter resume loop
- ERROR -> Report and exit

### 3. Auto-review Loop

1. Increment cycle count
2. Check MAX_CYCLES limit
3. Call review skill
4. If Approved -> Step 4
5. If Revision Needed -> Call draft modify -> Loop back

### 4. User Review Loop

> Skip if AUTO_ACCEPT=true

1. Display review result
2. Ask user: Approve or Request Changes
3. If Approve -> Step 5
4. If Request Changes -> Revise and return to Step 3

### 5. Finalize

Call finalize skill with appropriate destination.

## Output

SUCCESS:
- OUTPUT_LOCATION: Final output path or Linear Document ID
- CYCLE_COUNT: Number of auto-fix cycles
- CYCLE_HISTORY: Summary of each cycle result

ERROR: Error message string

## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- Execute domain logic directly (delegated to draft skill)
- Validate directly (delegated to review skill)
- Write to final destinations (delegated to finalize skill)

### Dependent Skills

This skill requires:
- `draft-{phase}` - Creates drafts in temporary files
- `{phase}-review` - Validates against rules
- `finalize-{phase}` - Saves to final destination
- `checkpoint` - Manages interruptible checkpoint files

### Three-Phase Workflow

1. **Draft Phase**: Work in temporary files only
2. **Review Phase**: Automated validation with auto-fix
3. **Finalize Phase**: Save to final destination after approval
```

## README.md Template

```markdown
# {Skill Name}

## Intent

{What problem this skill solves. What user need it addresses.}

## Motivation

{Why this workflow skill was created instead of manual steps.}

## Design Decisions

- **Three-phase pattern**: Ensures work is validated before persisting
- **Auto-fix loop**: Reduces user intervention for fixable issues
- **Checkpoint support**: Allows interruption and resume

## Constraints

- Must not write to final destinations until user approval
- Must not skip review phase
- Must track cycle history for debugging
```

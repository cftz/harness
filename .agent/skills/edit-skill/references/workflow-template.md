# Workflow Skill Template

Use this template for skills that:
- Perform complex multi-step processes
- Require user confirmation at key points
- Support multiple input/output sources (Artifact, Linear)
- Need LLM capabilities for decision-making

## Frontmatter Structure

```yaml
---
name: {skill-name}
description: |
  {One-line summary of what the skill does}.

  Args:
    Task Source (OneOf, Required):
      {INPUT_PARAM}=<format> - {Description}
      ISSUE_ID=<id> - Linear Issue ID
    Output (Optional):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      PROJECT_ID=<id> - Save as Linear issues
    Options:
      AUTO_ACCEPT=true - Skip user review (default: false)

  Examples:
    /{skill-name} {INPUT_PARAM}=value
    /{skill-name} ISSUE_ID=ABC-123 PROJECT_ID=my-project
model: claude-opus-4-5
---
```

**Note:** Use YAML multiline syntax (`|`) for better readability.

## Required Sections

### # {Skill Name} Skill

Brief description of what the skill does and when to use it.

### ## Parameters

Document all parameters with categories:

```markdown
### Task Source (OneOf, Required)

Provide one of the following:

- `{INPUT_PARAM}` - Description
- `ISSUE_ID` - Linear Issue ID (e.g., `ABC-123`)

### Output Destination (OneOf, Optional)

Provide one to specify where output is saved:

- `ARTIFACT_DIR_PATH` - Artifact directory path
- `PROJECT_ID` - Linear Project ID or name

### Optional

- `AUTO_ACCEPT` - If `true`, skip user review. Defaults to `false`.
```

### ## Usage Examples

```markdown
## Usage Examples

\`\`\`bash
# {Scenario 1 description}
skill: {skill-name}
args: {INPUT_PARAM}=value ARTIFACT_DIR_PATH=.agent/artifacts/20260105

# {Scenario 2 description}
skill: {skill-name}
args: ISSUE_ID=ABC-123 PROJECT_ID=my-project AUTO_ACCEPT=true
\`\`\`
```

### ## Process

Numbered steps with detailed guidance:

```markdown
## Process

### 1. {Step Title}

- If `{PARAM}` is provided -> {Action}
- If `{OTHER_PARAM}` is provided -> {Alternative action}

### 2. {Step Title}

{Description of what happens}

Questions to clarify:
- {Question 1}
- {Question 2}

### 3. Write to Temporary Files

Use the `mktemp` skill to create temporary files:

\`\`\`
skill: mktemp
args: {suffix}
\`\`\`

### 4. User Review

Present draft to user for confirmation.

> If `AUTO_ACCEPT` is `true`, skip this step.

### 5. Create Final Output

- If `ARTIFACT_DIR_PATH` is provided -> Read `{baseDir}/references/artifact-output.md`
- If `PROJECT_ID` is provided -> Read `{baseDir}/references/linear-output.md`
```

### ## Output Format

Document the structure of outputs:

```markdown
## Output Format

### YAML Frontmatter

\`\`\`yaml
---
name: {Name of the output}
{additional-fields}: {values}
---
\`\`\`

### Content Sections

- **Section 1**: Description
- **Section 2**: Description
```

### ## Quality Checklist

```markdown
## Quality Checklist

Before completing, verify:

- [ ] **{Check 1}**: Description
- [ ] **{Check 2}**: Description
- [ ] **User confirmation obtained**: Summary shown and approved
- [ ] **Output format followed**: All required sections present
```

## Optional Sections

### ## Notice

Important behavioral notes or caveats.

### ## Constraints

Technical or business constraints affecting implementation.

## Directory Structure

```
.agent/skills/{skill-name}/
├── SKILL.md
└── references/                  # Flat structure (no subdirectories)
    ├── artifact-task.md         # How to read from artifacts
    ├── linear-task.md           # How to read from Linear issues
    ├── artifact-output.md       # How to write to artifacts
    └── linear-output.md         # How to create Linear issues/docs
```

**Note:** Use `{baseDir}` variable to reference files: `{baseDir}/references/artifact-task.md`

## Reference Examples

- `.agent/skills/clarify-workflow/SKILL.md` - Requirements clarification workflow
- `.agent/skills/plan-workflow/SKILL.md` - Implementation planning workflow
- `.agent/skills/implement/SKILL.md` - Code implementation workflow
- `.agent/skills/code-review/SKILL.md` - Code validation workflow

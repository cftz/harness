# Orchestrator Skill Template

Use this template for skills that:
- Coordinate multiple SubAgents in parallel or sequence
- Delegate work rather than performing it directly
- Have dynamic outputs that vary based on execution results
- Focus on behavior rules rather than data transformation
- Handle user interaction delegation to SubAgents

## Frontmatter Structure

```yaml
---
name: {skill-name}
description: |
  {One-line summary of the orchestration}.

  Args:
    {PARAM1}="..." (Required) - {Description}
    {PARAM2}=<value> (Optional) - {Description}. Defaults to {default}

  Examples:
    /{skill-name} {PARAM1}="value1, value2"
    /{skill-name} {PARAM1}="value" {PARAM2}=value
model: claude-opus-4-5
---
```

**Note:** Orchestrator skills typically require `model: claude-opus-4-5` for complex coordination decisions.

## Required Sections

### # {Skill Name} Skill

Start with the CRITICAL ROLE CONSTRAINT block:

```markdown
> **CRITICAL ROLE CONSTRAINT**
>
> You are an **ORCHESTRATOR**, not an implementer.
> You delegate work to SubAgents and coordinate their execution.
```

Follow with a brief description of what the skill orchestrates and when to use it.

### ## Parameters

Document all parameters:

```markdown
## Parameters

### Required

- `{PARAM1}` - Description of required parameter

### Optional

- `{PARAM2}` - Description. Defaults to `{default}` if not provided.
```

### ## Subagent Selection

Define how to choose the appropriate subagent:

```markdown
## Subagent Selection

Select the appropriate subagent based on task type:

| Task Type | Subagent | Reason |
|-----------|----------|--------|
| Can be handled by a Skill | `step-by-step-agent` | Execute skill with TodoWrite tracking |
| General tasks | `general-purpose` (Task tool) | Flexible execution for non-skill tasks |

### How to Determine Task Type

1. **Check if a skill exists**: Review available skills that match the task
2. **If skill exists**: Use `step-by-step-agent` with skill invocation
3. **If no skill exists**: Use `general-purpose` Task agent
```

### ## Behavior Rules

Document behavioral constraints. Use diagrams for clarity:

```markdown
## Behavior Rules

### 1. {Rule Name}

┌──────────────────────────────────────────────────────────────┐
│  {Visualization of the rule}                                  │
└──────────────────────────────────────────────────────────────┘

**Correct:**
{Example of correct behavior}

**Wrong:**
{Example of incorrect behavior}

### 2. {Another Rule}

{Description and examples}
```

### ## Process

Describe the orchestration process:

```markdown
## Process

### Step 1: {Parse/Analyze}

1. {Parse inputs}
2. For each item:
   - {Determine characteristics}
   - {Identify dependencies}

### Step 2: {Prepare/Gather Context}

If items require shared context:
1. Collect necessary information **before** parallel execution
2. This may include:
   - {Context type 1}
   - {Context type 2}

### Step 3: {Execute in Parallel}

1. Prepare all Task tool calls in a **single message**:
   \`\`\`
   Task(
     subagent_type: "{type}",
     prompt: "{instruction}",
     description: "{description}"
   )
   \`\`\`

2. Send all Task calls **simultaneously** (not sequentially)
3. Wait for all results

### Step 4: {Handle Results/Interactions}

For each agent result:
1. {Check status}
2. {Handle success/failure}
3. {Forward user questions if needed}

### Step 5: {Aggregate and Report}

1. Collect all final results
2. Synthesize into comprehensive summary
3. Report to user
```

### ## Error Handling

```markdown
## Error Handling

| Error Type | Action |
|------------|--------|
| Single task fails | Continue others, report failure in summary |
| All tasks fail | Report comprehensive error with details |
| Agent timeout | Report which agent timed out, include partial results |
| Resume fails | Ask user how to proceed (retry/skip/abort) |
```

### ## Output Format

Document the dynamic output structure:

```markdown
## Output Format

\`\`\`markdown
## {Skill Name} Results

### Summary
| Metric | Value |
|--------|-------|
| Total Tasks | {N} |
| Succeeded | {M} |
| Failed | {F} |

### Results

#### 1. {Task Description}
- **Agent**: {agent type}
- **Status**: {Success / Failed / Partial}
- **Output**: {Brief summary or error message}

...

### Notes
{Any important observations or follow-up suggestions}
\`\`\`
```

### ## Quality Checklist

```markdown
## Quality Checklist

Before completing, verify:

- [ ] **All inputs parsed correctly**: Each item identified and categorized
- [ ] **Correct subagents selected**: Task types matched to appropriate agents
- [ ] **Parallel execution used**: Independent items launched in ONE message
- [ ] **No unintended background**: `run_in_background` only if explicitly requested
- [ ] **Interactions handled**: All agent questions forwarded to user and resumed
- [ ] **Results aggregated**: Comprehensive summary provided to user
```

### ## Notice (Optional but Recommended)

```markdown
## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- {Thing it does NOT do - delegated to SubAgent}
- {Another thing it does NOT do}

### Dependent Skills

This skill may invoke the following skills via SubAgents:
- `{skill-name}` - {What it does}
- `{another-skill}` - {What it does}

**Anti-patterns to avoid:**
- {Anti-pattern 1}
- {Anti-pattern 2}
```

## Directory Structure

Orchestrator skills typically have a simple structure:

```
.agent/skills/{skill-name}/
└── SKILL.md
```

No references or scripts are typically needed since orchestration logic is self-contained in SKILL.md and execution is delegated to SubAgents.

## Key Differences from Workflow Skills

| Aspect | Workflow | Orchestrator |
|--------|----------|--------------|
| Role Constraint | None | CRITICAL ROLE CONSTRAINT block required |
| Output Format | Fixed structure | Dynamic based on results |
| User Interaction | Direct at phase boundaries | Delegated to SubAgents |
| SubAgent Selection | N/A | Required section |
| Behavior Rules | Implicit in process | Explicit section with diagrams |
| Process Focus | Sequential phases | Parallel coordination |

## Reference Examples

- `.agent/skills/run-parallelly/SKILL.md` - Parallel task execution
- `.agent/skills/plan-issues/SKILL.md` - Batch issue planning

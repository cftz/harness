---
name: edit-skill-workflow
description: |
  Use this skill to create new skills or modify existing ones with automated review and finalization.

  IMPORTANT: ALWAYS use this skill instead of manually creating skill files - it ensures proper structure, validation, and review.

  Orchestrates skill creation/modification through draft-skill, skill-review (auto-fix loop), and finalize-skill.

  Args:
    NAME=<name> (Required) - Skill name
    MODE=create|modify (Required) - Operation mode
    PROMPT="<text>" (Required) - What to create/modify
    AUTO_ACCEPT=true (Optional) - Skip user approval after review passes
    MAX_CYCLES=<n> (Optional) - Max auto-fix cycles (default: 10)
    SCOPE=user|project (Optional) - Target scope for finalize (default: user)

  Examples:
    /edit-skill-workflow NAME=gofmt-runner MODE=create PROMPT="Format Go code using gofmt"
    /edit-skill-workflow NAME=plan MODE=modify PROMPT="Add batch processing support"
    /edit-skill-workflow NAME=test-skill MODE=create PROMPT="Test skill" AUTO_ACCEPT=true
model: claude-opus-4-5
---

# Description

Orchestrates the complete skill creation/modification workflow with automated review loop and user approval before finalization.

> **CRITICAL ROLE CONSTRAINT**
>
> You are an **orchestrator**, not an implementer.
> - DO NOT execute skills yourself
> - DO NOT write code or content directly
> - ONLY coordinate the workflow by invoking dependent skills
> - When tasks fail, invoke the appropriate fix skill rather than fixing directly

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `NAME` | Yes | - | Skill name (kebab-case) |
| `MODE` | Yes | - | `create` for new skill, `modify` for existing |
| `PROMPT` | Yes | - | Description of what to create or modify |
| `AUTO_ACCEPT` | No | `false` | Skip user approval if review passes |
| `MAX_CYCLES` | No | `10` | Maximum auto-fix cycles before failing |
| `SCOPE` | No | `user` | Target scope: `user` or `project` |

## Workflow Diagram

```
┌─────────────────────────────────────────┐
│ Phase 1: Draft Creation                 │
│ skill: draft-skill                      │
│ args: {MODE} NAME={NAME} PROMPT="{...}" │
│ → Returns: DRAFT_PATH                   │
└─────────────────────────────────────────┘
          │
          ↓
┌─────────────────────────────────────────┐
│ Phase 2: Auto-fix Loop                  │
│ REPEAT (up to MAX_CYCLES):              │
│   1. skill: skill-review                │
│      args: {NAME}                       │
│   2. IF Pass → EXIT LOOP                │
│   3. IF Issues Found:                   │
│      - skill: draft-skill               │
│        args: modify NAME={NAME}         │
│              PROMPT="Fix: {issues}"     │
│      - Loop back                        │
└─────────────────────────────────────────┘
          │
          ↓ (Pass)
┌─────────────────────────────────────────┐
│ User Approval (if AUTO_ACCEPT=false)    │
│ - Show verification report              │
│ - AskUserQuestion: Approve / Changes    │
└─────────────────────────────────────────┘
          │
          ↓ (Approved)
┌─────────────────────────────────────────┐
│ Phase 3: Finalize                       │
│ skill: finalize-skill                   │
│ args: DRAFT_PATH={path} NAME={NAME}     │
│       SCOPE={SCOPE}                     │
└─────────────────────────────────────────┘
```

## Process

### Phase 1: Draft Creation

Invoke draft-skill to create the initial draft:

```
skill: draft-skill
args: {MODE} NAME={NAME} PROMPT="{PROMPT}"
```

Extract `DRAFT_PATH` from the output for use in later phases.

### Phase 2: Auto-fix Loop

Repeat up to `MAX_CYCLES` times:

#### Step 2.1: Run Review

```
skill: skill-review
args: {NAME}
```

#### Step 2.2: Check Result

Parse the review output:
- If "Pass" or "Total Issues: 0" → Exit loop, proceed to Phase 3
- If issues found → Continue to Step 2.3

#### Step 2.3: Auto-fix

For each issue found, invoke draft-skill to fix:

```
skill: draft-skill
args: modify NAME={NAME} PROMPT="Fix the following issues from skill-review: {issues_summary}"
```

Loop back to Step 2.1.

#### Step 2.4: Max Cycles Reached

If loop exceeds `MAX_CYCLES`:
1. Report failure with remaining issues
2. Ask user whether to:
   - Continue with more cycles
   - Finalize anyway (with warning)
   - Cancel

### Phase 3: User Approval

If `AUTO_ACCEPT=false` (default):

1. Show the final verification report
2. Show the skill content summary
3. Use `AskUserQuestion`:
   - "Approve and finalize"
   - "Request changes" (loops back to Phase 2)
   - "Cancel"

If `AUTO_ACCEPT=true`:
- Skip this phase, proceed directly to finalization

### Phase 4: Finalize

```
skill: finalize-skill
args: DRAFT_PATH={DRAFT_PATH} NAME={NAME} SCOPE={SCOPE}
```

## Subagent Selection

This skill uses the Skill tool directly (not Task tool with subagents) because:
- Skills are lightweight coordination steps
- No parallel execution needed within the workflow
- Sequential dependency between phases

## Behavior Rules

1. **Never implement directly**: Always delegate to atomic skills
2. **Track cycle count**: Fail gracefully if MAX_CYCLES exceeded
3. **Preserve user control**: Always allow user to cancel or modify
4. **Report progress**: Show cycle-by-cycle progress in output

## Output

SUCCESS:
- STATUS: Success or Failure
- SKILL_NAME: Name of the created/modified skill
- SKILL_DIR: Final skill location path
- CYCLES: Number of auto-fix cycles completed
- CYCLE_SUMMARY: Table of cycle results

ERROR: Error message string

## Error Handling

| Error | Action |
|-------|--------|
| Draft creation fails | Report error, exit |
| Review consistently fails | After MAX_CYCLES, ask user for direction |
| Finalize fails | Report error, suggest manual intervention |
| User cancels | Clean up temp files, exit cleanly |

# `save` Command

Save execution checkpoint to a Markdown file when user input is needed.

## Process

### 1. Create Checkpoint File

```
skill: mktemp
args: {skill-name}-checkpoint
```

### 2. Copy and Fill Template

Read `{baseDir}/assets/checkpoint-template.md` and fill:

| Placeholder | Value | Example |
|-------------|-------|---------|
| `{SKILL_INVOCATION}` | Original skill invocation | `/draft-clarify create ISSUE_ID=TA-123` |
| `{PROGRESS_SUMMARY}` | Summary of progress so far (natural language) | See example below |
| `{PARTIAL_OUTPUTS}` | Files created, data collected | See example below |
| `{QUESTIONS}` | Question list (Answer field indicates state) | See example below |

### 3. Return

```
STATUS: SUCCESS
OUTPUT:
  CONTEXT_PATH: .agent/tmp/xxx-context.md
  QUESTIONS: [...]
```

## Example Output

```markdown
---
invocation: /draft-clarify create ISSUE_ID=TA-123
---

# Context

## Progress Summary

Analyzed requirements from Linear Issue TA-123.

**Completed steps:**
- Issue data loaded
- Requirements completeness analysis done
- Confirmed "CLI to Daemon requests" in scope

**Analysis result:**
- Requirements are mostly clear, but communication method needs decision
- Need to choose: existing gRPC channel or new HTTP endpoint

## Partial Outputs

### prompt_path
.agent/tmp/20260120-143050-prompt

### issue_data
- Title: Add CLI Daemon Communication
- Description: Send requests from CLI to Daemon...
- Labels: enhancement, cli

## Questions

### Q1: Select CLI to Daemon communication method

**Header**: Communication Method

**Options**:
1. Use existing gRPC - Leverage current gRPC channel
2. New HTTP endpoint - Implement new REST API

**Context**: "CLI to Daemon requests" is in scope. Communication method affects API design scope.

**Answer**:
```

## Progress Summary Writing Guide

Progress Summary should include:

1. **Completed steps**: What work has been done
2. **Information collected/analyzed**: What data was read and analyzed
3. **Current state**: Why stopped here, what decision is needed

Reading this summary alone should provide enough context to understand the situation on resume.

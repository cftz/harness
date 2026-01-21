---
name: codex
description: |
  Use this skill when you need to leverage OpenAI Codex for code explanation, review, or getting a second AI perspective.

  OpenAI Codex CLI wrapper for AI agent collaboration.

  Args:
    PROMPT="..." (Required) - Prompt to send to Codex

  Examples:
    /codex PROMPT="Explain this code"
    /codex PROMPT="Review this function for bugs"
---

# Description

Executes OpenAI Codex CLI as an intermediate AI agent. Enables collaboration between different AI agents by passing prompts to Codex and returning results.

## Parameters

### Required

- `PROMPT` - The prompt or question to send to Codex

## Process

1. Validate that `PROMPT` parameter is provided
2. Execute Codex CLI:
   ```bash
   codex -p "$PROMPT"
   ```
3. Return the response to the caller

## Output

SUCCESS: (no output fields)

ERROR: Error message string

## Error Handling

### Codex CLI Not Found

If `codex` command is not available:
1. Inform user that Codex CLI is not installed
2. Suggest installation: Check official OpenAI Codex CLI documentation

### API Rate Limit

If rate limit error occurs:
1. Report the error to user
2. Suggest waiting before retry

---
name: gemini
description: |
  Use this skill when you need to leverage Google Gemini for code explanation, review, or getting a second AI perspective.

  Google Gemini CLI wrapper for AI agent collaboration.

  Args:
    PROMPT="..." (Required) - Prompt to send to Gemini

  Examples:
    /gemini PROMPT="Explain this code"
    /gemini PROMPT="Review this function for bugs"
---

# Description

Executes Google Gemini CLI as an intermediate AI agent. Enables collaboration between different AI agents by passing prompts to Gemini and returning results.

## Parameters

### Required

- `PROMPT` - The prompt or question to send to Gemini

## Process

1. Validate that `PROMPT` parameter is provided
2. Execute Gemini CLI:
   ```bash
   gemini -p "$PROMPT"
   ```
3. Return the response to the caller

## Error Handling

### Gemini CLI Not Found

If `gemini` command is not available:
1. Inform user that Gemini CLI is not installed
2. Suggest installation: Check official Google Gemini CLI documentation

### API Rate Limit

If rate limit error occurs:
1. Report the error to user
2. Suggest waiting before retry

## Output

SUCCESS:
- RESPONSE: Gemini's response text

ERROR: Error message string

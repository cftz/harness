---
name: test-skill
description: |
  Test skill for Subagent Stop Hook testing.

  Writes a short poem on a given topic.

  Args:
    TOPIC="..." (Optional) - Topic for the poem (default: "coding")

  Examples:
    /test-skill
    /test-skill TOPIC="spring"
context: fork
agent: step-by-step-agent
---

# Description

Test skill that writes a short poem. Used for testing Subagent hooks.

## Parameters

### Optional

- `TOPIC` - The topic for the poem (default: "coding")

## Process

1. Parse the `TOPIC` parameter (use "coding" if not provided)
2. Write a short 4-line poem about the topic
3. Output the poem

## Output

SUCCESS:
- POEM: The generated poem text

ERROR: Error message string

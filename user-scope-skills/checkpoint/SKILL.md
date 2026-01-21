---
name: checkpoint
description: |
  Utility skill for managing interruptible context files.

  Context files allow draft-* skills to save state when user input is needed,
  enabling resume after collecting answers via AskUserQuestion.

  Commands:
    save - Save context to a Markdown file
      No parameters - internally uses mktemp skill
      Returns: CONTEXT_PATH
    load - Load context from Markdown file
      CONTEXT_PATH=<path> (Required) - Path to context file
      Returns: Parsed context info
    update - Validate context file after filling answers
      CONTEXT_PATH=<path> (Required) - Path to context file
      Returns: READY or INCOMPLETE status

  Examples:
    /checkpoint save
    /checkpoint load CONTEXT_PATH=.agent/tmp/xxx-context.md
    /checkpoint update CONTEXT_PATH=.agent/tmp/xxx-context.md
user-invocable: false
---

# Description

Allows draft-* skills to save execution state to a file when user input is required, and resume later.

## Commands

| Command  | Description                       | Docs                             |
| -------- | --------------------------------- | -------------------------------- |
| `save`   | Create and save checkpoint file   | `{baseDir}/references/save.md`   |
| `load`   | Read checkpoint file and parse state | `{baseDir}/references/load.md`   |
| `update` | Validate answer fields are filled | `{baseDir}/references/update.md` |

## Output

### save Command

SUCCESS:
- CONTEXT_PATH: Path to the created checkpoint file

AWAIT: Uses checkpoint file pattern (this skill creates the checkpoint)

ERROR: Error message string

### load Command

SUCCESS:
- INVOCATION: Original skill invocation string
- PENDING_QUESTIONS: List of questions without answers
- ANSWERED_QUESTIONS: List of questions with answers

ERROR: Error message string

### update Command

SUCCESS:
- STATUS: READY or INCOMPLETE
- MISSING: List of unanswered questions (if INCOMPLETE)

ERROR: Error message string

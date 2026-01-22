---
name: checkpoint
description: |
  Use this skill to manage interruptible context files.

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
context: fork
---

# Description

Use this skill to manage interruptible context files. Allows draft-* skills to save execution state to a file when user input is required, and resume later.

## Commands

| Command  | Description                       | Docs                             |
| -------- | --------------------------------- | -------------------------------- |
| `save`   | Create and save checkpoint file   | `{baseDir}/references/save.md`   |
| `load`   | Read checkpoint file and parse state | `{baseDir}/references/load.md`   |
| `update` | Validate answer fields are filled | `{baseDir}/references/update.md` |

## Parameters

### save Command

No parameters - internally uses mktemp skill.

### load Command

| Parameter      | Required | Description                         |
| -------------- | -------- | ----------------------------------- |
| `CONTEXT_PATH` | Yes      | Path to the checkpoint file to load |

### update Command

| Parameter      | Required | Description                 |
| -------------- | -------- | --------------------------- |
| `CONTEXT_PATH` | Yes      | Path to the checkpoint file |

## Output

### save Command

SUCCESS:
- CONTEXT_PATH: Path to the created checkpoint file

ERROR: Error message string

### load Command

SUCCESS:
- CONTEXT_PATH: Path to the loaded checkpoint file
- INVOCATION: Original skill invocation string
- PENDING_QUESTIONS: List of questions without answers
- ANSWERED_QUESTIONS: List of questions with answers

ERROR: Error message string

### update Command

SUCCESS:
- CONTEXT_PATH: Path to the checkpoint file
- RESULT: READY or INCOMPLETE
- MISSING: List of unanswered questions (if INCOMPLETE)

ERROR: Error message string

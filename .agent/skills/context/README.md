# Context Skill

## Intent

Enables draft-* skills to save execution state to a file when user input is required, allowing the workflow to resume after answers are collected via AskUserQuestion.

## Motivation

Draft-* skills run with `context: fork`, meaning:
- They execute in a separate environment from the main conversation
- They cannot directly prompt users via AskUserQuestion
- Traditional fork completion does not support resuming state

The context file pattern solves this by:
1. Saving state to a file when user input is needed
2. Returning `AWAIT` status to the workflow
3. Workflow collects answers via AskUserQuestion
4. Workflow records answers in the context file
5. `resume` command reloads state and continues

## Design Decisions

- **Markdown format**: Human-readable and naturally understood by agents
- **Progress Summary**: Natural language description helps agents understand context on resume
- **Invocation preservation**: Stores original call info for accurate resumption

## Constraints

- Context files are stored in `.agent/tmp/`
- Files are not auto-deleted (user must clean up manually)
- Useful for debugging and retry scenarios

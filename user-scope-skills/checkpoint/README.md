# Intent

Enables draft-* skills to save execution state to a file when user input is required, allowing the workflow to resume after answers are collected via AskUserQuestion.

## Motivation

Draft-* skills run with `context: fork`, meaning:
- They execute in a separate environment from the main conversation
- They cannot directly prompt users via AskUserQuestion
- Traditional fork completion does not support resuming state

The checkpoint file pattern solves this by:
1. Saving state to a file when user input is needed
2. Returning `AWAIT` status to the workflow
3. Workflow collects answers via AskUserQuestion
4. Workflow records answers in the checkpoint file
5. `resume` command reloads state and continues

## Design Decisions

- **Markdown format**: Human-readable and naturally understood by agents
- **Progress Summary**: Natural language description helps agents understand context on resume
- **Invocation preservation**: Stores original call info for accurate resumption

## Constraints

- Checkpoint files are stored in `.agent/tmp/`
- Files are not auto-deleted (user must clean up manually)
- Useful for debugging and retry scenarios

## Subagent Hooks

This skill includes hook scripts that improve subagent behavior:

| Script | Hook Type | Purpose |
|--------|-----------|---------|
| `subagent-start.py` | SubagentStart | Injects resume command guidance |
| `subagent-stop.py` | SubagentStop | Verifies task completion before stopping |
| `session-end.py` | SessionEnd | Same verification at session end |
| `install-hooks.py` | Setup | Auto-installs hooks during `claude --init` |

### Automatic Installation (Recommended)

Add the Setup hook to your user-level settings (`~/.claude/settings.json`).
This will automatically install the Subagent hooks to each project when you run `claude --init`.

**If the skill is installed in `~/.claude/skills/checkpoint/`:**

```json
{
  "hooks": {
    "Setup": [{
      "hooks": [{
        "type": "command",
        "command": "python3 ~/.claude/skills/checkpoint/scripts/install-hooks.py"
      }]
    }]
  }
}
```

**If the skill is in a project directory (e.g., `.agent/skills/checkpoint/`):**

```json
{
  "hooks": {
    "Setup": [{
      "hooks": [{
        "type": "command",
        "command": "python3 $CLAUDE_PROJECT_DIR/.agent/skills/checkpoint/scripts/install-hooks.py"
      }]
    }]
  }
}
```

### Manual Installation

If you prefer manual setup, add these hooks directly to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SubagentStart": [{
      "hooks": [{
        "type": "command",
        "command": "python3 /path/to/checkpoint/scripts/subagent-start.py"
      }]
    }],
    "SubagentStop": [{
      "hooks": [{
        "type": "command",
        "command": "python3 /path/to/checkpoint/scripts/subagent-stop.py"
      }]
    }],
    "SessionEnd": [{
      "hooks": [{
        "type": "command",
        "command": "python3 /path/to/checkpoint/scripts/session-end.py"
      }]
    }]
  }
}
```

### Verification

After running `claude --init`, check `.claude/settings.local.json` to confirm the hooks were installed.

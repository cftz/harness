#!/usr/bin/env python3
"""SubagentStart hook for skill execution reminders.

Injects a system-reminder at the start of every subagent execution,
including conditional guidance for resume commands.

Input (via stdin):
{
  "session_id": "abc123",
  "transcript_path": "...",
  "hook_event_name": "SubagentStart",
  "agent_id": "...",
  "agent_type": "..."
}

Exit codes:
- 0: Allow start (stderr message is injected if provided)
"""
import sys
import json
import os


def log(message: str):
    """Log to a file for debugging."""
    log_path = os.path.expanduser("~/.claude/subagent-start-hook.log")
    with open(log_path, "a") as f:
        f.write(f"{message}\n")


def main():
    log("=== SubagentStart Hook triggered ===")
    try:
        data = json.load(sys.stdin)
        log(f"Input: {json.dumps(data, indent=2)}")

        # Always inject reminder for all subagents
        log("Injecting startup reminder")
        reminder = """<system-reminder>
If you received a `resume` command with CONTEXT_PATH:

1. **Load checkpoint** - Read the CONTEXT_PATH file to understand:
   - Original invocation and parameters
   - Progress summary (what was done, why it paused)
   - Answered questions from the user

2. **Validate** - Use `checkpoint update` to verify all questions are answered

3. **Restore process** - Read the original skill's reference document:
   - Find `{baseDir}/references/{command}.md` where command is from the original invocation
   - Identify where you stopped in the process

4. **Continue execution** - Execute ALL remaining steps from the reference:
   - DO NOT just validate and return SUCCESS
   - MUST complete file creation, output generation, etc.
   - Continue until the ENTIRE original task is done

5. **Return properly** - Return SUCCESS with all required output fields

If you cannot continue (need more info), create a new checkpoint with AWAIT status.
</system-reminder>"""
        print(reminder, file=sys.stderr)
        sys.exit(0)

    except Exception as e:
        log(f"Error: {e}")
        sys.exit(0)


if __name__ == "__main__":
    main()

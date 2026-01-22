#!/usr/bin/env python3
"""SubagentStop hook for task completion verification.

Always blocks once to inject a system-reminder that asks the agent
to verify if the original goal is truly complete, or if it mistook
another skill's SUCCESS response as its own completion.

Input (via stdin):
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": bool
}

Exit codes:
- 0: Allow stop
- 2: Block stop, stderr message shown to agent
"""
import sys
import json
import os


def log(message: str):
    """Log to a file for debugging."""
    log_path = os.path.expanduser("~/.claude/subagent-stop-hook.log")
    with open(log_path, "a") as f:
        f.write(f"{message}\n")


def main():
    log("=== Hook triggered ===")
    try:
        data = json.load(sys.stdin)
        log(f"Input: {json.dumps(data, indent=2)}")

        # Skip if stop hook is already active to prevent infinite loop
        if data.get("stop_hook_active", False):
            log("stop_hook_active=true, allowing stop")
            sys.exit(0)

        # Always block once to inject reminder
        log("First attempt - blocking with completion verification reminder")
        reminder = """<system-reminder>
Before finishing, verify your task completion:

1. Is your ORIGINAL goal truly complete?
2. Did you mistake another skill's SUCCESS response as your own completion?
   - A child skill returning SUCCESS only means THAT skill finished
   - It does NOT mean YOUR task is complete
3. Review your todo list - are ALL items marked as completed?

If everything is genuinely done, proceed to finish.
If not, continue working on the remaining steps.
</system-reminder>"""
        log(f"Stderr reminder: {reminder[:100]}...")
        print(reminder, file=sys.stderr)
        sys.exit(2)

    except Exception as e:
        log(f"Error: {e}")
        # On error, allow normal completion
        sys.exit(0)


if __name__ == "__main__":
    main()

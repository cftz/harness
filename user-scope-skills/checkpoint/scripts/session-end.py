#!/usr/bin/env python3
"""SessionEnd hook for task completion verification.

Injects a system-reminder at the end of a session that asks the agent
to verify if the original goal is truly complete, or if it mistook
another skill's SUCCESS response as its own completion.

Input (via stdin):
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "hook_event_name": "SessionEnd"
}

Exit codes:
- 0: Allow session end (stderr message is injected if provided)
"""
import sys
import json
import os


def log(message: str):
    """Log to a file for debugging."""
    log_path = os.path.expanduser("~/.claude/session-end-hook.log")
    with open(log_path, "a") as f:
        f.write(f"{message}\n")


def main():
    log("=== SessionEnd Hook triggered ===")
    try:
        data = json.load(sys.stdin)
        log(f"Input: {json.dumps(data, indent=2)}")

        # Inject reminder for session end
        log("Injecting session end reminder")
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
        print(reminder, file=sys.stderr)
        sys.exit(0)

    except Exception as e:
        log(f"Error: {e}")
        sys.exit(0)


if __name__ == "__main__":
    main()

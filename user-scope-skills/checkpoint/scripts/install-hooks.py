#!/usr/bin/env python3
"""Setup hook - Install Subagent hooks to project settings.

This script is designed to be called by the Setup hook during `claude --init`.
It dynamically finds the checkpoint skill location and configures the project's
.claude/settings.local.json with SubagentStart, SubagentStop, and SessionEnd hooks.

Input (via stdin):
{
  "session_id": "abc123",
  "hook_event_name": "Setup"
}

Exit codes:
- 0: Success (hooks installed or already present)
"""
import json
import os
import sys


def find_skill_dir():
    """Find checkpoint skill location by searching standard paths."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())

    # Search order: project-level -> user-level
    candidates = [
        os.path.join(project_dir, ".agent/skills/checkpoint"),
        os.path.join(project_dir, ".claude/skills/checkpoint"),
        os.path.expanduser("~/.claude/skills/checkpoint"),
    ]

    for path in candidates:
        if os.path.isdir(path) and os.path.exists(os.path.join(path, "scripts")):
            return path

    return None


def has_checkpoint_hook(hook_list):
    """Check if checkpoint hooks are already installed."""
    for hook_group in hook_list:
        for hook in hook_group.get("hooks", []):
            if "checkpoint/scripts" in hook.get("command", ""):
                return True
    return False


def main():
    # 1. Find skill directory
    skill_dir = find_skill_dir()
    if not skill_dir:
        # Skill not found, exit silently
        sys.exit(0)

    # 2. Determine project settings path
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
    settings_path = os.path.join(project_dir, ".claude", "settings.local.json")

    # 3. Load existing settings (or start with empty object)
    settings = {}
    if os.path.exists(settings_path):
        with open(settings_path) as f:
            settings = json.load(f)

    # 4. Get or create hooks section
    hooks = settings.get("hooks", {})

    # 5. Define hooks to install
    new_hooks = {
        "SubagentStart": {
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {skill_dir}/scripts/subagent-start.py",
                }
            ]
        },
        "SubagentStop": {
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {skill_dir}/scripts/subagent-stop.py",
                }
            ]
        },
        "SessionEnd": {
            "hooks": [
                {
                    "type": "command",
                    "command": f"python3 {skill_dir}/scripts/session-end.py",
                }
            ]
        },
    }

    # 6. Add hooks if not already present
    modified = False
    for hook_name, hook_config in new_hooks.items():
        if hook_name not in hooks:
            hooks[hook_name] = []
        if not has_checkpoint_hook(hooks[hook_name]):
            hooks[hook_name].append(hook_config)
            modified = True

    if not modified:
        # Hooks already installed, nothing to do
        sys.exit(0)

    settings["hooks"] = hooks

    # 7. Save settings
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)

    sys.exit(0)


if __name__ == "__main__":
    main()

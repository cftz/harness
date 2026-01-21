#!/usr/bin/env python3
"""PreToolUse hook to inject CLAUDE_PROJECT_DIR into Bash commands for deep-find skill."""
import sys
import json
import os
import subprocess


def get_project_root():
    """Determine project root: CLAUDE_PROJECT_DIR > git root > cwd"""
    if os.environ.get('CLAUDE_PROJECT_DIR'):
        return os.environ['CLAUDE_PROJECT_DIR']
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--show-toplevel'],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except Exception:
        return os.getcwd()


def main():
    try:
        data = json.load(sys.stdin)
        command = data.get('tool_input', {}).get('command', '')
        project_dir = get_project_root()

        if project_dir and command:
            # Inject CLAUDE_PROJECT_DIR at the start of the command
            modified_command = f'CLAUDE_PROJECT_DIR="{project_dir}" {command}'
            result = {
                'hookSpecificOutput': {
                    'hookEventName': 'PreToolUse',
                    'permissionDecision': 'allow',
                    'updatedInput': {
                        'command': modified_command
                    }
                }
            }
            print(json.dumps(result))
        # If no project_dir, output nothing to allow original command
    except Exception:
        # On error, output nothing to allow original command
        pass


if __name__ == '__main__':
    main()

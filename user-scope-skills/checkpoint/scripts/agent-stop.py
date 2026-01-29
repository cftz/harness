#!/usr/bin/env python3
"""
Agent stop hook for checkpoint skill.

This hook verifies task completion before stopping an agent.
Works with both SubagentStop and Stop hooks.
Checks todos file to ensure no pending/in_progress tasks remain.
"""

import sys
import json
import os
from datetime import datetime

LOG_FILE = os.path.expanduser("~/.claude/agent-stop-debug.log")


def log_debug(
    data: dict,
    incomplete_todos: list | None = None,
    checked_files: list[str] | None = None,
    incomplete_transcript: list[str] | None = None,
    task_status: dict[str, str] | None = None,
    decision_info: dict | None = None,
):
    """Log hook input for debugging."""
    with open(LOG_FILE, "a") as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"Timestamp: {datetime.now().isoformat()}\n")
        f.write(f"Input: {json.dumps(data, indent=2)}\n")
        if checked_files is not None:
            f.write(f"Checked files: {json.dumps(checked_files, indent=2)}\n")
        if incomplete_todos is not None:
            f.write(f"Incomplete from todos: {json.dumps(incomplete_todos, indent=2)}\n")
        if task_status is not None:
            f.write(f"Task status from transcript: {json.dumps(task_status, indent=2)}\n")
        if incomplete_transcript is not None:
            f.write(f"Incomplete from transcript: {json.dumps(incomplete_transcript, indent=2)}\n")
        if decision_info is not None:
            f.write(f"Decision info: {json.dumps(decision_info, indent=2)}\n")


def get_incomplete_tasks_from_todos(
    session_id: str, agent_id: str
) -> tuple[list[dict], list[str]]:
    """
    Check todos files for incomplete tasks.

    Checks multiple locations:
    1. Subagent-specific file: {session_id}-agent-{agent_id}.json
    2. Main session file: {session_id}-agent-{session_id}.json

    Args:
        session_id: The session UUID
        agent_id: The agent ID (full UUID or short ID)

    Returns:
        Tuple of (incomplete_tasks, checked_files)
    """
    todos_dir = os.path.expanduser("~/.claude/todos")
    checked_files: list[str] = []
    all_incomplete: list[dict] = []

    # Files to check (in order of priority)
    files_to_check = [
        f"{session_id}-agent-{agent_id}.json",  # Subagent-specific
        f"{session_id}-agent-{session_id}.json",  # Main session
    ]

    for filename in files_to_check:
        todos_file = os.path.join(todos_dir, filename)
        checked_files.append(todos_file)

        if not os.path.exists(todos_file):
            continue

        try:
            with open(todos_file) as f:
                todos = json.load(f)

            if not isinstance(todos, list):
                continue

            # Find tasks that are not completed
            incomplete = [
                t for t in todos
                if t.get("status") in ("pending", "in_progress")
            ]
            all_incomplete.extend(incomplete)
        except (json.JSONDecodeError, IOError):
            continue

    return all_incomplete, checked_files


def get_incomplete_tasks_from_transcript(
    transcript_path: str,
) -> tuple[list[str], dict[str, str]]:
    """
    Parse transcript to find incomplete tasks.

    Looks for TaskCreate/TaskUpdate calls and their responses to track status.

    Args:
        transcript_path: Path to the agent's transcript file

    Returns:
        Tuple of (incomplete_task_ids, task_status_map)
    """
    if not os.path.exists(transcript_path):
        return [], {}

    task_status: dict[str, str] = {}  # task_id -> status
    pending_creates: dict[str, bool] = {}  # tool_use_id -> True (waiting for response)
    import re

    try:
        with open(transcript_path) as f:
            for line in f:
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                message = entry.get("message", {})
                content = message.get("content", [])
                if not isinstance(content, list):
                    continue

                for item in content:
                    item_type = item.get("type", "")

                    # Track TaskCreate calls
                    if item_type == "tool_use" and item.get("name") == "TaskCreate":
                        tool_use_id = item.get("id", "")
                        if tool_use_id:
                            pending_creates[tool_use_id] = True

                    # Track TaskCreate responses to get task IDs
                    elif item_type == "tool_result":
                        tool_use_id = item.get("tool_use_id", "")
                        result_content = item.get("content", "")

                        if tool_use_id in pending_creates:
                            # Parse: "Task #25 created successfully: ..."
                            match = re.search(r"Task #(\d+) created", result_content)
                            if match:
                                task_id = match.group(1)
                                task_status[task_id] = "pending"
                            del pending_creates[tool_use_id]

                    # Track TaskUpdate calls
                    elif item_type == "tool_use" and item.get("name") == "TaskUpdate":
                        tool_input = item.get("input", {})
                        task_id = tool_input.get("taskId", "")
                        status = tool_input.get("status", "")
                        if task_id and status:
                            task_status[task_id] = status

        # Find tasks that are not completed
        incomplete = [
            task_id for task_id, status in task_status.items()
            if status in ("pending", "in_progress")
        ]
        return incomplete, task_status

    except IOError:
        return [], {}


def main():
    """
    Hook that runs when an agent is about to stop.

    Works with both SubagentStop and Stop hooks.
    Reads hook input from stdin, checks todos file for incomplete tasks,
    and blocks stopping if tasks remain.

    Returns:
        JSON response: {"decision": "block", "reason": "..."} to prevent stopping,
        or {} to allow stopping.
    """
    # Read stdin
    stdin_data = sys.stdin.read()

    try:
        hook_input = json.loads(stdin_data) if stdin_data else {}
    except json.JSONDecodeError:
        # Can't parse input, allow stopping
        print(json.dumps({}))
        return 0

    session_id = hook_input.get("session_id", "")
    agent_id = hook_input.get("agent_id", "")

    if not session_id:
        # Missing session_id, log and allow stopping
        log_debug(hook_input, None)
        print(json.dumps({}))
        return 0

    # Fallback for Stop hook (no agent_id)
    if not agent_id:
        agent_id = session_id

    # Check for incomplete tasks from todos files
    incomplete_todos, checked_files = get_incomplete_tasks_from_todos(session_id, agent_id)

    # Check for incomplete tasks from transcript (more reliable)
    # Fallback to main transcript for Stop hook
    transcript_path = hook_input.get("agent_transcript_path") or hook_input.get("transcript_path", "")
    incomplete_transcript, task_status = get_incomplete_tasks_from_transcript(transcript_path)

    # Determine response based on task status
    stop_hook_active = hook_input.get("stop_hook_active", False)
    has_tasks = bool(task_status) or bool(incomplete_todos)

    # Log for debugging
    log_debug(
        hook_input,
        incomplete_todos,
        checked_files,
        incomplete_transcript,
        task_status,
        {"stop_hook_active": stop_hook_active, "has_tasks": has_tasks},
    )

    if incomplete_transcript:
        # Case 1: Incomplete tasks from transcript → Block
        response = {
            "decision": "block",
            "reason": f"<system-reminder>Tasks incomplete: {incomplete_transcript}. Complete all tasks before stopping. If you're waiting for a background task to finish, use TaskOutput with block=true to wait for completion. If you need to confirm something with the user before completing tasks, use AskUserQuestion tool.</system-reminder>"
        }
    elif incomplete_todos:
        # Case 2: Incomplete tasks from todos → Block
        task_names = [t.get("content", "Unknown task") for t in incomplete_todos]
        response = {
            "decision": "block",
            "reason": f"<system-reminder>Tasks incomplete: {task_names}. Complete all tasks before stopping. If you're waiting for a background task to finish, use TaskOutput with block=true to wait for completion. If you need to confirm something with the user before completing tasks, use AskUserQuestion tool.</system-reminder>"
        }
    elif has_tasks:
        # Case 3: All tasks completed → Allow
        response = {}
    elif not stop_hook_active:
        # Case 4: No tasks + first stop attempt → Block with reminder
        response = {
            "decision": "block",
            "reason": "<system-reminder>No tasks were tracked. Please verify all work is complete before stopping. If you've finished your work, you may stop now.</system-reminder>"
        }
    else:
        # Case 5: No tasks + already reminded → Allow
        response = {}

    print(json.dumps(response))
    return 0


if __name__ == "__main__":
    sys.exit(main())

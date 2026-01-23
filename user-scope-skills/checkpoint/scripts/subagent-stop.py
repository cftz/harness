#!/usr/bin/env python3
"""
Backwards compatibility shim for subagent-stop.py -> agent-stop.py

This script was renamed to agent-stop.py. This shim maintains backwards
compatibility for any cached hook configurations that still reference the
old filename.
"""

import sys
import os
import importlib.util

# Load agent-stop.py module dynamically
script_dir = os.path.dirname(os.path.abspath(__file__))
agent_stop_path = os.path.join(script_dir, 'agent-stop.py')

spec = importlib.util.spec_from_file_location("agent_stop", agent_stop_path)
agent_stop = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agent_stop)

if __name__ == "__main__":
    sys.exit(agent_stop.main())

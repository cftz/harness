# skill-finder

## Intent

Provides visibility into all available Skills, Tools, and Agents by analyzing user prompts and recommending the most relevant ones. Ensures agents don't miss existing tools and avoid reinventing functionality.

## Motivation

Agents often don't have visibility into the full list of available skills because the skill list is truncated in context. This leads to situations where agents attempt to perform tasks manually when a dedicated skill already exists. This skill solves that by running in a forked context to scan all available tools without consuming main context space.

## Design Decisions

- **Forked Context**: Uses `context: fork` to avoid consuming main conversation context while scanning all tools
- **Sonnet Model**: Uses a lighter model (sonnet) since the task is analysis/matching, not complex reasoning
- **Read-Only**: Only reads skill definitions - never executes tools or modifies files
- **Comprehensive Output**: Returns all potentially relevant tools rather than filtering aggressively
- **File System Scan**: System prompt truncates skill list due to token limits (e.g., "Showing 2 of 48 skills"). This skill scans all skill directories:
  - Local: `.claude/skills/`, `.agent/skills/` (current + parent dirs + home)
  - Plugins: Reads `settings.json`, `settings.local.json`, `~/.claude/settings.json` for `enabledPlugins`
  - Installed plugins: Reads `~/.claude/plugins/installed_plugins.json` for plugin directories

## Constraints

- Must NOT execute any recommended tools - only provide recommendations
- Must NOT modify any files - purely read-only analysis
- Should err on the side of over-recommending rather than missing relevant tools

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

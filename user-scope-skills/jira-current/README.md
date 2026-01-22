# Jira Current Skill

## Intent

Provide a cached context layer for Jira operations by storing and retrieving the current project and user. This skill eliminates repetitive prompts by caching user selections for project, and auto-fetching the authenticated user from Jira.

## Motivation

Many Jira-related skills need to know the current project or user context. Without caching, each skill would need to prompt the user repeatedly or require explicit parameters. This skill provides a read-through cache pattern that:
- Returns cached values instantly when available
- Prompts the user to select only on cache miss (for project)
- Fetches from API automatically on cache miss (for user)
- Persists selections in a project-local cache file

## Design Decisions

- **Read-through cache pattern**: Check cache first, fetch and prompt only on miss
- **Project-local cache**: Cache stored in `$PWD/.agent/cache/jira-current.json` so different projects can have different contexts
- **No team concept**: Unlike Linear, Jira's project is the primary organizational unit

## Constraints

- This skill should NOT create or modify Jira resources
- This skill should NOT bypass the cache for project commands (use explicit skill parameters instead)
- Cache invalidation is manual (delete the cache file)

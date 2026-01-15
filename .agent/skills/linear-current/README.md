# Linear Current Skill

## Intent

Provide a cached context layer for Linear operations by storing and retrieving the current team, project, and user. This skill eliminates repetitive prompts by caching user selections for team and project, and automatically fetching the authenticated user from the Linear API.

## Motivation

Many Linear-related skills need to know the current team, project, or user context. Without caching, each skill would need to prompt the user repeatedly or require explicit parameters. This skill provides a read-through cache pattern that:
- Returns cached values instantly when available
- Prompts the user to select only on cache miss
- Persists selections in a project-local cache file

## Design Decisions

- **Read-through cache pattern**: Check cache first, fetch and prompt only on miss
- **Project-local cache**: Cache stored in `$PWD/.agent/cache/linear-current.json` so different projects can have different contexts
- **User command fetches API directly**: Unlike team/project which require user selection, the user command fetches the authenticated viewer from Linear API

## Constraints

- This skill should NOT create or modify Linear resources
- This skill should NOT bypass the cache for team/project commands (use explicit skill parameters instead)
- Cache invalidation is manual (delete the cache file)

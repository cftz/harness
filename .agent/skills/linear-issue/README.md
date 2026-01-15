# Linear Issue Skill

## Intent

Provide a unified interface for managing Linear issues (create, read, update, list) with smart defaults and caching support. This skill simplifies interactions with the Linear GraphQL API by:

1. Abstracting the GraphQL query complexity behind simple commands
2. Providing intelligent defaults through cached team/project settings
3. Supporting issue relationships (parent-child, blocking)
4. Offering consistent parameter naming across all commands

## Motivation

Direct GraphQL API calls require:
- Knowledge of Linear's schema
- Manual ID resolution for teams, projects, states
- Repeated boilerplate for authentication and error handling

This skill centralizes these concerns, allowing other skills and workflows to interact with Linear issues without this complexity.

## Design Decisions

1. **Command-based interface**: Uses `get`, `list`, `update`, `create` commands rather than separate skills for each operation
2. **Smart caching**: Leverages `linear-current` skill for team/project defaults to reduce repetitive selections
3. **Identifier support**: Accepts both UUIDs and human-readable identifiers (e.g., TA-123)
4. **Relationship validation**: Validates parent and blocking issues before creation to fail fast

## Constraints

- This skill should NOT handle issue comments (use `linear-comment`)
- This skill should NOT handle issue relations directly (use `linear-issue-relation`)
- This skill should NOT manage workflow states (read-only access to state info)

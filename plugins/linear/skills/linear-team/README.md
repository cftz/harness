# Linear Team Skill

## Intent

Provide a standardized interface for listing Linear teams through the GraphQL API. This skill enables retrieving available teams for context selection and team-scoped operations.

## Motivation

Many Linear operations require a team context. This skill provides consistent access to team information for workflows that need to select or reference teams.

## Design Decisions

- Single command: `list` for retrieving all teams
- Returns team ID, key, and name for each team
- Uses GraphQL API for reliable data access

## Constraints

- This skill only lists teams, not creates/updates/deletes them
- Requires LINEAR_API_KEY environment variable

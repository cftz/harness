# Linear State Skill

## Intent

Provide a standardized interface for listing Linear workflow states through the GraphQL API. This skill enables retrieving state IDs needed for issue state transitions.

## Motivation

Updating issue states in Linear requires knowing the state ID. This skill provides easy lookup of available states for a team, either directly via TEAM_ID or derived from an issue via ISSUE_ID.

## Design Decisions

- Single command: `list` for retrieving states
- Multiple lookup methods: TEAM_ID, ISSUE_ID, or defaults to linear-current team
- Optional NAME filter for exact state lookup
- Uses GraphQL API for reliable data access

## Constraints

- This skill only lists states, not creates/updates/deletes them
- Requires LINEAR_API_KEY environment variable

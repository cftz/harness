# Linear Issue Label Skill

## Intent

Provide a standardized interface for listing Linear issue labels through the GraphQL API. This skill enables retrieving available labels for a team to support label assignment in issue creation and updates.

## Motivation

Labels help categorize and organize issues. This skill provides consistent access to available labels for workflows that need to assign or filter by labels.

## Design Decisions

- Single command: `list` for retrieving labels
- Defaults to current team via linear-current if TEAM_ID not provided
- Uses GraphQL API for reliable data access

## Constraints

- This skill only lists labels, not creates/updates/deletes them
- Requires LINEAR_API_KEY environment variable

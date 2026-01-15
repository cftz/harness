# Linear Project Skill

## Intent

Provide a standardized interface for listing Linear projects through the GraphQL API. This skill enables retrieving available projects, optionally filtered by team.

## Motivation

Projects in Linear organize related issues. This skill provides consistent access to project information for workflows that need to assign issues to projects or query project-specific data.

## Design Decisions

- Single command: `list` for retrieving projects
- Optional TEAM_ID filter to scope to specific team
- Uses GraphQL API for reliable data access

## Constraints

- This skill only lists projects, not creates/updates/deletes them
- Requires LINEAR_API_KEY environment variable

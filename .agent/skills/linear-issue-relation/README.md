# Linear Issue Relation Skill

## Intent

Provide a consistent interface for managing relationships between Linear issues via GraphQL API. This skill enables creating, listing, updating, and deleting issue relations (blocks, duplicate, related, similar).

## Motivation

Linear issues often have relationships that need to be tracked programmatically. This skill abstracts the GraphQL API complexity and provides a simple command-based interface for relation management.

## Design Decisions

- Commands follow CRUD pattern: create, list, update, delete
- All commands accept human-readable identifiers (e.g., TA-123) or UUIDs
- Output is always JSON for easy parsing by other skills

## Constraints

- This skill only manages issue relations, not the issues themselves
- Authentication via LINEAR_API_KEY environment variable is required
- Relation types are limited to Linear's supported types: blocks, duplicate, related, similar

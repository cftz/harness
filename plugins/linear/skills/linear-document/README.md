# Linear Document Skill

## Intent

Provide a standardized interface for managing Linear documents through the GraphQL API. This skill enables creating, reading, updating, and searching documents that can be attached to Linear issues for storing plans, reviews, and other artifacts.

## Motivation

Linear documents serve as the primary storage mechanism for plan documents, code review results, and other structured content that needs to be associated with issues. Having a dedicated skill ensures consistent document management across all workflows.

## Design Decisions

- Commands mirror standard CRUD operations: get, list, search, create, update
- Documents are attached to issues via ISSUE_ID parameter
- Content can be provided inline (CONTENT) or from file (CONTENT_FILE)
- Scripts handle GraphQL API communication

## Constraints

- This skill does NOT delete documents (Linear API limitation)
- Document content is always Markdown formatted
- Requires LINEAR_API_KEY environment variable

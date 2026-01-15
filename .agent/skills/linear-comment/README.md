# Linear Comment Skill

## Intent

Provide a standardized interface for managing Linear issue comments through the GraphQL API. This skill enables listing and creating comments on issues for communication and audit trails.

## Motivation

Comments on Linear issues serve important purposes:
- Recording decisions and discussions
- Logging automated workflow actions
- Providing context for issue transitions

Having a dedicated skill ensures consistent comment management across all workflows.

## Design Decisions

- Two commands: `list` for reading, `create` for writing
- Requires ISSUE_ID to scope operations to specific issues
- Uses GraphQL API for reliable data access

## Constraints

- This skill does NOT delete or update comments (read and create only)
- This skill does NOT handle document attachments (use linear-document)
- Requires LINEAR_API_KEY environment variable

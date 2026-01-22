# jira-issue

## Intent

Provide a reliable way to manage Jira issues (get, list, update, create) using **issueType ID** instead of name. This ensures issue creation works correctly with localized Jira instances where issue type names may be in different languages (e.g., Korean "작업" instead of "Task").

## Motivation

Jira MCP tools use issue type **names** for creation, which fails when:
- Jira is localized (e.g., Korean, Japanese, Chinese)
- Issue type names are customized per project
- Names differ across Jira instances

Using issueType **ID** ensures consistent behavior regardless of localization.

## Design Decisions

1. **ID-based issue type**: Uses `ISSUE_TYPE_ID` parameter instead of name to support localized Jira
2. **REST API direct calls**: Bypasses MCP for full control over request format
3. **AccountId for assignee**: Uses `accountId` (not email) for assignee field
4. **Paired with project-manage**: Relies on `project-manage metadata` to provide issue type IDs

## Constraints

- Requires `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` environment variables
- Does NOT support issue type name lookup (use `project-manage metadata` for ID mapping)
- Does NOT handle Jira OAuth (uses Basic Auth only)

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

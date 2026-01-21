# Finalize Clarify Skill

## Intent

Provide a reliable way to convert approved draft task documents into their final output destinations (artifact files or issue tracker issues). This skill handles the "finalization" phase of the clarify workflow, ensuring that only approved content is written to persistent storage.

## Motivation

The clarify workflow separates draft creation from finalization to enable:
1. Safe iteration on drafts in temporary storage
2. Review and approval gates before writing final content
3. Consistent output format across different destinations (artifact vs issue tracker)

## Design Decisions

- **Two output modes**: Supports both artifact directory (file-based) and issue tracker (API-based) outputs
- **Multi-provider support**: Abstracts issue tracker operations behind PROVIDER parameter to support Linear and Jira
- **Common logic in SKILL.md**: Provider-agnostic operations (user resolution, draft parsing, dependency ordering) are handled in the main skill before routing to provider-specific references
- **Provider-specific references for API calls only**: Reference documents contain only the provider-specific API call logic, not common data processing
- **Dependency resolution**: When creating issues, automatically resolves blocking relationships from task dependencies
- **Parent issue support**: Can create sub-issues under a specified parent issue
- **Atomic operation**: Converts all drafts in a single invocation to ensure consistency
- **Extensible architecture**: New providers can be added by creating `{provider}-output.md` reference with API call definitions
- **MCP-first for Jira**: Jira integration uses MCP server directly instead of custom skills

## Constraints

- Should NOT create or modify draft files (that is `draft-clarify`'s responsibility)
- Should NOT validate content (that is `clarify-review`'s responsibility)
- Should NOT be called without user approval (except when `AUTO_ACCEPT=true` in workflow)
- Expects draft files in the format produced by `draft-clarify`

## Provider Requirements

| Provider | Implementation | Requirements |
|----------|---------------|--------------|
| `linear` | Skills | `linear-issue`, `project-manage` |
| `jira` | MCP | `jira` MCP server (`mcp-atlassian`) |

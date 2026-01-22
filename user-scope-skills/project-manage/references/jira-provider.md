# Jira Provider

This document defines how project-manage interacts with Jira using jira2 MCP and jira-issue skill.

## MCP Tools

| Tool | Purpose |
|------|---------|
| `mcp__jira2__getAccessibleAtlassianResources` | Get available Atlassian sites (cloudId) |
| `mcp__jira2__atlassianUserInfo` | Get current user info |
| `mcp__jira2__getVisibleJiraProjects` | Get projects with issue types |
| `mcp__jira2__getJiraIssueTypeMetaWithFields` | Get components for issue type |

## Skills Used

| Skill | Purpose |
|-------|---------|
| `jira-issue` | Create/update issues with issueType ID |

## CloudId (Required First)

Before any Jira operation, get the cloudId:

```
mcp__jira2__getAccessibleAtlassianResources()
```

Returns:
```json
[
  {"id": "xxx-cloud-id", "name": "Company", "url": "https://company.atlassian.net"}
]
```

**If multiple sites:**
- Use AskUserQuestion to let user select
- Cache selected cloudId

## User

```
mcp__jira2__atlassianUserInfo()
```

Returns:
```json
{
  "account_id": "5c74dcae24a84d130780201b",
  "email": "user@example.com",
  "name": "User Name"
}
```

**Normalize to:**
```json
{
  "id": "5c74dcae24a84d130780201b",
  "name": "User Name",
  "email": "user@example.com"
}
```

## Project

```
mcp__jira2__getVisibleJiraProjects(cloudId, expandIssueTypes=true)
```

Returns:
```json
[
  {
    "id": "10001",
    "key": "PROJ",
    "name": "Project Name",
    "issueTypes": [
      {"id": "10001", "name": "Task", "subtask": false},
      {"id": "10002", "name": "Bug", "subtask": false},
      {"id": "10003", "name": "Sub-task", "subtask": true}
    ]
  }
]
```

**If multiple projects:**
- Use AskUserQuestion to let user select
- Cache selected project

**Normalize to:**
```json
{
  "id": "10001",
  "key": "PROJ",
  "name": "Project Name"
}
```

## Metadata

### Issue Types

Issue types come from `getVisibleJiraProjects(expandIssueTypes=true)`.

Cache format:
```json
{
  "issueTypes": [
    {"id": "10001", "name": "Task", "subtask": false},
    {"id": "10002", "name": "Bug", "subtask": false},
    {"id": "10003", "name": "Sub-task", "subtask": true}
  ]
}
```

### Components

```
mcp__jira2__getJiraIssueTypeMetaWithFields(cloudId, projectKey, issueTypeId)
```

Find `fields` entry where `key = "components"`, then get `allowedValues`:

```json
{
  "fields": [
    {
      "key": "components",
      "name": "Components",
      "allowedValues": [
        {"id": "10001", "name": "API"},
        {"id": "10002", "name": "Web"}
      ]
    }
  ]
}
```

**Component selection during init:**
- 0 components: Skip (no default needed)
- 1 component: Auto-select as default
- 2+ components: Use AskUserQuestion

### Labels

Labels in Jira are free-form text. To get existing labels, search issues:

```
mcp__jira2__searchJiraIssuesUsingJql(cloudId, "project = {projectKey}", fields=["labels"], limit=50)
```

Extract unique labels from results.

## Issue Creation

Use `jira-issue` skill with **issueType ID** (not name):

```
skill: jira-issue
args: create PROJECT={projectKey} ISSUE_TYPE_ID={issueTypeId} TITLE="..." ASSIGNEE={accountId} COMPONENT={componentName}
```

**Why use jira-issue skill instead of MCP:**
1. MCP uses issue type name which fails with localized names (e.g., Korean "작업")
2. jira-issue uses issue type ID which always works
3. Consistent interface with linear-issue skill

## Full Init Flow

1. **Get CloudId**
   ```
   mcp__jira2__getAccessibleAtlassianResources()
   ```
   - If multiple: AskUserQuestion
   - Cache cloudId

2. **Get User**
   ```
   mcp__jira2__atlassianUserInfo()
   ```
   - Normalize and cache

3. **Get Projects with IssueTypes**
   ```
   mcp__jira2__getVisibleJiraProjects(cloudId, expandIssueTypes=true)
   ```
   - If multiple: AskUserQuestion
   - Cache project and issueTypes

4. **Get Components** (using first non-subtask issue type)
   ```
   mcp__jira2__getJiraIssueTypeMetaWithFields(cloudId, projectKey, issueTypeId)
   ```
   - Extract components from fields
   - If multiple: AskUserQuestion for default
   - Cache components and defaultComponent

5. **Return Complete Context**
   ```json
   {
     "provider": "jira",
     "cloudId": "xxx",
     "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
     "user": {"id": "xxx", "name": "User Name", "email": "user@example.com"},
     "defaultComponent": "API"
   }
   ```

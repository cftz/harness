# Jira Init

Initialize Jira as the PMS provider. This document is self-contained with all steps needed for Jira initialization.

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__jira2__getAccessibleAtlassianResources` | Get available Atlassian sites (cloudId) |
| `mcp__jira2__atlassianUserInfo` | Get current user info |
| `mcp__jira2__getVisibleJiraProjects` | Get projects with issue types |
| `mcp__jira2__getJiraIssueTypeMetaWithFields` | Get components for issue type |

## Process

### Step 1: Get CloudId

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
- Cache selected cloudId:
  ```bash
  {baseDir}/scripts/write_cache.sh cloudId '"xxx-cloud-id"'
  ```

### Step 2: Get User

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

**Normalize and cache:**
```bash
{baseDir}/scripts/write_cache.sh user '{"id":"5c74dcae24a84d130780201b","name":"User Name","email":"user@example.com"}'
```

### Step 3: Get Projects with Issue Types

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

**Cache project:**
```bash
{baseDir}/scripts/write_cache.sh project '{"id":"10001","key":"PROJ","name":"Project Name"}'
```

**Cache issue types in metadata:**
```bash
{baseDir}/scripts/write_cache.sh metadata '{"issueTypes":[...],"labels":[],"components":[]}'
```

### Step 4: Get Components

Using the first non-subtask issue type ID from Step 3:

```
mcp__jira2__getJiraIssueTypeMetaWithFields(cloudId, projectKey, issueTypeId)
```

Find `fields` entry where `key = "components"`, extract `allowedValues`:

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

**Component selection:**
- **0 components**: Skip (no default needed)
- **1 component**: Auto-select as default
- **2+ components**: Use AskUserQuestion to let user select default

**Cache components and defaultComponent:**
```bash
# Update metadata with components
{baseDir}/scripts/write_cache.sh metadata '{"issueTypes":[...],"labels":[],"components":[{"id":"10001","name":"API"},...],"defaultComponent":"API"}'

# Also cache defaultComponent separately for easy access
{baseDir}/scripts/write_cache.sh defaultComponent '"API"'
```

### Step 5: Return Complete Context

```json
{
  "provider": "jira",
  "cloudId": "xxx-cloud-id",
  "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
  "user": {"id": "5c74dcae24a84d130780201b", "name": "User Name", "email": "user@example.com"},
  "defaultComponent": "API"
}
```

# `list` Command

List Jira issues with optional JQL filter.

## Parameters

### Required

- `PROJECT` - Project key (e.g., `PROJ`)

### Optional

- `JQL` - Additional JQL filter (will be combined with project filter)
- `LIMIT` - Maximum number of results (default: 50)

## Usage

```bash
# List all issues in project
skill: jira-issue
args: list PROJECT=PROJ

# List with JQL filter
skill: jira-issue
args: list PROJECT=PROJ JQL="status = 'To Do'"

# List with limit
skill: jira-issue
args: list PROJECT=PROJ LIMIT=10
```

## Process

### Step 1: Build JQL Query

Combine project filter with optional JQL:

- Base query: `project = "{PROJECT}"`
- If JQL provided: `project = "{PROJECT}" AND ({JQL})`

### Step 2: Search Issues

Run `{baseDir}/scripts/list_issues.sh` with parameters:

```bash
{baseDir}/scripts/list_issues.sh "{final_jql}" "{LIMIT}"
```

### Step 3: Return Result

Return the issue list:

```json
{
  "total": 25,
  "issues": [
    {
      "key": "PROJ-123",
      "summary": "Issue title",
      "status": "To Do",
      "issuetype": {"id": "10002", "name": "Task"},
      "assignee": {"displayName": "User Name"}
    }
  ]
}
```

## Environment Variables

- `JIRA_API_TOKEN` - Required for API authentication
- `JIRA_EMAIL` - Required for API authentication
- `JIRA_URL` - Jira instance URL

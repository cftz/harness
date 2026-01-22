# `get` Command

Get Jira issue details by issue key.

## Parameters

### Required

- `ID` - Issue key (e.g., `PROJ-123`)

## Usage

```bash
skill: jira-issue
args: get ID=PROJ-123
```

## Process

### Step 1: Fetch Issue

Run `{baseDir}/scripts/get_issue.sh` with the issue key:

```bash
{baseDir}/scripts/get_issue.sh "PROJ-123"
```

### Step 2: Return Result

Return the issue details:

```json
{
  "key": "PROJ-123",
  "id": "10001",
  "summary": "Issue title",
  "description": "Issue description",
  "status": "To Do",
  "assignee": {
    "accountId": "xxx",
    "displayName": "User Name",
    "emailAddress": "user@example.com"
  },
  "issuetype": {
    "id": "10002",
    "name": "Task",
    "subtask": false
  },
  "components": [{"id": "10001", "name": "API"}],
  "labels": ["backend"],
  "parent": {"key": "PROJ-100"}
}
```

## Environment Variables

- `JIRA_API_TOKEN` - Required for API authentication
- `JIRA_EMAIL` - Required for API authentication
- `JIRA_URL` - Jira instance URL

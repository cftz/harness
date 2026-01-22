# `user` Command

Get current user using read-through cache pattern.

Unlike Linear which has a direct viewer query, Jira requires fetching user via a workaround using `assignee = currentUser()` JQL.

## Usage

```bash
skill: jira:jira-current
args: user
```

## Output

```json
{"accountId": "xxx", "displayName": "John Doe", "emailAddress": "john@example.com"}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh user`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch Current User from API

Since Jira MCP doesn't have a direct "get current user" tool, use a search query with `currentUser()` to extract user info:

```
mcp__jira__jira_search(
  jql="assignee = currentUser() ORDER BY updated DESC",
  fields="assignee",
  limit=1
)
```

If the search returns at least one issue, extract the assignee field:
- `accountId`: The user's account ID
- `displayName`: The user's display name
- `emailAddress`: The user's email address

**If no issues found** (user has no assigned issues):

Use `AskUserQuestion` to get user's email, then fetch profile:

```json
{
  "questions": [{
    "question": "No assigned issues found. What is your Jira email address?",
    "header": "Email",
    "options": [],
    "multiSelect": false
  }]
}
```

Then call:
```
mcp__jira__jira_get_user_profile(user_identifier="<email>")
```

### Step 3: Save to Cache

Execute `{baseDir}/scripts/write_cache.sh user '<user_json>'`

Where `<user_json>` is:
```json
{"accountId": "xxx", "displayName": "John Doe", "emailAddress": "john@example.com"}
```

### Step 4: Return Result

Return the user as JSON:

```json
{"accountId": "xxx", "displayName": "John Doe", "emailAddress": "john@example.com"}
```

## Notes

- Unlike `project` which prompts the user to select, `user` fetches automatically
- The `currentUser()` JQL function returns the authenticated user
- If user has no assigned issues, manual email input is required as fallback

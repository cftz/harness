# list

List Linear issues with optional filters.

## Usage

```
skill: linear-issue
args: list [TEAM_ID=<id>] [PROJECT_ID=<id>] [STATE=<name>] [ASSIGNEE_ID=<id>] [PARENT_ID=<id>] [FIRST=<n>]
```

## Parameters

| Parameter     | Required | Description                                                            |
| ------------- | -------- | ---------------------------------------------------------------------- |
| `TEAM_ID`     | No       | Filter by team ID                                                      |
| `PROJECT_ID`  | No       | Filter by project ID                                                   |
| `STATE`       | No       | Filter by state name (e.g., "Todo", "In Progress")                     |
| `ASSIGNEE_ID` | No       | Filter by assignee user ID                                             |
| `PARENT_ID`   | No       | Filter by parent issue ID (returns sub-issues of the specified parent) |
| `FIRST`       | No       | Limit results (default: 50)                                            |

## Process

1. **Resolve Project** - If PROJECT_ID not specified, follow [resolve-project flow](#resolve-project)
2. **Build Query** - Apply all filters
3. **Execute & Return** - Call API and return results

### Resolve Project

**Step 1: Use linear-current**

Use `linear-current project` to get the current project with read-through cache:

```bash
skill: linear-current
args: project
```

This will:
- Return cached project if available
- Prompt user to select if not cached
- Automatically save selection to cache

Returns: `{"id": "project-uuid", "name": "Project Name"}`

**Step 2: Use Resolved ID**

Use the returned project ID for the issue query/operation.

If the user needs to search without a project filter, they should explicitly pass an empty `PROJECT_ID` parameter.

## Output

JSON array of issues:

```json
[
  {
    "id": "uuid",
    "identifier": "TA-123",
    "title": "Issue Title",
    "state": { "id": "...", "name": "Todo" },
    "team": { "id": "...", "key": "TA", "name": "Team Name" },
    "project": { "id": "...", "name": "Project Name" },
    "assignee": { "id": "...", "name": "User" },
    "priority": 2,
    "priorityLabel": "High",
    "url": "https://linear.app/...",
    "createdAt": "2024-01-01T00:00:00.000Z"
  },
  ...
]
```

## Execution

```bash
# List all issues (up to 50)
{baseDir}/scripts/list_issues.sh

# Filter by team
{baseDir}/scripts/list_issues.sh "team-uuid"

# Filter by team and state
{baseDir}/scripts/list_issues.sh "team-uuid" "" "Todo"

# Filter by parent issue (get sub-issues)
{baseDir}/scripts/list_issues.sh "" "" "" "" "parent-issue-uuid"
```

## Examples

```
# List all issues
skill: linear-issue
args: list

# List issues for a team
skill: linear-issue
args: list TEAM_ID=abc123

# List todo issues
skill: linear-issue
args: list STATE=Todo

# List issues assigned to a user
skill: linear-issue
args: list ASSIGNEE_ID=user-uuid

# List sub-issues of a parent issue
skill: linear-issue
args: list PARENT_ID=TA-123
```

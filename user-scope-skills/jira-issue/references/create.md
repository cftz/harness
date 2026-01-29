# `create` Command

Creates a Jira issue using **issueType ID** (not name).

This is the key difference from MCP tools - using ID ensures issue creation works regardless of localized issue type names.

## Parameters

### Required

- `PROJECT` - Project key (e.g., `PROJ`)
- `ISSUE_TYPE_ID` - Issue type ID (e.g., `10002`). Get from `project-manage metadata`
- `TITLE` - Issue summary/title

### Optional

- `DESCRIPTION` - Issue description in Markdown format
- `ASSIGNEE` - Assignee account ID (NOT email). Get from `project-manage user`
- `COMPONENT` - Component name to assign
- `PARENT` - Parent issue key for sub-tasks (e.g., `PROJ-100`)
- `LABELS` - Comma-separated label names
- `CUSTOM_FIELDS` - JSON string for custom fields. Format: `'{"customfield_XXXXX": value}'`

## Custom Fields

Use `CUSTOM_FIELDS` to set Jira custom fields that are not supported by standard parameters.

**Format:** JSON string with field IDs as keys.

**Common value formats:**
- Text field: `{"customfield_10001": "text value"}`
- Select field: `{"customfield_10002": {"value": "Option A"}}`
- Multi-select field: `{"customfield_10003": [{"value": "Option A"}, {"value": "Option B"}]}`
- User field: `{"customfield_10004": {"accountId": "user-account-id"}}`
- Number field: `{"customfield_10005": 42}`

**Example:** Setting a required multi-select custom field:
```bash
skill: jira-issue
args: create PROJECT=SP ISSUE_TYPE_ID=10002 TITLE="Task" CUSTOM_FIELDS='{"customfield_10378": [{"value": "미정"}]}'
```

## Usage Examples

```bash
# Basic issue creation
skill: jira-issue
args: create PROJECT=PROJ ISSUE_TYPE_ID=10002 TITLE="Fix login button"

# With assignee and component
skill: jira-issue
args: create PROJECT=PROJ ISSUE_TYPE_ID=10002 TITLE="Fix bug" ASSIGNEE=5c74dcae24a84d130780201b COMPONENT="API"

# Sub-task under parent
skill: jira-issue
args: create PROJECT=PROJ ISSUE_TYPE_ID=10003 TITLE="Sub-task" PARENT=PROJ-100

# With custom fields
skill: jira-issue
args: create PROJECT=SP ISSUE_TYPE_ID=10002 TITLE="New task" CUSTOM_FIELDS='{"customfield_10378": [{"value": "미정"}]}'

# Full example with custom fields
skill: jira-issue
args: create PROJECT=PROJ ISSUE_TYPE_ID=10002 TITLE="Implement feature" DESCRIPTION="Add new functionality" ASSIGNEE=5c74dcae24a84d130780201b COMPONENT="Web" LABELS="enhancement,frontend" CUSTOM_FIELDS='{"customfield_10001": "extra info"}'
```

## Process

### Step 1: Get Issue Type ID from Metadata

If not provided, use `project-manage metadata` to get available issue types:

```
skill: project-manage
args: metadata
```

Returns:
```json
{
  "issueTypes": [
    {"id": "10001", "name": "Task", "subtask": false},
    {"id": "10002", "name": "Bug", "subtask": false},
    {"id": "10003", "name": "Sub-task", "subtask": true}
  ]
}
```

### Step 2: Validate Parent (if PARENT provided)

For sub-tasks, verify parent exists:

```
skill: jira-issue
args: get ID={PARENT}
```

### Step 3: Create Issue

Run `{baseDir}/scripts/create_issue.sh` with positional arguments:

1. `PROJECT` - Project key
2. `ISSUE_TYPE_ID` - Issue type ID (not name!)
3. `TITLE` - Issue summary
4. `DESCRIPTION` - Description (optional, empty string if not provided)
5. `ASSIGNEE` - Assignee account ID (optional, empty string if not provided)
6. `COMPONENT` - Component name (optional, empty string if not provided)
7. `PARENT` - Parent issue key (optional, empty string if not provided)
8. `LABELS` - Comma-separated labels (optional, empty string if not provided)
9. `CUSTOM_FIELDS` - JSON string for custom fields (optional, empty string if not provided)

```bash
{baseDir}/scripts/create_issue.sh "PROJ" "10002" "Fix bug" "Description here" "5c74dcae24a84d130780201b" "API" "" "bug,backend" '{"customfield_10378": [{"value": "미정"}]}'
```

### Step 4: Report Result

Display created issue information:

```
Issue created successfully.

- Issue: PROJ-456
- Title: Fix bug
- Type: Task (10002)
- Project: PROJ
- Parent: None
- URL: https://company.atlassian.net/browse/PROJ-456
```

## Environment Variables

- `JIRA_API_TOKEN` - Required for API authentication
- `JIRA_EMAIL` - Required for API authentication
- `JIRA_URL` - Jira instance URL (e.g., https://company.atlassian.net)

## Why Use Issue Type ID?

Jira issue type names can be:
- Localized (e.g., Korean "작업" instead of "Task")
- Customized per project
- Different across Jira instances

Using the ID ensures consistent behavior:

```bash
# MCP approach (may fail with localized names)
mcp__jira__jira_create_issue(issue_type="작업")  # ❌

# This skill (always works)
/jira-issue create ISSUE_TYPE_ID=10002 ...  # ✅
```

# update

Update a Linear issue.

## Usage

```
skill: linear-issue
args: update ID=<issue-id> [STATE_ID=<id>] [TITLE="..."] [DESCRIPTION="..."] [ASSIGNEE_ID=<id>] [LABEL_IDS=<ids>] [ADD_LABEL_IDS=<ids>] [PRIORITY=<n>] [PROJECT_ID=<id>]
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `ID` | Yes | Issue UUID or identifier (e.g., TA-123) |
| `STATE_ID` | No | New workflow state ID |
| `TITLE` | No | New title |
| `DESCRIPTION` | No | New description (markdown) |
| `ASSIGNEE_ID` | No | Assignee user ID (use "null" to unassign) |
| `LABEL_IDS` | No | Comma-separated label IDs (replaces all labels) |
| `ADD_LABEL_IDS` | No | Comma-separated label IDs to add |
| `PRIORITY` | No | Priority (0=None, 1=Urgent, 2=High, 3=Normal, 4=Low) |
| `PROJECT_ID` | No | Project ID |

## Output

JSON object with updated issue:

```json
{
  "id": "uuid",
  "identifier": "TA-123",
  "title": "Updated Title",
  "url": "https://linear.app/...",
  "state": { "id": "...", "name": "In Progress" },
  "team": { "id": "...", "key": "TA", "name": "Team Name" },
  "project": { "id": "...", "name": "Project Name" },
  "assignee": { "id": "...", "name": "User", "email": "user@example.com" },
  "labels": { "nodes": [{ "id": "...", "name": "bug", "color": "#ff0000" }] },
  "priority": 2,
  "priorityLabel": "High"
}
```

## Execution

```bash
# Update state
{baseDir}/scripts/update_issue.sh "TA-123" "state-uuid"

# Update title
{baseDir}/scripts/update_issue.sh "TA-123" "" "New Title"

# Add labels
{baseDir}/scripts/update_issue.sh "TA-123" "" "" "" "" "" "label1,label2"
```

## Examples

```
# Change state
skill: linear-issue
args: update ID=TA-123 STATE_ID=state-uuid

# Update title and priority
skill: linear-issue
args: update ID=TA-123 TITLE="Fixed bug" PRIORITY=3

# Add labels to existing
skill: linear-issue
args: update ID=TA-123 ADD_LABEL_IDS=label1,label2

# Replace all labels
skill: linear-issue
args: update ID=TA-123 LABEL_IDS=label1,label2,label3

# Unassign
skill: linear-issue
args: update ID=TA-123 ASSIGNEE_ID=null
```

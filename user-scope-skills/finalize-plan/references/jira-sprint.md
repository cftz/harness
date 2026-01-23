# Jira Sprint Assignment

Add issue to active sprint if one exists.

## Prerequisites

Load required MCP tools:

```
ToolSearch: select:mcp__jira__jira_get_agile_boards
ToolSearch: select:mcp__jira__jira_get_sprints_from_board
```

## Input

- `ISSUE_ID` - Jira issue key (e.g., PROJ-123)
- `PROJECT_KEY` - Project key extracted from ISSUE_ID

## Process

### 1. Get Agile Boards for Project

Query for agile boards associated with the project:

```
mcp__jira__jira_get_agile_boards(project_key="{PROJECT_KEY}")
```

If no boards found, skip sprint assignment (this is not an error - project may not use sprints).

### 2. Get Active Sprint from Board

For the first board found, get active sprints:

```
mcp__jira__jira_get_sprints_from_board(board_id="{board_id}", state="active")
```

If no active sprint found, skip sprint assignment.

### 3. Add Issue to Sprint

Use Jira Agile REST API to add issue to sprint:

```bash
curl -s -X POST "${JIRA_URL}/rest/agile/1.0/sprint/{sprint_id}/issue" \
  -H "Authorization: Basic $(echo -n ${JIRA_EMAIL}:${JIRA_API_TOKEN} | base64)" \
  -H "Content-Type: application/json" \
  -d '{"issues": ["{ISSUE_ID}"]}'
```

Or if MCP tool available:
```
mcp__jira__jira_move_issues_to_sprint(sprint_id="{sprint_id}", issue_keys=["{ISSUE_ID}"])
```

## Example

```
Input:
  ISSUE_ID: PROJ-123
  PROJECT_KEY: PROJ

Step 1 - Get agile boards:
  mcp__jira__jira_get_agile_boards(project_key="PROJ")

  Response:
    [{ "id": 42, "name": "PROJ board", "type": "scrum" }]

Step 2 - Get active sprint:
  mcp__jira__jira_get_sprints_from_board(board_id=42, state="active")

  Response:
    [{ "id": 100, "name": "Sprint 5", "state": "active" }]

Step 3 - Add to sprint:
  POST /rest/agile/1.0/sprint/100/issue
  Body: {"issues": ["PROJ-123"]}

Result:
  Issue PROJ-123 added to Sprint 5
```

## Output

This step does not return a separate output. Log the result:

- If sprint assigned: Log "Added to sprint: {sprint_name}"
- If no active sprint: Log "No active sprint found, skipping" (not an error)
- If no agile board: Log "No agile board found, skipping" (not an error)

## Error Handling

- If board lookup fails with API error: Return error
- If sprint lookup fails with API error: Return error
- If adding to sprint fails: Return error
- If no board exists: Skip silently (not an error)
- If no active sprint exists: Skip silently (not an error)

## Notes

- Only the first agile board is used if multiple boards exist for the project
- Only Scrum boards with active sprints are relevant; Kanban boards don't have sprints

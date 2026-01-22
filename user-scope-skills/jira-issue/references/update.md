# `update` Command

Update an existing Jira issue.

## Parameters

### Required

- `ID` - Issue key (e.g., `PROJ-123`)

### Optional (at least one required)

- `STATE` - Transition to this status name (e.g., "In Progress", "Done")
- `ASSIGNEE` - Assignee account ID (not email)
- `SUMMARY` - New issue title
- `DESCRIPTION` - New issue description

## Usage

```bash
# Update status
skill: jira-issue
args: update ID=PROJ-123 STATE="In Progress"

# Update assignee
skill: jira-issue
args: update ID=PROJ-123 ASSIGNEE=5c74dcae24a84d130780201b

# Update multiple fields
skill: jira-issue
args: update ID=PROJ-123 SUMMARY="New title" DESCRIPTION="New description"
```

## Process

### Step 1: Handle State Transition (if STATE provided)

1. Get available transitions:
   ```bash
   {baseDir}/scripts/get_transitions.sh "PROJ-123"
   ```

2. Find transition matching the target state name

3. Execute transition:
   ```bash
   {baseDir}/scripts/transition_issue.sh "PROJ-123" "{transition_id}"
   ```

### Step 2: Update Fields (if any field provided)

Run `{baseDir}/scripts/update_issue.sh` with parameters:

```bash
{baseDir}/scripts/update_issue.sh "PROJ-123" '{
  "summary": "New title",
  "description": "New description",
  "assignee": {"accountId": "xxx"}
}'
```

### Step 3: Return Result

Return the updated issue:

```json
{
  "key": "PROJ-123",
  "summary": "New title",
  "status": "In Progress"
}
```

## Environment Variables

- `JIRA_API_TOKEN` - Required for API authentication
- `JIRA_EMAIL` - Required for API authentication
- `JIRA_URL` - Jira instance URL

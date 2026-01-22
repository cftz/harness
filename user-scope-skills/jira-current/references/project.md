# `project` Command

Get current project using read-through cache pattern.

## Usage

```bash
skill: jira:jira-current
args: project
```

## Output

```json
{"id": "10001", "key": "PROJ", "name": "Project Name"}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh project`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch Project List

Use the Jira MCP tool to get available projects:

```
mcp__jira__jira_get_all_projects()
```

Parse response to extract project list with id, key, and name.

### Step 3: Ask User

Use `AskUserQuestion` tool:

```json
{
  "questions": [{
    "question": "Which Jira project should be set as current?",
    "header": "Project",
    "options": [
      {"label": "{project1_name} ({project1_key})", "description": "ID: {project1_id}"},
      {"label": "{project2_name} ({project2_key})", "description": "ID: {project2_id}"}
    ],
    "multiSelect": false
  }]
}
```

### Step 4: Save to Cache

Execute `{baseDir}/scripts/write_cache.sh project '{"id":"<selected_id>","key":"<selected_key>","name":"<selected_name>"}'`

### Step 5: Return Result

Return the selected project as JSON:

```json
{"id": "10001", "key": "PROJ", "name": "Selected Project"}
```

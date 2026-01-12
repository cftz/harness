# `project` Command

Get current project using read-through cache pattern.

## Usage

```bash
skill: linear-current
args: project
```

## Output

```json
{"id": "project-uuid", "name": "C-Ops"}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh project`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch Project List

Use `skill: linear-project` with `args: list` to get available projects.

Parse response to extract project list with id and name.

### Step 3: Ask User

Use `AskUserQuestion` tool:

```json
{
  "questions": [{
    "question": "Which project should be set as current?",
    "header": "Project",
    "options": [
      {"label": "{project1_name}", "description": "ID: {project1_id}"},
      {"label": "{project2_name}", "description": "ID: {project2_id}"}
    ],
    "multiSelect": false
  }]
}
```

### Step 4: Save to Cache

Execute `{baseDir}/scripts/write_cache.sh project '{"id":"<selected_id>","name":"<selected_name>"}'`

### Step 5: Return Result

Return the selected project as JSON:

```json
{"id": "selected-id", "name": "Selected Project"}
```

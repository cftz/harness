# `team` Command

Get current team using read-through cache pattern.

## Usage

```bash
skill: linear-current
args: team
```

## Output

```json
{"id": "team-uuid", "name": "Team Attention"}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh team`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch Team List

Use `skill: linear-team` with `args: list` to get available teams.

Parse response to extract team list with id, key, and name.

### Step 3: Ask User

Use `AskUserQuestion` tool:

```json
{
  "questions": [{
    "question": "Which team should be set as current?",
    "header": "Team",
    "options": [
      {"label": "{team1_name}", "description": "Key: {team1_key}"},
      {"label": "{team2_name}", "description": "Key: {team2_key}"}
    ],
    "multiSelect": false
  }]
}
```

### Step 4: Save to Cache

Execute `{baseDir}/scripts/write_cache.sh team '{"id":"<selected_id>","name":"<selected_name>"}'`

### Step 5: Return Result

Return the selected team as JSON:

```json
{"id": "selected-id", "name": "Selected Team"}
```

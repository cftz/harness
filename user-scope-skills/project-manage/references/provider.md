# `provider` Command

Get the current PMS provider (linear or jira) using read-through cache pattern.

## Usage

```bash
skill: project-manage
args: provider

# With explicit PROVIDER (sets and returns)
skill: project-manage
args: provider PROVIDER=jira
```

## Parameters

### Optional

- `PROVIDER` - If provided, cache this value and return it

## Output

Returns a string: `"linear"` or `"jira"`

## Process

### Step 1: Check PROVIDER Parameter

If `PROVIDER` parameter is provided:
- Save to cache: `{baseDir}/scripts/write_cache.sh provider '"jira"'`
- Return the provided value immediately

### Step 2: Check Cache

Execute `{baseDir}/scripts/read_cache.sh provider`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 3

### Step 3: Prompt User

If no provider is cached, ask the user:

```json
{
  "questions": [{
    "question": "Which project management system do you use?",
    "header": "PMS",
    "options": [
      {"label": "Linear", "description": "Linear issue tracker"},
      {"label": "Jira", "description": "Atlassian Jira"}
    ],
    "multiSelect": false
  }]
}
```

Save selection to cache and return.

## Notes

- This command is primarily used by other skills to auto-resolve PROVIDER
- Returns a plain string, not a JSON object
- If PROVIDER param provided, it's cached for future calls without the param

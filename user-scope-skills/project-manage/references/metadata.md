# `metadata` Command

Get project metadata (issue types, labels, components) using read-through cache pattern.

## Usage

```bash
skill: project-manage
args: metadata
```

## Output

```json
{
  "issueTypes": [
    {"id": "10001", "name": "Task"},
    {"id": "10002", "name": "Bug"},
    {"id": "10003", "name": "Story"}
  ],
  "labels": ["frontend", "backend", "urgent"],
  "components": [
    {"id": "10001", "name": "API"},
    {"id": "10002", "name": "Web"}
  ]
}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh metadata`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Ensure Project is Selected

Execute `{baseDir}/scripts/read_cache.sh project`:

- If result is `null`: Run project command first
  ```
  skill: project-manage
  args: project
  ```

Get the project key/id for metadata fetching.

### Step 3: Check Provider

Execute `{baseDir}/scripts/read_cache.sh provider`:

- If result is `null`: Return error "Provider not configured. Run /project-manage init first"

### Step 4: Fetch Metadata from Provider

Based on the provider value:

**If Linear:**

1. Get labels:
   ```
   skill: linear:linear-issue-label
   args: list
   ```

2. Issue types in Linear are simpler (Issue, Project, etc.) - typically not configurable per project

3. No components concept in Linear

**If Jira:**

1. Get issue types for project:
   ```
   mcp__jira__jira_search_fields()
   ```
   Filter for `issuetype` field to get available types.

2. Get labels from existing issues:
   ```
   mcp__jira__jira_search(
     jql="project = {project_key}",
     fields="labels",
     limit=50
   )
   ```
   Extract unique labels from results.

3. Get project details with components (may need additional API call)

### Step 5: Normalize and Cache

Normalize the metadata to common format:

```json
{
  "issueTypes": [{"id": "...", "name": "..."}],
  "labels": ["label1", "label2"],
  "components": [{"id": "...", "name": "..."}]
}
```

For Linear, `components` will be empty array.

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh metadata '{...}'
```

### Step 6: Return Result

Return the normalized metadata:

```json
{
  "issueTypes": [
    {"id": "10001", "name": "Task"},
    {"id": "10002", "name": "Bug"}
  ],
  "labels": ["frontend", "backend"],
  "components": [
    {"id": "10001", "name": "API"}
  ]
}
```

## Notes

- Metadata is project-specific
- This data is primarily useful for issue creation and filtering
- Labels may be incomplete if fetched from existing issues only

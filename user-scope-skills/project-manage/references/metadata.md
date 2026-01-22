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
    {"id": "10001", "name": "Task", "subtask": false},
    {"id": "10002", "name": "Bug", "subtask": false},
    {"id": "10003", "name": "Sub-task", "subtask": true}
  ],
  "labels": ["frontend", "backend", "urgent"],
  "components": [
    {"id": "10001", "name": "API"},
    {"id": "10002", "name": "Web"}
  ],
  "defaultComponent": "API"
}
```

Note: `issueTypes[].subtask` and `defaultComponent` are Jira-specific fields.

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

Based on the provider value, follow the respective provider documentation:

**If Linear:** See `{baseDir}/references/linear-provider.md` - Metadata section
- Labels: from `linear:linear-issue-label list`
- Issue types: empty array (Linear doesn't have per-project issue types)
- Components: empty array (Linear doesn't have components)

**If Jira:** See `{baseDir}/references/jira-provider.md` - Metadata section
- Issue types: from `getVisibleJiraProjects(expandIssueTypes=true)`
- Components: from `getJiraIssueTypeMetaWithFields()`
- Labels: from searching existing issues

### Step 5: Normalize and Cache

Normalize the metadata to common format:

```json
{
  "issueTypes": [
    {"id": "...", "name": "...", "subtask": false},
    {"id": "...", "name": "...", "subtask": true}
  ],
  "labels": ["label1", "label2"],
  "components": [{"id": "...", "name": "..."}],
  "defaultComponent": "Component Name"
}
```

**Field details:**
- `issueTypes[].subtask`: `true` for sub-task types (Jira only), used when creating sub-issues
- `defaultComponent`: Selected default component name (Jira only, from init step)
- For Linear, `components` will be empty array and `defaultComponent` will be `null`

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh metadata '{...}'
```

### Step 6: Return Result

Return the normalized metadata:

**For Jira:**
```json
{
  "issueTypes": [
    {"id": "10001", "name": "기타", "subtask": false},
    {"id": "10002", "name": "하위 작업", "subtask": true}
  ],
  "labels": ["frontend", "backend"],
  "components": [
    {"id": "10001", "name": "합성 패널"}
  ],
  "defaultComponent": "합성 패널"
}
```

**For Linear:**
```json
{
  "issueTypes": [],
  "labels": ["feature", "bug", "enhancement"],
  "components": [],
  "defaultComponent": null
}
```

## Notes

- Metadata is project-specific
- This data is primarily useful for issue creation and filtering
- Labels may be incomplete if fetched from existing issues only

# Linear Init

Initialize Linear as the PMS provider. This document is self-contained with all steps needed for Linear initialization.

## Skills Used

| Skill | Purpose |
|-------|---------|
| `linear:linear-project` | List projects |
| `linear:linear-issue-label` | List labels |

## Scripts Used

| Script | Purpose |
|--------|---------|
| `{baseDir}/scripts/linear_get_viewer.sh` | Get current user (viewer) |

## Process

### Step 1: Get User

Run the get_viewer script:

```bash
{baseDir}/scripts/linear_get_viewer.sh
```

Returns:
```json
{
  "id": "user-uuid",
  "name": "User Name",
  "email": "user@example.com"
}
```

Already normalized. Cache as-is:
```bash
{baseDir}/scripts/write_cache.sh user '{"id":"user-uuid","name":"User Name","email":"user@example.com"}'
```

### Step 2: Get Projects

```
skill: linear:linear-project
args: list
```

Returns list of projects.

**If multiple projects:**
- Use AskUserQuestion to let user select

**Normalize and cache:**
```bash
{baseDir}/scripts/write_cache.sh project '{"id":"project-uuid","key":"Project Name","name":"Project Name"}'
```

Note: Linear doesn't have project keys, so we use name for both `key` and `name`.

### Step 3: Get Labels (Metadata)

```
skill: linear:linear-issue-label
args: list
```

Returns labels for the team.

**Cache metadata:**
```bash
{baseDir}/scripts/write_cache.sh metadata '{"issueTypes":[],"labels":["feature","bug","enhancement"],"components":[],"defaultComponent":null}'
```

Note: Linear doesn't have configurable issue types or components per project.

### Step 4: Return Complete Context

```json
{
  "provider": "linear",
  "project": {"id": "project-uuid", "key": "Project Name", "name": "Project Name"},
  "user": {"id": "user-uuid", "name": "User Name", "email": "user@example.com"},
  "defaultComponent": null
}
```

## Differences from Jira

| Feature | Linear | Jira |
|---------|--------|------|
| Issue Types | None (just issues) | Configurable per project |
| Components | None | Per project |
| Default Component | N/A (always null) | Selectable |
| Project Key | Uses name | Separate key field |
| Sub-tasks | Parent-child via PARENT param | Specific sub-task issue types |

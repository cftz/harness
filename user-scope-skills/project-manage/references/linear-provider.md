# Linear Provider

This document defines how project-manage interacts with Linear using linear:* skills.

## Skills Used

| Skill | Purpose |
|-------|---------|
| `linear:linear-project` | List projects |
| `linear:linear-issue-label` | List labels |
| `linear:linear-issue` | Create/update issues |

## Scripts

| Script | Purpose |
|--------|---------|
| `{baseDir}/scripts/linear_get_viewer.sh` | Get current user (viewer) |

## User

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

Already normalized - use as-is.

## Project

```
skill: linear:linear-project
args: list
```

Returns list of projects. If multiple:
- Use AskUserQuestion to let user select
- Cache selected project

**Normalize to:**
```json
{
  "id": "project-uuid",
  "key": "Project Name",
  "name": "Project Name"
}
```

Note: Linear doesn't have project keys, so we use name for both key and name.

## Metadata

### Issue Types

Linear doesn't have configurable issue types per project. Return empty array:

```json
{
  "issueTypes": []
}
```

### Components

Linear doesn't have a components concept. Return empty array:

```json
{
  "components": [],
  "defaultComponent": null
}
```

### Labels

```
skill: linear:linear-issue-label
args: list
```

Returns labels for the team.

## Issue Creation

Use `linear:linear-issue` skill:

```
skill: linear:linear-issue
args: create TITLE="..." DESCRIPTION="..." ASSIGNEE=me LABELS="label1,label2"
```

## Full Init Flow

1. **Get User**
   ```bash
   {baseDir}/scripts/linear_get_viewer.sh
   ```
   - Cache user

2. **Get Projects**
   ```
   skill: linear:linear-project
   args: list
   ```
   - If multiple: AskUserQuestion
   - Cache project

3. **Get Labels**
   ```
   skill: linear:linear-issue-label
   args: list
   ```
   - Cache in metadata

4. **Return Complete Context**
   ```json
   {
     "provider": "linear",
     "project": {"id": "uuid", "key": "Project Name", "name": "Project Name"},
     "user": {"id": "uuid", "name": "User Name", "email": "user@example.com"},
     "defaultComponent": null
   }
   ```

## Differences from Jira

| Feature | Linear | Jira |
|---------|--------|------|
| Issue Types | None (just issues) | Configurable per project |
| Components | None | Per project |
| Default Component | N/A | Selectable |
| Project Key | Uses name | Separate key field |
| Sub-tasks | Parent-child via PARENT param | Specific sub-task issue types |

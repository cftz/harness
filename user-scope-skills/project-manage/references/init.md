# `init` Command

Initialize PMS selection and project context. This command runs through the full setup flow.

## Usage

```bash
skill: project-manage
args: init
```

## Output

```json
{
  "provider": "jira",
  "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
  "user": {"id": "xxx", "name": "User Name", "email": "user@example.com"}
}
```

## Process

### Step 1: Check Cache for Provider

Execute `{baseDir}/scripts/read_cache.sh provider`:

- If result is not `null`: Use cached provider, skip to Step 3
- If result is `null`: Continue to Step 2

### Step 2: Ask User to Select PMS

Use `AskUserQuestion` tool:

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

Save selection:
```bash
{baseDir}/scripts/write_cache.sh provider '"linear"'
# or
{baseDir}/scripts/write_cache.sh provider '"jira"'
```

### Step 3: Get Project from Provider-Specific Skill

Based on the provider value:

**If Linear:**
```
skill: linear:linear-current
args: project
```

**If Jira:**
```
skill: jira:jira-current
args: project
```

Normalize the returned project data:

| Field  | Linear Source | Jira Source |
| ------ | ------------- | ----------- |
| `id`   | `id`          | `id`        |
| `key`  | `name`        | `key`       |
| `name` | `name`        | `name`      |

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh project '{"id":"...","key":"...","name":"..."}'
```

### Step 4: Get User from Provider-Specific Skill

Based on the provider value:

**If Linear:**
```
skill: linear:linear-current
args: user
```

**If Jira:**
```
skill: jira:jira-current
args: user
```

Normalize the returned user data:

| Field   | Linear Source | Jira Source      |
| ------- | ------------- | ---------------- |
| `id`    | `id`          | `accountId`      |
| `name`  | `name`        | `displayName`    |
| `email` | `email`       | `emailAddress`   |

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh user '{"id":"...","name":"...","email":"..."}'
```

### Step 5: Fetch Metadata (Optional)

Fetch and cache project metadata if available. See `{baseDir}/references/metadata.md`.

### Step 6: Return Result

Return the complete context:

```json
{
  "provider": "jira",
  "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
  "user": {"id": "xxx", "name": "User Name", "email": "user@example.com"}
}
```

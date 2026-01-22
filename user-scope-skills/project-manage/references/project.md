# `project` Command

Get the current project info using read-through cache pattern.

## Usage

```bash
skill: project-manage
args: project

# With explicit PROVIDER
skill: project-manage
args: project PROVIDER=jira
```

## Parameters

### Optional

- `PROVIDER` - If provided, use and cache this provider (`linear` or `jira`)

## Output

```json
{"id": "10001", "key": "PROJ", "name": "Project Name"}
```

## Process

### Step 0: Resolve Provider

1. If `PROVIDER` parameter is provided:
   - Save to cache: `{baseDir}/scripts/write_cache.sh provider '"jira"'`
   - Use this provider for subsequent steps

2. If `PROVIDER` parameter is NOT provided:
   - Execute `{baseDir}/scripts/read_cache.sh provider`
   - If result is `null`: Run init flow (which will prompt user)
     ```
     skill: project-manage
     args: init
     ```
   - Use cached/resolved provider

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh project`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch from Provider

Based on the resolved provider value:

**If Linear:**

```
skill: linear:linear-project
args: list
```

Returns list of projects. If multiple projects, use AskUserQuestion to let user select.

**If Jira:**

First, get cloudId from cache or `mcp__jira2__getAccessibleAtlassianResources()`.

Then:
```
mcp__jira2__getVisibleJiraProjects(cloudId, expandIssueTypes=true)
```

Returns list of projects. If multiple projects, use AskUserQuestion to let user select.

### Step 3: Normalize and Cache

Normalize the returned data according to the provider:

| Field  | Linear Source | Jira Source |
| ------ | ------------- | ----------- |
| `id`   | `id`          | `id`        |
| `key`  | `name`        | `key`       |
| `name` | `name`        | `name`      |

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh project '{"id":"...","key":"...","name":"..."}'
```

### Step 4: Return Result

Return the normalized project:

```json
{"id": "10001", "key": "PROJ", "name": "Project Name"}
```

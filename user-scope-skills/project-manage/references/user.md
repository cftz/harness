# `user` Command

Get the current user info using read-through cache pattern.

## Usage

```bash
skill: project-manage
args: user

# With explicit PROVIDER
skill: project-manage
args: user PROVIDER=jira
```

## Parameters

### Optional

- `PROVIDER` - If provided, use and cache this provider (`linear` or `jira`)

## Output

```json
{"id": "xxx", "name": "User Name", "email": "user@example.com"}
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

Execute `{baseDir}/scripts/read_cache.sh user`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch from Provider

Based on the resolved provider value, follow the respective provider documentation:

**If Linear:** See `{baseDir}/references/linear-provider.md` - User section
**If Jira:** See `{baseDir}/references/jira-provider.md` - User section

### Step 3: Normalize and Cache

Normalize the returned data according to the provider:

| Field   | Linear Source | Jira Source      |
| ------- | ------------- | ---------------- |
| `id`    | `id`          | `accountId`      |
| `name`  | `name`        | `displayName`    |
| `email` | `email`       | `emailAddress`   |

Save to cache:
```bash
{baseDir}/scripts/write_cache.sh user '{"id":"...","name":"...","email":"..."}'
```

### Step 4: Return Result

Return the normalized user:

```json
{"id": "xxx", "name": "User Name", "email": "user@example.com"}
```

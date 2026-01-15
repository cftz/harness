# `user` Command

Get current user (viewer) using read-through cache pattern.

Unlike `project` and `team`, this command does not prompt the user. It fetches the currently authenticated user from Linear API.

## Usage

```bash
skill: linear-current
args: user
```

## Output

```json
{"id": "user-uuid", "name": "John Doe", "email": "john@example.com"}
```

## Process

### Step 1: Check Cache

Execute `{baseDir}/scripts/read_cache.sh user`:

- If result is not `null`: Return the cached value and stop
- If result is `null`: Continue to Step 2

### Step 2: Fetch Viewer from API

Execute `{baseDir}/scripts/get_viewer.sh` to get current authenticated user.

Output will be:
```json
{"id": "user-uuid", "name": "John Doe", "email": "john@example.com"}
```

### Step 3: Save to Cache

Execute `{baseDir}/scripts/write_cache.sh user '<viewer_json>'`

### Step 4: Return Result

Return the viewer as JSON:

```json
{"id": "user-uuid", "name": "John Doe", "email": "john@example.com"}
```

## Environment Variables

- `LINEAR_API_KEY` - Required for GraphQL API authentication

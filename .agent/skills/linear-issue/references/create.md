# `create` Command

Creates a Linear issue with smart defaults, caching, and relationship support.

This is the "smart" issue creation command that:
- Uses cached team/project defaults
- Prompts user to select team/project if not cached
- Supports blocking relationships via `BLOCKED_BY`
- Validates parent and blocking issues before creation

## Parameters

### Required

- `TITLE` - Issue title

### Optional

- `DESCRIPTION` - Issue description in Markdown format
- `PARENT` - Parent issue ID or identifier (e.g., `TA-123`) to create as sub-issue
- `BLOCKED_BY` - Comma-separated issue IDs that block this issue (e.g., `TA-100,TA-101`)
- `TEAM` - Team name or ID (overrides cache)
- `PROJECT` - Project name or ID (overrides cache)
- `ASSIGNEE` - User to assign (ID, name, email, or "me")
- `LABELS` - Comma-separated label names to apply
- `NO_CACHE` - If `true`, do not use or update cache

## Usage Examples

```bash
# Simple issue with cached defaults
skill: linear-issue
args: create TITLE="Fix login button alignment"

# Issue with description
skill: linear-issue
args: create TITLE="Add user profile page" DESCRIPTION="Create a new profile page with avatar, bio, and settings sections."

# Sub-issue under a parent
skill: linear-issue
args: create TITLE="Implement avatar upload" PARENT=TA-456

# Issue blocked by others
skill: linear-issue
args: create TITLE="Deploy to production" BLOCKED_BY="TA-100,TA-101"

# Override cached team/project
skill: linear-issue
args: create TITLE="New feature" TEAM="Backend" PROJECT="API Improvements"

# Full example with all options
skill: linear-issue
args: create TITLE="Add pagination" DESCRIPTION="Implement cursor-based pagination" PARENT=TA-200 BLOCKED_BY="TA-150" ASSIGNEE=me LABELS="enhancement,backend"
```

## Process

### Step 1: Resolve Team

**Priority order:**
1. Use `TEAM` parameter if provided -> Resolve name to ID via `linear-team list`
2. Use `linear-current team` to get cached/selected team (read-through)

```bash
skill: linear-current
args: team
```

Returns: `{"id": "team-uuid", "name": "Team Name"}`

### Step 2: Resolve Project

**Priority order:**
1. Use `PROJECT` parameter if provided -> Resolve name to ID via `linear-project list`
2. Use `linear-current project` to get cached/selected project (read-through)

```bash
skill: linear-current
args: project
```

Returns: `{"id": "project-uuid", "name": "Project Name"}`

### Step 3: Validate Relationships

If `PARENT` is provided:
1. Use `skill: linear-issue` with `args: get ID=<parent-id>`
2. If not found, report error and exit

If `BLOCKED_BY` is provided:
1. Split comma-separated IDs
2. For each ID, use `skill: linear-issue` with `args: get ID=<id>`
3. If any not found, report which IDs are invalid and exit

### Step 4: Create Issue

Run `{baseDir}/scripts/create_issue.sh` with positional arguments:
1. `TITLE` - Issue title
2. `TEAM_ID` - Resolved team ID
3. `DESCRIPTION` - Description (if provided, else empty string)
4. `PROJECT_ID` - Resolved project ID (if provided, else empty string)
5. `ASSIGNEE_ID` - Assignee user ID (if provided, else empty string)
6. `LABEL_IDS` - Comma-separated label IDs (if provided, else empty string)
7. `PARENT_ID` - Parent issue ID (if provided, else empty string)
8. `PRIORITY` - Priority (if provided, else empty string)
9. `STATE_ID` - State ID (if provided, else empty string)

Note: For `BLOCKED_BY`, use the Linear API's relation feature after issue creation (not yet implemented in script).

### Step 5: Report Result

Display created issue information:

```
Issue created successfully.

- Issue: {identifier} (e.g., TA-789)
- Title: {title}
- Team: {team name}
- Project: {project name}
- Parent: {parent ID or "None"}
- Blocked By: {list of blocking issue IDs or "None"}
- URL: {issue URL}
```

## Environment Variables

- `LINEAR_API_KEY` - Required for GraphQL API authentication

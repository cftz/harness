---
name: finalize-clarify
description: |
  Use this skill to finalize clarified requirements by converting approved temporary task files to final outputs (Artifact files or issue tracker issues).

  IMPORTANT: Only call this skill after user approval of draft-clarify outputs. This is Phase B of the clarify workflow.

  Args:
    DRAFT_PATHS=<paths> (Required) - Comma-separated list of temporary file paths
    Output (OneOf, Required):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      PROJECT_ID=<id> - Create issues in project (requires PROVIDER)
    Options:
      PROVIDER=linear|jira - Issue tracker provider (default: linear)
      ASSIGNEE=<id|name|email|me> - Issue assignee (Linear: "me" supported, Jira: email or account ID only)
      PARENT_ISSUE_ID=<id> - Create as sub-issues under this parent

  Examples:
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1,.agent/tmp/20260110-task2 ARTIFACT_DIR_PATH=.agent/artifacts/20260110
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops PROVIDER=jira
    /finalize-clarify DRAFT_PATHS=.agent/tmp/20260110-task1 PROJECT_ID=cops PARENT_ISSUE_ID=TA-123 ASSIGNEE=me
model: claude-sonnet-4-5
context: fork
agent: step-by-step-agent
---

# Description

Converts approved temporary task files from draft-clarify to final outputs. This is Phase B of the clarify workflow, called only after user approval.

Supports two output destinations:
- **Artifact Directory**: Creates numbered artifact files and copies content
- **Issue Tracker**: Creates issues with proper dependency relationships (Linear or Jira)

## Parameters

### Required

- `DRAFT_PATHS` - Comma-separated list of temporary file paths from draft-clarify (e.g., `.agent/tmp/20260110-task1,.agent/tmp/20260110-task2`)

### Output Destination (OneOf, Required)

Provide exactly one:

- `ARTIFACT_DIR_PATH` - Artifact directory path to save the final outputs
- `PROJECT_ID` - Project ID or name to create issues in (requires PROVIDER for issue tracker)

### Optional

- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`. Only used with PROJECT_ID.
- `ASSIGNEE` - User to assign issues to. For Linear: ID, name, email, or "me". For Jira: account ID only (email matching is unreliable).
- `PARENT_ISSUE_ID` - Parent issue ID to create as sub-issues under (e.g., `PROJ-123`)

## Process

### If ARTIFACT_DIR_PATH is provided

Follow `{baseDir}/references/artifact-output.md`

### If PROJECT_ID is provided

#### Step 1: Resolve Defaults

1. **Resolve PROVIDER**:
   - If `PROVIDER` parameter is explicitly provided, use it
   - If not provided, get from project-manage:
     ```
     skill: project-manage
     args: provider
     ```
     Use the returned provider value (or `linear` if project-manage not initialized)

2. **Resolve ASSIGNEE** (if not provided):
   ```
   skill: project-manage
   args: user PROVIDER=<provider>
   ```
   Use the returned `user.id` for issue assignment (Jira: accountId, Linear: UUID).

   **IMPORTANT**: Always use the `id` field, NOT email. Email matching is unreliable.

#### Step 2: Parse Draft Files

1. Split `DRAFT_PATHS` by comma
2. Read each file and extract YAML frontmatter:
   - `name` - Task name (used for dependency references)
   - `title` - Issue title (falls back to `name` if not present)
   - `description` - Issue description (content after frontmatter)
   - `blockedBy` - List of task names this depends on

3. Build a task map: `{task_name -> task_data}`

**Draft File Format:**

```yaml
---
name: task-name
blockedBy:
  - prerequisite-task-name
---

# Task Summary

[Task description in Markdown format...]

# Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

#### Step 3: Determine Creation Order

Build a dependency graph and sort tasks topologically:
1. Tasks with no dependencies (`blockedBy: []`) are created first
2. Tasks are created only after all their dependencies

#### Step 3.5: Get Metadata (Jira Only)

For Jira provider, fetch metadata to get issue types and components:

```
skill: project-manage
args: metadata PROVIDER=<provider>
```

Returns:
- `issueTypes`: Available issue types (with `subtask` flag)
- `components`: Available components
- `defaultComponent`: Pre-selected default component

This data is passed to the provider-specific reference for correct issue creation.

#### Step 4: Create Issues (Provider-Specific)

Route to provider-specific reference with prepared data:

| PROVIDER           | Reference Document                      |
| ------------------ | --------------------------------------- |
| `linear` (default) | `{baseDir}/references/linear-output.md` |
| `jira`             | `{baseDir}/references/jira-output.md`   |

**Data passed to reference:**
- `PROJECT_ID` - Target project
- `TASK_MAP` - Parsed task data (name, title, description, blockedBy)
- `CREATION_ORDER` - Topologically sorted task names
- `ASSIGNEE` - Resolved assignee (user ID, NOT email)
- `PARENT_ISSUE_ID` - Parent issue (optional)
- `METADATA` - (Jira only) Issue types, components, defaultComponent from Step 3.5

#### Step 5: Report Results

After provider-specific issue creation completes, report:
- List of created issues with their IDs
- Blocking relationships established
- Parent issue (if provided)

## Output

SUCCESS:
- For Artifact Output:
  - ARTIFACT_PATHS: List of created artifact file paths
- For Issue Tracker Output:
  - PROVIDER: The provider used (linear or jira)
  - ISSUE_IDS: Map of task names to created issue identifiers
  - BLOCKING_RELATIONS: List of blocking relationships created

ERROR: Error message string (e.g., "Draft file not found: {path}", "API error: {message}", "Unknown provider: {value}")

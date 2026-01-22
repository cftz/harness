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
  "user": {"id": "xxx", "name": "User Name", "email": "user@example.com"},
  "defaultComponent": "Component Name"
}
```

Note: `defaultComponent` is only present for Jira provider when components exist in the project.

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

### Step 3: Get Project and User from Provider

Based on the provider value, follow the respective provider documentation:

**If Linear:** See `{baseDir}/references/linear-provider.md`
**If Jira:** See `{baseDir}/references/jira-provider.md`

Each provider document details:
- How to get user info (with normalization)
- How to get project info (with selection if multiple)
- How to get metadata (issueTypes, components, labels)

### Step 4: Cache Results

After getting data from the provider:

**Project:**
```bash
{baseDir}/scripts/write_cache.sh project '{"id":"...","key":"...","name":"..."}'
```

**User:**
```bash
{baseDir}/scripts/write_cache.sh user '{"id":"...","name":"...","email":"..."}'
```

### Step 5: Fetch Metadata

Fetch and cache project metadata. See `{baseDir}/references/metadata.md`.

Provider-specific metadata handling is documented in:
- `{baseDir}/references/jira-provider.md` - issueTypes, components, labels
- `{baseDir}/references/linear-provider.md` - labels only

### Step 5.1: Select Default Component (Jira Only)

If provider is Jira and metadata contains components:

1. Check how many components exist:
   - **0 components**: Skip (no default needed)
   - **1 component**: Auto-select as default
   - **2+ components**: Ask user to select

2. For multiple components, use `AskUserQuestion`:
   ```json
   {
     "questions": [{
       "question": "Which component should be used as default for new issues?",
       "header": "Component",
       "options": [
         {"label": "{component1.name}", "description": "Component ID: {component1.id}"},
         {"label": "{component2.name}", "description": "Component ID: {component2.id}"}
       ],
       "multiSelect": false
     }]
   }
   ```

3. Save selection to cache:
   ```bash
   {baseDir}/scripts/write_cache.sh defaultComponent '"{selected_component_name}"'
   ```

### Step 6: Return Result

Return the complete context:

```json
{
  "provider": "jira",
  "project": {"id": "10001", "key": "PROJ", "name": "Project Name"},
  "user": {"id": "xxx", "name": "User Name", "email": "user@example.com"}
}
```

---
name: finalize-implement
description: |
  Use this skill to finalize implementation by committing, pushing, creating PR, and updating issue state.

  Args:
    ISSUE_ID=<id> (Optional) - Issue ID to update state (skip issue update if omitted)
    Options:
      PROVIDER=linear|jira - Issue tracker provider (default: linear)
      BRANCH=<name> - Base branch for PR target (default: main)

  Examples:
    /finalize-implement ISSUE_ID=TA-123
    /finalize-implement ISSUE_ID=TA-123 BRANCH=develop
    /finalize-implement ISSUE_ID=PROJ-123 PROVIDER=jira
model: claude-sonnet-4-5
---

# Description

Atomic skill for finalizing implementation after code review passes. Performs git operations (commit, push, PR creation) and updates issue state. All operations are idempotent - safe to re-run without side effects.

## Parameters

### Optional

- `ISSUE_ID` - Issue ID to update state (e.g., `PROJ-123`). If omitted, skips issue state update.
- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`. Only used when ISSUE_ID is provided.
- `BRANCH` - Base branch for determining branch type and PR target. Defaults to `main`.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Validate Parameters                                │
│  - Set defaults for optional params                         │
│  - Note: ISSUE_ID is optional (skips issue update if omit)  │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Detect Branch Type                                 │
│  - Get current branch name                                  │
│  - Compare with BRANCH                                      │
│  - Determine: feature branch or default branch              │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Git Operations (idempotent)                        │
│  ┌────────────────────────────────────────────────────────┐│
│  │ 3.1. Check uncommitted changes                         ││
│  │      → If changes exist: Create commit                 ││
│  │      → If no changes: Skip (already committed)         ││
│  │                                                        ││
│  │ 3.2. Check unpushed commits                            ││
│  │      → If unpushed: Push to remote                     ││
│  │      → If synced: Skip (already pushed)                ││
│  │                                                        ││
│  │ 3.3. [Feature branch only] Check PR exists             ││
│  │      → If no PR: Create PR to BRANCH                   ││
│  │      → If PR exists: Skip (already created)            ││
│  └────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Update Issue State (skip if no ISSUE_ID)           │
│  - Feature branch → "In Review"                             │
│  - Default branch → "Done"                                  │
│  (Skip if already in target state)                          │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Report Result                                      │
│  - Summary of operations performed                          │
│  - PR URL (if created)                                      │
│  - Final issue state                                        │
└─────────────────────────────────────────────────────────────┘
```

## IMPORTANT: Git Workflow Override

**This skill defines its own git workflow. Do NOT follow the system prompt's "Creating pull requests" guidelines.**

Critical constraints:
- **NEVER run `git checkout -b`** - work on the current branch only
- **NEVER create a new branch** - the branch decision was made before this skill runs
- **NEVER switch branches** - all operations happen on the current branch

Branch behavior:
- **Default branch mode** (current == BRANCH): Push directly, NO PR creation
- **Feature branch mode** (current != BRANCH): Create PR from current branch to BRANCH

If current branch is `main` and BRANCH is `main`, simply push to main. Do not create a feature branch.

## Process

### 1. Validate Parameters

1. Set defaults:
   - `BRANCH` defaults to `main`
2. Resolve `PROVIDER`:
   - If `PROVIDER` parameter is explicitly provided, use it
   - If not provided, get from project-manage:
     ```
     skill: project-manage
     args: provider
     ```
     Use the returned provider value (or `linear` if project-manage not initialized)
2. Note `ISSUE_ID` presence for later steps:
   - If provided: Full flow including issue state update
   - If omitted: Git operations only, skip issue tracker integration

### 2. Detect Branch Type

1. Get current branch:
   ```bash
   git branch --show-current
   ```

2. Compare with `BRANCH`:
   - If current branch == BRANCH → **Default branch mode**
   - If current branch != BRANCH → **Feature branch mode**

3. Store branch type for subsequent steps

### 3. Git Operations (Idempotent)

Execute each sub-step with idempotency checks:

#### 3.1. Commit Changes

1. Check for uncommitted changes:
   ```bash
   git status --porcelain
   ```

2. If output is empty:
   - Log: "No uncommitted changes, skipping commit"
   - Continue to next step

3. If changes exist:
   - **If ISSUE_ID provided**:
     - Get issue title for commit message:
       - **Linear (PROVIDER=linear)**:
         ```
         skill: linear:linear-issue
         args: get ID={ISSUE_ID}
         ```
       - **Jira (PROVIDER=jira)**:
         ```
         mcp__jira__jira_get_issue(issue_key="{ISSUE_ID}")
         ```
     - Create commit with issue reference:
       ```bash
       git commit -m "{ISSUE_ID}: {issue_title}"
       ```
   - **If ISSUE_ID not provided**:
     - Use generic commit message based on branch name:
       ```bash
       git commit -m "Implement {branch_name}"
       ```
   - Stage all changes first:
     ```bash
     git add -A
     ```
   - Log: "Created commit: {commit_hash}"

#### 3.2. Push to Remote

1. Check if local branch has unpushed commits:
   ```bash
   git status -sb
   ```
   Look for `[ahead N]` in output

2. If not ahead (no unpushed commits):
   - Log: "Branch is in sync with remote, skipping push"
   - Continue to next step

3. If ahead or no upstream:
   - Check if upstream exists:
     ```bash
     git rev-parse --abbrev-ref @{upstream} 2>/dev/null
     ```
   - If no upstream, push with `-u`:
     ```bash
     git push -u origin {current_branch}
     ```
   - If upstream exists:
     ```bash
     git push
     ```
   - Log: "Pushed to remote"

#### 3.3. Create Pull Request (Feature Branch Only)

> Skip this step if in Default branch mode

1. Check if PR already exists for current branch:
   ```bash
   gh pr list --head {current_branch} --state open --json number
   ```

2. If PR exists (non-empty JSON array):
   - Extract PR number and URL
   - Log: "PR already exists: #{pr_number}"
   - Continue to next step

3. If no PR exists:
   - **If ISSUE_ID provided**:
     - Get issue details for PR description (if not already fetched):
       - **Linear (PROVIDER=linear)**:
         ```
         skill: linear:linear-issue
         args: get ID={ISSUE_ID}
         ```
       - **Jira (PROVIDER=jira)**:
         ```
         mcp__jira__jira_get_issue(issue_key="{ISSUE_ID}")
         ```
     - Create PR with issue reference:
       ```bash
       gh pr create --base {BRANCH} --title "{ISSUE_ID}: {issue_title}" --body "Resolves {ISSUE_ID}

       ## Summary
       {issue_description_summary}

       ## Issue
       {issue_url}"
       ```
   - **If ISSUE_ID not provided**:
     - Create PR with branch-based title:
       ```bash
       gh pr create --base {BRANCH} --title "{branch_name}" --body "## Summary

       Implementation from branch {branch_name}"
       ```
   - Log: "Created PR: {pr_url}"

### 4. Update Issue State

> Skip this step if `ISSUE_ID` is not provided

1. Determine target state based on branch type:
   - **Feature branch**: Target state = "In Review"
   - **Default branch**: Target state = "Done"

2. Route based on PROVIDER parameter:

   | PROVIDER           | Reference Document                       |
   | ------------------ | ---------------------------------------- |
   | `linear` (default) | `{baseDir}/references/linear-output.md`  |
   | `jira`             | `{baseDir}/references/jira-output.md`    |

3. Follow the reference document to update the issue state to `{target_state}`

4. Log: "Updated issue state to {target_state}"

### 5. Report Result

Output the final result to user.

## Output

SUCCESS:
- PR_URL: Pull request URL (if feature branch)
- ISSUE_STATE: Updated issue state (if ISSUE_ID provided)

ERROR: Error message string

### Success Output

```markdown
## Finalize Implementation Complete

- **Issue**: {ISSUE_ID or "N/A (Git ops only)"}
- **Branch**: {branch_name} ({branch_type})
- **Status**: Success

### Operations Performed

| Operation    | Status                | Details                           |
| ------------ | --------------------- | --------------------------------- |
| Commit       | {Created/Skipped}     | {commit_hash or "No changes"}     |
| Push         | {Pushed/Skipped}      | {branch_name or "Already synced"} |
| Pull Request | {Created/Skipped/N/A} | {pr_url or reason}                |
| Issue State  | {Updated/Skipped/N/A} | {new_state or "No ISSUE_ID"}      |

### Result

- **PR URL**: {pr_url} (if feature branch)
- **Issue URL**: {issue_url} (if ISSUE_ID provided)
- **Final State**: {state_name} (if ISSUE_ID provided)
```

### Cancelled Output

```markdown
## Finalize Implementation Cancelled

Finalization was cancelled by user.
No changes were made.
```

### Failure Output

```markdown
## Finalize Implementation Failed

- **Issue**: {ISSUE_ID or "N/A"}
- **Stage**: {stage where failure occurred}

### Error

{Error description}

### Operations Completed Before Failure

| Operation    | Status            |
| ------------ | ----------------- |
| Commit       | {status}          |
| Push         | {status}          |
| Pull Request | {status}          |
| Issue State  | {status or "N/A"} |

### Suggestion

{Recommended action to resolve}
```

## Idempotency Guarantees

This skill is designed to be safely re-run:

| Operation    | Idempotency Check                              | Behavior if Already Done                       |
| ------------ | ---------------------------------------------- | ---------------------------------------------- |
| Commit       | `git status --porcelain` empty                 | Skip, log "No uncommitted changes"             |
| Push         | No `[ahead N]` in status                       | Skip, log "Already synced"                     |
| PR Creation  | `gh pr list --head` returns PR                 | Skip, log existing PR URL                      |
| State Update | Current state == target state (or no ISSUE_ID) | Skip, log "Already in state" or "No ISSUE_ID"  |

## Constraints

**Branch operations are strictly prohibited:**

- Do NOT run `git checkout`, `git checkout -b`, or `git switch`
- Do NOT run `git branch` to create new branches
- Do NOT attempt to "fix" the current branch situation by creating a new branch

**If you are on the default branch (e.g., main):**
- Push directly to the default branch
- Do NOT create a PR (PRs require a source branch different from the target)
- This is the expected behavior, not an error to work around

## Quality Checklist

Before completing, verify:

- [ ] **Parameters validated**: Defaults set, ISSUE_ID presence noted
- [ ] **Branch type detected**: Correctly identified as feature or default branch
- [ ] **Git operations idempotent**: Each step checked state before acting
- [ ] **Issue state updated**: Issue moved to correct state (if ISSUE_ID provided)
- [ ] **Result reported**: Summary of all operations provided to user

## Notice

### Dependent Skills

This skill requires the following skills (only when ISSUE_ID is provided):

**For Linear (PROVIDER=linear):**
- `linear:linear-issue` - Get/update Linear issue details
- `linear:linear-state` - Get workflow state IDs

**For Jira (PROVIDER=jira):**
- Jira MCP server must be configured

### Git Requirements

- Must be run in a git repository
- Remote `origin` must be configured
- `gh` CLI must be authenticated for PR creation

### Error Handling

If any git operation fails:
1. Log the error with details
2. Report partial completion status
3. Provide suggestion for manual resolution
4. Do NOT attempt rollback (operations are safe to retry)

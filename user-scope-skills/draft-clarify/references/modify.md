# `modify` Command

Revises existing draft task documents based on feedback.

## Parameters

### Drafts (Required)

- `DRAFT_PATHS` - Comma-separated paths to existing draft task documents to revise

### Feedback (OneOf, Required)

Provide one of the following:

- `FEEDBACK` - Feedback text directly (e.g., `FEEDBACK="Split auth into login and registration tasks"`)
- `FEEDBACK_PATH` - Path to a file containing feedback (e.g., review document)

### Optional

- `PROMPT_PATH` - Path to the original prompt file. When provided, use it as context to ensure modifications remain aligned with the original request.

## Process

### 1. Read Existing Drafts

Read all draft task documents from `DRAFT_PATHS`. For each draft, understand:
- Task name and dependencies
- Current acceptance criteria
- Scope definitions
- Constraints and context

### 1.5. Read Original Prompt (if provided)

If `PROMPT_PATH` is provided, read the original prompt file to understand:
- The original request that initiated this clarification
- Any context that should be preserved during modification

Use this as a reference to ensure modifications remain aligned with the user's original intent.

### 2. Read Feedback

- If `FEEDBACK` is provided -> Use the text directly
- If `FEEDBACK_PATH` is provided -> Read the file contents

Parse the feedback to identify:
- Specific tasks that need changes
- Requirements to add, modify, or remove
- Scope adjustments
- New tasks to create or tasks to merge
- Dependency changes

### 3. Identify Changes Needed

Map feedback items to specific actions:

| Feedback Type | Action |
|---------------|--------|
| Unclear acceptance criteria | Refine criteria to be more specific and testable |
| Missing scope boundaries | Add explicit in-scope/out-of-scope items |
| Task too large | Split into multiple smaller tasks |
| Tasks overlap | Merge or clarify boundaries |
| Missing dependencies | Add blockedBy relationships |
| Wrong abstraction level | Adjust to behavior-level (not implementation) |

### 4. Ask Clarifying Questions if Needed

If feedback is ambiguous or requires decisions:

1. Use `AskUserQuestion` to clarify intent
2. **MUST resolve all ambiguities** - do not leave "A or B" options
3. Document decisions in the "Questions Resolved" section

> **CRITICAL**: Continue to focus on **what** and **why**, not **how**. Do not introduce implementation details during revision.

### 5. Update Drafts

Apply revisions to address all feedback items following the Output Format defined in `{baseDir}/SKILL.md`:

- **Modify existing tasks**: Update sections as needed while preserving structure
- **Split tasks**: Create new draft files for split tasks, update dependencies
- **Merge tasks**: Consolidate into fewer files, remove redundant drafts
- **Add tasks**: Create new draft files with proper dependencies
- **Remove tasks**: Delete files if tasks are no longer needed

For each modified task:
- Maintain YAML frontmatter consistency
- Ensure acceptance criteria remain behavior-focused
- Update dependencies (blockedBy) if task structure changed
- Add new Q&A to "Questions Resolved" section

### 6. Write to Paths

- For modified tasks: Overwrite existing files at their original paths
- For new tasks: Use `mktemp` skill to create new files
- For removed tasks: Note which files should be deleted (do not delete automatically)

## Output

SUCCESS:
- DRAFT_PATHS: Comma-separated list of updated draft file paths
- REMOVED_PATHS: Comma-separated list of removed file paths (if any tasks were removed)

ERROR: Error message string

## Quality Verification

After revision, verify:

- [ ] All feedback items have been addressed
- [ ] No implementation details introduced
- [ ] Acceptance criteria remain behavior-focused and testable
- [ ] Task dependencies (blockedBy) are consistent
- [ ] No vague "A or B" options left unresolved
- [ ] Quality Checklist from `{baseDir}/SKILL.md` still passes for all drafts

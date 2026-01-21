# `modify` Command

Revises an existing draft execution plan based on feedback.

## Parameters

### Draft (Required)

- `DRAFT_PATH` - Path to the existing draft plan to revise

### Feedback (OneOf, Required)

Provide one of the following:

- `FEEDBACK` - Feedback text directly (e.g., `FEEDBACK="Add error handling for network failures"`)
- `FEEDBACK_PATH` - Path to a file containing feedback (e.g., review document)

## Process

### 1. Read Existing Draft

Read the draft plan from `DRAFT_PATH`. Understand:
- Current plan structure and content
- Existing decisions and rationale
- Implementation steps already defined

### 2. Read Feedback

- If `FEEDBACK` is provided -> Use the text directly
- If `FEEDBACK_PATH` is provided -> Read the file contents

Parse the feedback to identify:
- Specific sections that need changes
- New requirements or constraints
- Issues with current approach
- Missing details or considerations

### 3. Identify Sections Needing Revision

Map feedback items to specific plan sections:
- Overview changes
- Package changes (add/remove)
- Implementation step modifications
- New steps to add
- Steps to remove or restructure

### 4. Research if Needed

If feedback requires new information:

1. Use Context7 MCP to investigate packages or APIs
2. Explore codebase for patterns or constraints
3. Read relevant rules from `.agent/rules/`

If multiple approaches exist for addressing feedback:
- Use `AskUserQuestion` to get user selection
- **MUST select exactly one approach** - do not leave as "A or B"

### 5. Update Draft

Apply revisions to address all feedback items following the Output Format defined in `{baseDir}/SKILL.md`:
- Maintain existing structure where unchanged
- Update affected sections with new content
- Ensure consistency across the entire plan
- Verify all cross-references remain valid

### 6. Write to Same Path

Overwrite the existing draft at `DRAFT_PATH` with the revised content.

## Output

**On Success:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: {DRAFT_PATH}
```

**On Error:**
```
STATUS: ERROR
OUTPUT: {error message}
```

## Quality Verification

After revision, verify:

- [ ] All feedback items have been addressed
- [ ] No new "or" statements introduced
- [ ] Revised sections maintain consistency with unchanged sections
- [ ] Quality Checklist from `{baseDir}/SKILL.md` still passes

# `modify` Command

Revises an existing draft solution document based on feedback.

## Parameters

### Draft (Required)

- `DRAFT_PATH` - Path to the existing draft solution to revise

### Feedback (OneOf, Required)

Provide one of the following:

- `FEEDBACK` - Feedback text directly (e.g., `FEEDBACK="Explore more cross-domain approaches"`)
- `FEEDBACK_PATH` - Path to a file containing feedback

## Process

### 1. Read Existing Draft

Read the draft solution from `DRAFT_PATH`. Understand:
- Original problem and approach used
- Current ideas and recommendations
- Analysis path for context

### 2. Read Feedback

- If `FEEDBACK` is provided -> Use the text directly
- If `FEEDBACK_PATH` is provided -> Read the file contents

Parse the feedback to identify:
- Requests for more ideas in specific directions
- Ideas to expand or refine
- Ideas to deprioritize or remove
- New approaches to explore
- Specific aspects to research further

### 3. Identify Actions Needed

Map feedback items to specific actions:

| Feedback Type | Action |
|---------------|--------|
| "Explore more X" | Load appropriate reference, execute additional searches |
| "Expand idea Y" | Deep dive into that specific idea |
| "Consider alternative Z" | Research and add new idea |
| "Remove/deprioritize idea" | Update rankings and remove if appropriate |
| "More practical details" | Add implementation considerations |

### 4. Research if Needed

If feedback requires exploring new directions:

1. Load the appropriate approach reference document
2. Use `WebSearch` to investigate new angles
3. Find additional sources and examples

If feedback is ambiguous:
- Use `AskUserQuestion` to clarify intent
- Document the clarification in the solution

### 5. Update Draft

Apply revisions to address all feedback items following the Output Format defined in `{baseDir}/SKILL.md`:
- Add new ideas as requested
- Expand existing ideas with more detail
- Update rankings based on new information
- Maintain consistency with original analysis
- Preserve ideas that weren't flagged for change

### 6. Write to Same Path

Overwrite the existing draft at `DRAFT_PATH` with the revised content.

## Output

**If completed:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: {path to revised draft}
```

**If clarification needed:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

## Quality Verification

After revision, verify:

- [ ] All feedback items have been addressed
- [ ] New ideas have proper source attribution
- [ ] Rankings reflect the updated idea set
- [ ] Trade-offs are honestly assessed for new/modified ideas
- [ ] Quality Checklist from `{baseDir}/SKILL.md` still passes

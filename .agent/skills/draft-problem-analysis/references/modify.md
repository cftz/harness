# `modify` Command

Revises an existing draft problem analysis based on feedback.

## Parameters

### Draft (Required)

- `DRAFT_PATH` - Path to the existing draft analysis to revise

### Feedback (OneOf, Required)

Provide one of the following:

- `FEEDBACK` - Feedback text directly (e.g., `FEEDBACK="Focus on eventual consistency approaches"`)
- `FEEDBACK_PATH` - Path to a file containing feedback

## Process

### 1. Read Existing Draft

Read the draft analysis from `DRAFT_PATH`. Understand:
- Current problem statement and context
- Current specificity determination
- Existing recommendations

### 2. Read Feedback

- If `FEEDBACK` is provided -> Use the text directly
- If `FEEDBACK_PATH` is provided -> Read the file contents

Parse the feedback to identify:
- Changes to problem understanding
- Domain context adjustments
- Specificity re-evaluation requests
- Approach recommendation changes

### 3. Identify Sections Needing Revision

Map feedback items to specific analysis sections:
- Problem statement refinements
- Domain context updates
- Specificity level re-evaluation
- Recommendation adjustments

### 4. Research if Needed

If feedback requires new information:

1. Use `WebSearch` to investigate updated context
2. Explore relevant documentation or resources
3. Re-evaluate specificity level if problem understanding changed

If multiple approaches exist for addressing feedback:
- Use `AskUserQuestion` to get user selection
- **MUST select exactly one approach** - do not leave as "A or B"

### 5. Update Draft

Apply revisions to address all feedback items following the Output Format defined in `{baseDir}/SKILL.md`:
- Maintain existing structure where unchanged
- Update affected sections with new content
- Ensure consistency across the entire analysis
- Re-evaluate recommendations if problem understanding changed

### 6. Write to Same Path

Overwrite the existing draft at `DRAFT_PATH` with the revised content.

## Output

Return SUCCESS status with the draft path:

```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-analysis.md
```

## Quality Verification

After revision, verify:

- [ ] All feedback items have been addressed
- [ ] Problem understanding is clearer
- [ ] Specificity determination reflects any new insights
- [ ] Recommendations are consistent with updated analysis
- [ ] Quality Checklist from `{baseDir}/SKILL.md` still passes

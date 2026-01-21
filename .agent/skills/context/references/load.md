# `load` Command

Load context from a Markdown file to resume work.

## Parameters

| Parameter      | Required | Description                      |
| -------------- | -------- | -------------------------------- |
| `CONTEXT_PATH` | Yes      | Path to the context file to load |

## Process

Read the context file and continue from where the previous work left off.

### Sections to Read

1. **invocation** (frontmatter): Original skill invocation info
2. **Progress Summary**: What was done so far, current state
3. **Partial Outputs**: Files already created, data collected
4. **Pending Questions**: Questions needing answers (check Answer field)
5. **Answered Questions**: Questions already answered

### Next Steps

- Check which questions in Pending Questions have filled Answer fields
- Reference Progress Summary to resume from the stopping point
- Use files/data from Partial Outputs

## Output

After parsing context content, return information needed to resume:

```
STATUS: SUCCESS
OUTPUT:
  INVOCATION: /draft-clarify create ISSUE_ID=TA-123
  PENDING_QUESTIONS: [Q1, Q2, ...]  (questions without answers)
  ANSWERED_QUESTIONS: [Q0, ...]     (questions with answers)
```

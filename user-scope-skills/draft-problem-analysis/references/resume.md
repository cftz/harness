# `resume` Command

Continues execution from a saved context file after answers have been collected.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CONTEXT_PATH` | Yes | Path to context file with answers filled in |

## Usage Examples

```bash
# Resume from context file after workflow collected answers
/draft-problem-analysis resume CONTEXT_PATH=.agent/tmp/20260120-143052-draft-problem-analysis-context.md
```

## Process

### 1. Load Context File

Load and parse the context file:

```
skill: context
args: load CONTEXT_PATH={CONTEXT_PATH}
```

Extract:
- Original parameters (PROBLEM, DOMAIN)
- Execution state (phase, step, completed steps)
- Answered questions (domain clarification, scope questions)
- Partial output (research results, initial analysis)

### 2. Validate All Questions Answered

Verify that all questions in "Pending Questions" have their Answer fields filled:

```
skill: context
args: update CONTEXT_PATH={CONTEXT_PATH}
```

If validation fails (STATUS: INCOMPLETE), return error:
```
STATUS: ERROR
MESSAGE: Context file has unanswered questions: {list}
```

### 3. Restore State

From the context file:
- Set current phase to saved phase
- Set step counter to saved step
- Load any partial outputs (research results, domain analysis)

### 4. Apply Answered Questions

Use the answers from the context file to continue execution:

1. For domain clarification: Use the specified domain context
2. For scope questions: Apply to specificity analysis
3. Document decisions in the analysis

### 5. Continue Execution

Resume from the saved step:

1. If more clarification is needed:
   - Save new context (update existing file or create new)
   - Return `AWAIT` status with context path

2. If all clarification is complete:
   - Complete the analysis document
   - Return `SUCCESS` status with draft path

### 6. Return Result

**If completed:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-analysis.md
```

**If more input needed:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

## Context File Integration

| Context Section | Usage in Resume |
|-----------------|-----------------|
| Parameters | Restore original PROBLEM, DOMAIN |
| Execution State | Know where to continue from |
| Pending Questions | Verify all answered, then apply |
| Answered Questions | Already applied (history) |
| Partial Output | Restore research results |

## Error Handling

| Error | Response |
|-------|----------|
| Context file not found | `STATUS: ERROR` + `OUTPUT: Context file not found at {path}` |
| Unanswered questions | `STATUS: ERROR` + `OUTPUT: Questions {list} not answered` |
| Invalid context format | `STATUS: ERROR` + `OUTPUT: Invalid context file format` |
| Mismatched skill name | `STATUS: ERROR` + `OUTPUT: Context file was created by different skill` |

## Quality Verification

After resume completes:

- [ ] Problem is clearly understood and restated
- [ ] Domain context reflects user's answer (if clarified)
- [ ] Specificity level determination has clear reasoning
- [ ] Recommended approach matches the specificity level
- [ ] Quality Checklist from SKILL.md passes

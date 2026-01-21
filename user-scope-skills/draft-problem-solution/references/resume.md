# `resume` Command

Continues execution from a saved context file after answers have been collected.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CONTEXT_PATH` | Yes | Path to context file with answers filled in |

## Usage Examples

```bash
# Resume from context file after workflow collected answers
/draft-problem-solution resume CONTEXT_PATH=.agent/tmp/20260120-143052-draft-problem-solution-context.md
```

## Process

### 1. Load Context File

Load and parse the context file:

```
skill: context
args: load CONTEXT_PATH={CONTEXT_PATH}
```

Extract:
- Original parameters (ANALYSIS_PATH)
- Execution state (phase, step, completed steps)
- Answered questions (approach clarification, idea direction)
- Partial output (analysis summary, initial ideas)

### 2. Validate All Questions Answered

Verify that all questions in "Pending Questions" have their Answer fields filled:

```
skill: context
args: update CONTEXT_PATH={CONTEXT_PATH}
```

If validation fails (STATUS: INCOMPLETE), return error:
```
STATUS: ERROR
OUTPUT: Context file has unanswered questions: {list}
```

### 3. Restore State

From the context file:
- Set current phase to saved phase
- Set step counter to saved step
- Load any partial outputs (analysis summary, generated ideas)

### 4. Apply Answered Questions

Use the answers from the context file to continue execution:

1. For approach clarification: Focus ideation on chosen approach
2. For priority questions: Weight ideas accordingly
3. Document decisions in the solution document

### 5. Continue Execution

Resume from the saved step:

1. If more clarification is needed:
   - Save new context (update existing file or create new)
   - Return `AWAIT` with context path

2. If all clarification is complete:
   - Complete the solution document
   - Return `SUCCESS` with draft path

### 6. Return Result

**If completed:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-solution.md
```

**If more input needed:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

## Context File Integration

| Context Section | Usage in Resume |
|-----------------|-----------------|
| Parameters | Restore original ANALYSIS_PATH |
| Execution State | Know where to continue from |
| Pending Questions | Verify all answered, then apply |
| Answered Questions | Already applied (history) |
| Partial Output | Restore analysis summary, partial ideas |

## Error Handling

| Error | Response |
|-------|----------|
| Context file not found | `STATUS: ERROR`, `OUTPUT: Context file not found at {path}` |
| Unanswered questions | `STATUS: ERROR`, `OUTPUT: Questions {list} not answered` |
| Invalid context format | `STATUS: ERROR`, `OUTPUT: Invalid context file format` |
| Mismatched skill name | `STATUS: ERROR`, `OUTPUT: Context file was created by different skill` |

## Quality Verification

After resume completes:

- [ ] Analysis was thoroughly reviewed and understood
- [ ] Ideas reflect user's direction from answered questions
- [ ] Each idea has a clear source and attribution
- [ ] Trade-offs are honestly assessed
- [ ] Quality Checklist from SKILL.md passes

# `resume` Command

Continues execution from a saved context file after answers have been collected.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CONTEXT_PATH` | Yes | Path to context file with answers filled in |

## Usage Examples

```bash
# Resume from context file after workflow collected answers
/draft-clarify resume CONTEXT_PATH=.agent/tmp/20260120-143052-draft-clarify-context.md
```

## Process

### 1. Load Context File

Load and parse the context file:

```
skill: context
args: load CONTEXT_PATH={CONTEXT_PATH}
```

Extract:
- Original parameters (REQUEST or ISSUE_ID)
- Execution state (phase, step, completed steps)
- Answered questions (from both sections)
- Partial output (prompt_path, draft_content, etc.)

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
- Load any partial outputs (prompt_path, draft_content)

### 4. Apply Answered Questions

Use the answers from the context file to continue execution:

1. For each answered question, record the decision
2. Apply the decision to the appropriate section of the task document
3. Add to "Questions Resolved" section in the output

### 5. Continue Execution

Resume from the saved step:

1. If more clarifying questions are needed:
   - Save new context (update existing file or create new)
   - Return `AWAITING_INPUT` with new questions

2. If all clarification is complete:
   - Finalize task documents
   - Return `COMPLETED` with draft paths

### 6. Return Result

**If completed:**
```
STATUS: COMPLETED
PROMPT_PATH: {prompt_path}
DRAFT_PATHS: {path1},{path2},{path3}
```

**If more input needed:**
```
STATUS: AWAITING_INPUT
CONTEXT_PATH: .agent/tmp/xxx-context.md
QUESTIONS: [...]
```

## Context File Integration

The resume command relies on the context file structure defined in the `context` skill:

| Context Section | Usage in Resume |
|-----------------|-----------------|
| Parameters | Restore original parameters |
| Execution State | Know where to continue from |
| Pending Questions | Verify all answered, then apply |
| Answered Questions | Already applied (history) |
| Partial Output | Restore intermediate work |

## Example Flow

1. **Original create call** identifies need for user input about communication method
2. **Skill saves context** with the question and partial draft
3. **Skill returns** `AWAITING_INPUT` to workflow
4. **Workflow collects answer** via AskUserQuestion
5. **Workflow fills answer** in context file
6. **Workflow calls resume** with context path
7. **Resume loads context**, applies answer to draft
8. **Resume completes** and returns COMPLETED with paths

## Error Handling

| Error | Response |
|-------|----------|
| Context file not found | `STATUS: ERROR`, `MESSAGE: Context file not found at {path}` |
| Unanswered questions | `STATUS: ERROR`, `MESSAGE: Questions {list} not answered` |
| Invalid context format | `STATUS: ERROR`, `MESSAGE: Invalid context file format` |
| Mismatched skill name | `STATUS: ERROR`, `MESSAGE: Context file was created by different skill` |

## Quality Verification

After resume completes:

- [ ] All answered questions are reflected in "Questions Resolved" section
- [ ] Task documents follow the Output Format from SKILL.md
- [ ] No vague "A or B" options remain
- [ ] Quality Checklist from SKILL.md passes

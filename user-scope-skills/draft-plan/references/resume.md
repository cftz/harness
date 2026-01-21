# `resume` Command

Continues execution from a saved context file after answers have been collected.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `CONTEXT_PATH` | Yes | Path to context file with answers filled in |

## Usage Examples

```bash
# Resume from context file after workflow collected answers
/draft-plan resume CONTEXT_PATH=.agent/tmp/20260120-143052-draft-plan-context.md
```

## Process

### 1. Load Context File

Load and parse the context file:

```
skill: context
args: load CONTEXT_PATH={CONTEXT_PATH}
```

Extract:
- Original parameters (TASK_PATH or ISSUE_ID)
- Execution state (phase, step, completed steps)
- Answered questions (package selection, architecture decisions)
- Partial output (requirements analysis, explored code patterns)

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
- Load any partial outputs (requirements, code patterns, package candidates)

### 4. Apply Answered Questions

Use the answers from the context file to continue execution:

1. For package selection questions: Use selected package in the plan
2. For architecture questions: Apply chosen approach
3. Document decisions in the plan under "Package Changes" or implementation steps

### 5. Continue Execution

Resume from the saved step:

1. If more decisions are needed:
   - Save new context (update existing file or create new)
   - Return `AWAIT` with context path

2. If all decisions are made:
   - Complete the plan document
   - Return `SUCCESS` with draft path

### 6. Return Result

**On Success:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-plan.md
```

**On More Input Needed:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

## Context File Integration

The resume command relies on the context file structure defined in the `context` skill:

| Context Section | Usage in Resume |
|-----------------|-----------------|
| Parameters | Restore original TASK_PATH or ISSUE_ID |
| Execution State | Know where to continue from |
| Pending Questions | Verify all answered, then apply |
| Answered Questions | Already applied (history) |
| Partial Output | Restore research results, code patterns |

## Example Flow

1. **Original create call** needs user input for package selection (Redis vs Memcached)
2. **Skill saves context** with the question and package research results
3. **Skill returns** `AWAIT` to workflow
4. **Workflow collects answer** via AskUserQuestion
5. **Workflow fills answer** in context file
6. **Workflow calls resume** with context path
7. **Resume loads context**, applies package choice to plan
8. **Resume completes** and returns SUCCESS with draft path

## Error Handling

| Error | Response |
|-------|----------|
| Context file not found | `STATUS: ERROR`, `OUTPUT: Context file not found at {path}` |
| Unanswered questions | `STATUS: ERROR`, `OUTPUT: Questions {list} not answered` |
| Invalid context format | `STATUS: ERROR`, `OUTPUT: Invalid context file format` |
| Mismatched skill name | `STATUS: ERROR`, `OUTPUT: Context file was created by different skill` |

## Quality Verification

After resume completes:

- [ ] All answered questions are reflected in the plan
- [ ] Plan follows the Plan Document Format from SKILL.md
- [ ] No "A or B" options remain undecided
- [ ] Every function has concrete signature (not "something like X")
- [ ] Quality Checklist from SKILL.md passes

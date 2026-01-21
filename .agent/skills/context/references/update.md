# `update` Command

Validate context file after answers have been filled in.

## Parameters

| Parameter      | Required | Description                      |
| -------------- | -------- | -------------------------------- |
| `CONTEXT_PATH` | Yes      | Path to the context file         |

## Process

Read the context file and check if all Answer fields in Pending Questions are filled.

### Validation

For each question in the Pending Questions section:
- If `**Answer**:` is followed by a value -> answered
- If `**Answer**:` is followed by empty or whitespace only -> not answered

## Output

**All answered (ready to resume):**
```
STATUS: SUCCESS
OUTPUT:
  RESULT: READY
  CONTEXT_PATH: .agent/tmp/xxx-context.md
```

**Missing answers:**
```
STATUS: SUCCESS
OUTPUT:
  RESULT: INCOMPLETE
  MISSING: [Q1, Q3]
```

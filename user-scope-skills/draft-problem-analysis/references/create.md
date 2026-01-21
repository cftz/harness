# `create` Command

Creates a new draft problem analysis document.

## Parameters

### Required

- `PROBLEM` - Problem description to analyze (e.g., `PROBLEM="How to synchronize state across microservices"`)

### Optional

- `DOMAIN` - Target domain context (e.g., `DOMAIN="distributed systems"`)
- `OUTPUT_PATH` - Path to write the draft analysis. If not provided, uses `mktemp` skill to create a temporary file.

## Process

### 1. Parse Problem

Extract from `PROBLEM` parameter:
- **Problem Statement**: What needs to be solved?
- **Implicit Domain**: What field does this belong to? (use `DOMAIN` if provided)
- **Implicit Constraints**: What limitations might exist?

### 2. Research Problem Context

Use `WebSearch` to understand the problem domain:

| Query Type | Template | Example |
|------------|----------|---------|
| Definition | `"what is {problem}"` | "what is state synchronization" |
| Solutions | `"{problem}" solutions` | "state synchronization solutions" |
| Challenges | `"{problem}" challenges` | "state synchronization challenges" |
| Domain-specific | `"{domain}" "{problem}"` | "distributed systems state synchronization" |

### 3. Determine Specificity Level

Analyze the problem against these criteria:

**General** (recommend `best-practice`):
- Problem is well-known in the industry
- Multiple documented solutions exist
- Standard patterns or frameworks address it
- Examples: caching, authentication, API design

**Specialized** (recommend `analogous`):
- Problem is domain-specific
- Related fields have solved similar problems
- Solutions need adaptation from adjacent domains
- Examples: state sync (PLC systems), resource scheduling (OS schedulers)

**Novel** (recommend `cross-domain`):
- Problem is unique or unprecedented
- No direct solutions exist in any related field
- Requires innovative thinking from unrelated domains
- Examples: breakthrough product design, paradigm-shifting architecture

#### Checkpoint: Save Context if Clarification Needed

If the problem statement is ambiguous or domain context is unclear, **save context and return** for clarification.

Use the `checkpoint` skill to save state and return AWAIT:

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

### 4. Create Output File

- If `OUTPUT_PATH` is provided -> Use that path directly
- If `OUTPUT_PATH` is not provided -> Use the `mktemp` skill:
  ```
  skill: mktemp
  args: analysis
  ```

### 5. Write Draft Analysis

Write the analysis document to the output file following the Output Format defined in `{baseDir}/SKILL.md`.

Include:
- Clear problem restatement
- Domain context (provided or inferred)
- Specificity level with reasoning
- Primary approach recommendation
- Alternative approaches
- Next step command

## Output

Return SUCCESS status with the draft path:

```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-analysis.md
```

> Note: The output uses `DRAFT_PATH` (not `OUTPUT_PATH`) to maintain consistency with the `modify` command and dependent skills.

# Analysis Criteria

This document defines the criteria for detecting conflicts, duplications, and ambiguities in rule files.

## Conflict Detection

### What Constitutes a Conflict?

Two rules conflict when they provide **contradictory guidance** on the same topic.

### Conflict Patterns

#### 1. Opposite Instructions

```markdown
# File A
- Always use `async def` for handlers

# File B
- Use `def` for handlers unless I/O is involved
```

#### 2. Different Defaults

```markdown
# File A
- Return `None` when resource not found

# File B
- Raise `NotFoundError` when resource not found
```

#### 3. Contradictory Code Examples

```markdown
# File A
class Handler(Protocol):  # Inherit Protocol
    ...

# File B
class Handler:  # No inheritance needed
    ...
```

### Not a Conflict

- Same rule stated differently (paraphrasing)
- One rule being more specific than another (that's hierarchy)
- Rules for different contexts (e.g., HTTP vs Worker)

---

## Duplication Detection

### What Constitutes Duplication?

Content is duplicated when **substantially the same information** appears in multiple files.

### Duplication Patterns

#### 1. Verbatim Copy

Exact same text block (3+ lines) in multiple files.

#### 2. Same Code Example

Identical or nearly identical code snippets demonstrating the same concept.

```python
# Same example in multiple files
class UserService:
    def __init__(self, logger: structlog.BoundLogger, repo: UserRepositoryPort):
        self.logger = logger.bind(name="user.service")
        self.repo = repo
```

#### 3. Same Rule List

Same bullet points or numbered list covering identical rules.

```markdown
# Appears in multiple files
1. Use Protocol for ports
2. Explicit Protocol inheritance
3. Async for all I/O operations
```

### Duplication Categories

#### Hierarchical (Glob Pattern Overlap)

Files where one glob pattern is a subset of another:

- `**/src/**/*.py` contains `**/src/platform/**/*`
- Rule should exist in the **more general** (parent) file
- Child file should reference parent: `See [parent.md](./parent.md)`

#### Unrelated Paths

Files with non-overlapping glob patterns:

- `**/src/platform/domain/*.py` and `**/src/service/*/inbound/http/**/*`
- Should extract to a **new shared file** with broader glob pattern
- Or keep in both if context-specific explanation is needed

---

## Ambiguity Detection

### What Constitutes Ambiguity?

A rule is ambiguous when it **cannot be consistently applied** due to lack of specificity.

### Ambiguity Patterns

#### 1. Vague Quantifiers

Words that don't specify exact amounts:

- "some", "few", "many", "several"
- "often", "sometimes", "usually"
- "etc.", "and so on", "and more"

```markdown
# Ambiguous
- Add comments for complex logic

# Clear
- Add comments for functions longer than 20 lines or with cyclomatic complexity > 5
```

#### 2. Missing Thresholds

Rules without numeric limits:

```markdown
# Ambiguous
- Keep functions short

# Clear
- Functions should not exceed 50 lines
```

#### 3. Undefined Terms

Technical terms used without definition:

```markdown
# Ambiguous
- Use appropriate error handling

# Clear
- Catch specific exceptions (NotFoundError, BadRequestError), never bare `except:`
```

#### 4. Missing Examples

Rules that would benefit from concrete examples:

```markdown
# Ambiguous
- Use descriptive variable names

# Clear
- Use descriptive variable names:
  - Good: `user_count`, `is_authenticated`, `order_items`
  - Bad: `x`, `temp`, `data`
```

#### 5. Conditional Without Criteria

"If appropriate" or "when needed" without specifying when:

```markdown
# Ambiguous
- Add type hints when appropriate

# Clear
- Add type hints to all function signatures and class attributes
```

---

## Severity Levels

### Critical (Must Fix)

- Direct contradictions between rules
- Same exact content copied across 3+ files
- Rules that cannot be followed due to ambiguity

### High (Should Fix)

- Implicit contradictions (conflicting examples)
- Content duplicated in 2 files
- Missing examples for complex rules

### Medium (Consider Fixing)

- Redundant explanations (same concept, different words)
- Vague quantifiers in non-critical rules
- Minor inconsistencies in terminology

### Low (Optional)

- Stylistic differences in examples
- Extra explanatory text that doesn't change meaning
- Slightly different formatting

---
name: draft-problem-analysis
description: |
  Use this skill to analyze problems and recommend approaches for ideation.

  Creates or modifies draft problem analysis documents in temporary files. Atomic skill for Phase A of problem-solving workflow.

  Commands:
    create - Create new problem analysis
      PROBLEM="<text>" (Required) - Problem description
      DOMAIN="<text>" (Optional) - Target domain context
      OUTPUT_PATH=<path> (Optional) - Output file path (uses mktemp if omitted)
      Returns: DRAFT_PATH (if completed) or CONTEXT_PATH, QUESTIONS (if awaiting input)
    modify - Revise existing analysis based on feedback
      DRAFT_PATH=<path> (Required) - Existing draft to revise
      Feedback (OneOf, Required):
        FEEDBACK="<text>" - Feedback text
        FEEDBACK_PATH=<path> - Feedback file path

  Examples:
    /draft-problem-analysis create PROBLEM="How to synchronize state across microservices"
    /draft-problem-analysis create PROBLEM="State sync issue" DOMAIN="distributed systems"
    /draft-problem-analysis modify DRAFT_PATH=.agent/tmp/xxx-analysis FEEDBACK="Focus on eventual consistency"
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Draft Problem Analysis Skill

Creates or modifies draft problem analysis documents and writes them to temporary files. This is an atomic skill that handles the problem analysis phase, recommending appropriate approaches for ideation.

## Commands

| Command  | Description                                 | Docs                             |
| -------- | ------------------------------------------- | -------------------------------- |
| `create` | Create new problem analysis                 | `{baseDir}/references/create.md` |
| `modify` | Revise existing analysis based on feedback  | `{baseDir}/references/modify.md` |

## Output Format

Each analysis document must include YAML frontmatter followed by the content sections.

### YAML Frontmatter

```yaml
---
title: Analysis title based on problem
problem: Original problem statement
domain: Target domain (if provided)
specificity: General | Specialized | Novel
---
```

- `title`: Short analysis title
- `problem`: Original problem statement for reference
- `domain`: Target domain context (if provided)
- `specificity`: Determined problem specificity level

### Problem Statement

Restate the problem with clarity and precision.

### Domain Context

Describe the target domain and relevant context.

### Specificity Analysis

Analyze the problem against these criteria:

```
+------------------+    +------------------+    +------------------+
|     General      |    |   Specialized    |    |      Novel       |
|                  |    |                  |    |                  |
| - Well-known     |    | - Domain-specific|    | - Unique problem |
|   problem        |    | - Solutions exist|    | - No direct      |
| - Standard       |    |   in related     |    |   solutions      |
|   patterns exist |    |   fields         |    | - Needs          |
|                  |    |                  |    |   innovation     |
+--------+---------+    +--------+---------+    +--------+---------+
         |                       |                       |
         v                       v                       v
   best-practice            analogous             cross-domain
```

| Level | Characteristics | Recommended Approach |
|-------|-----------------|---------------------|
| **General** | Well-known, standardized patterns exist | `best-practice` |
| **Specialized** | Domain-specific, solutions in related fields | `analogous` |
| **Novel** | Unique, no direct solutions, needs innovation | `cross-domain` |

### Reasoning

Explain why this specificity level was determined.

### Recommended Approach

State the primary recommendation with rationale.

### Alternative Approaches

List other approaches that might help and when they would be useful.

### Next Step

Provide the suggested command to continue:

```
/draft-problem-solution create ANALYSIS_PATH={DRAFT_PATH}
```

## Quality Checklist

Before completing the draft, verify:

- [ ] Problem is clearly understood and restated
- [ ] Domain context is properly identified
- [ ] Specificity level determination has clear reasoning
- [ ] Recommended approach matches the specificity level
- [ ] Alternative approaches are mentioned for completeness
- [ ] Next step command is provided

## Output

SUCCESS:
- DRAFT_PATH: Path to the created/modified analysis file

ERROR: Error message describing what went wrong

## Notice

### Strict Decision Making

The analysis must not contain vague content such as "could be A or B". All aspects must be analyzed and decided before creating the output. If uncertain:

1. Research using available tools (WebSearch, codebase exploration)
2. Ask the user using `AskUserQuestion` if clarification is needed
3. Document the decision in the analysis

### No User Review in This Skill

This skill only creates/modifies the draft. User review and final output creation should be handled by a separate workflow or the caller.

---
name: draft-problem-solution
description: |
  Use this skill to generate problem-solving ideas based on analysis results.

  Creates or modifies draft solution documents in temporary files. Atomic skill for Phase B of problem-solving workflow.

  Commands:
    create - Create new solution ideas from analysis
      ANALYSIS_PATH=<path> (Required) - Path to draft-problem-analysis output
      OUTPUT_PATH=<path> (Optional) - Output file path (uses mktemp if omitted)
      Returns: SUCCESS with DRAFT_PATH, or AWAIT with CONTEXT_PATH
    modify - Revise existing solutions based on feedback
      DRAFT_PATH=<path> (Required) - Existing draft to revise
      Feedback (OneOf, Required):
        FEEDBACK="<text>" - Feedback text
        FEEDBACK_PATH=<path> - Feedback file path

  Examples:
    /draft-problem-solution create ANALYSIS_PATH=.agent/tmp/xxx-analysis
    /draft-problem-solution modify DRAFT_PATH=.agent/tmp/xxx-solution FEEDBACK="Explore more cross-domain approaches"
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Draft Problem Solution Skill

Creates or modifies draft solution documents and writes them to temporary files. This is an atomic skill that handles the ideation phase of problem-solving workflow, generating ideas based on the analysis from draft-problem-analysis.

## Commands

| Command  | Description                                 | Docs                             |
| -------- | ------------------------------------------- | -------------------------------- |
| `create` | Create new solution ideas from analysis     | `{baseDir}/references/create.md` |
| `modify` | Revise existing solutions based on feedback | `{baseDir}/references/modify.md` |

## Approach Reference Documents

Based on the approach recommended in the analysis, load the corresponding reference:

| Approach | Reference Document |
|----------|-------------------|
| `best-practice` | `{baseDir}/references/best-practice.md` |
| `analogous` | `{baseDir}/references/analogous-domain.md` |
| `cross-domain` | `{baseDir}/references/cross-domain.md` |

## Output Format

Each solution document must include YAML frontmatter followed by the content sections.

### YAML Frontmatter

```yaml
---
title: Solution title based on problem
problem: Original problem statement
approach: best-practice | analogous | cross-domain
analysis_path: Path to source analysis
---
```

- `title`: Short solution title
- `problem`: Original problem statement for reference
- `approach`: The approach used for ideation
- `analysis_path`: Path to the analysis this is based on

### Problem Summary

Brief restatement of the problem being solved.

### Approach Used

Name of the approach and brief explanation of why it was selected.

### Ideas Generated

For each idea generated:

```markdown
### N. {Idea Name}

**Source**: {where this idea comes from - reference link if available}

**Core Principle**:
{The fundamental concept that makes this approach work}

**Application to This Problem**:
{Specific guidance on applying to the user's problem}

**Trade-offs**:
- Pros: {list benefits}
- Cons: {list drawbacks}

**When to Use**: {ideal scenarios for this approach}
```

### Top Recommendations

Highlight the top 3 ideas with rationale and suggested next steps.

### Further Exploration

Suggested directions for deeper investigation if needed.

## Quality Checklist

Before completing the draft, verify:

- [ ] Analysis was thoroughly reviewed and understood
- [ ] Correct approach reference document was loaded
- [ ] Each idea has a clear source and attribution
- [ ] Ideas are actionable with concrete application strategies
- [ ] Trade-offs are honestly assessed
- [ ] Top recommendations have clear rationale
- [ ] Further exploration suggestions are provided

## Output

SUCCESS:
- DRAFT_PATH: Path to the created/modified solution file

ERROR: Error message string

## Notice

### WebSearch-Based Exploration

This skill uses `WebSearch` to find real-world examples and references rather than generating ideas purely from LLM knowledge. Each idea should be grounded in documented solutions or principles.

### No User Review in This Skill

This skill only creates/modifies the draft. User review and final output creation should be handled by a separate workflow or the caller.

# `create` Command

Creates a new draft solution document from problem analysis.

## Parameters

### Required

- `ANALYSIS_PATH` - Path to the problem analysis document from draft-problem-analysis (e.g., `.agent/tmp/xxx-analysis`)

### Optional

- `OUTPUT_PATH` - Path to write the draft solution. If not provided, uses `mktemp` skill to create a temporary file.

## Process

### 1. Read Analysis

Read the problem analysis from `ANALYSIS_PATH`. Extract:
- Problem statement
- Domain context
- Specificity level
- Recommended approach

Verify the analysis is complete and has clear recommendations.

### 2. Load Approach Guide

Based on the recommended approach in the analysis, load the corresponding reference document:

| Approach | Reference Document |
|----------|-------------------|
| `best-practice` | `{baseDir}/references/best-practice.md` |
| `analogous` | `{baseDir}/references/analogous-domain.md` |
| `cross-domain` | `{baseDir}/references/cross-domain.md` |

Read and understand the approach methodology.

### 3. Execute Approach

Follow the process defined in the loaded reference document:

**For best-practice approach**:
1. Formulate search queries for documented solutions
2. Execute WebSearch for patterns, libraries, and frameworks
3. Extract solution details from authoritative sources

**For analogous approach**:
1. Abstract the problem to reveal core challenge
2. Identify related engineering domains
3. Search for solutions in those domains
4. Analyze transferability of analogies

**For cross-domain approach**:
1. Deep abstraction to find universal problem
2. Identify core tensions and trade-offs
3. Search completely unrelated fields for inspiration
4. Extract universal principles that could apply

### 4. Generate Ideas

For each relevant finding, structure the idea with:
- Source attribution (reference link when available)
- Core principle explanation
- Specific application guidance
- Honest trade-off assessment
- Usage scenarios

Aim for 5-10 ideas with varying levels of innovation.

#### Checkpoint: Save Context if Clarification Needed

If you need user input to focus the ideation direction, **save context and return**.

Use the `checkpoint` skill to save state and return AWAIT:

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

### 5. Rank Recommendations

Select top 3 ideas based on:
- Applicability to the specific problem
- Feasibility of implementation
- Potential impact
- Risk/reward balance

Provide clear rationale for each ranking.

### 6. Create Output File

- If `OUTPUT_PATH` is provided -> Use that path directly
- If `OUTPUT_PATH` is not provided -> Use the `mktemp` skill:
  ```
  skill: mktemp
  args: solution
  ```

### 7. Write Draft Solution

Write the solution document to the output file following the Output Format defined in `{baseDir}/SKILL.md`.

## Output

**If completed:**
```
STATUS: SUCCESS
OUTPUT:
  DRAFT_PATH: .agent/tmp/xxx-solution.md
```

**If user input needed:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

> Note: The output uses `DRAFT_PATH` (not `OUTPUT_PATH`) to maintain consistency with the `modify` command and dependent skills.

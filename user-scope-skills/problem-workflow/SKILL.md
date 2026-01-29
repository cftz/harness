---
name: problem-workflow
description: |
  Use this skill to orchestrate the complete problem-solving process.

  Orchestrates problem-solving by combining draft-problem-analysis, draft-problem-solution, and finalize-problem-solution skills with user approval.

  Args:
    Problem Source (OneOf, Required):
      PROBLEM="<text>" - Problem description text
      ISSUE_ID=<id> - Issue ID containing the problem (e.g., PROJ-123)
    Options:
      DOMAIN="<text>" - Target domain context (optional)
      PROVIDER=linear|jira - Issue tracker provider (default: linear)
    Output Destination (OneOf, Optional):
      ARTIFACT_DIR_PATH=<path> - Save to artifact directory
      PROJECT_ID=<id> - Save as issue/document in project
      (If omitted with ISSUE_ID, saves as Document/Attachment to the issue)
    Finalize Options:
      NEW_ISSUE=<bool> - true=Create Issue (default), false=Create Document (PROJECT_ID only)

  Examples:
    /problem-workflow PROBLEM="How to synchronize state across microservices"
    /problem-workflow PROBLEM="State sync issue" DOMAIN="distributed systems"
    /problem-workflow ISSUE_ID=TA-123
    /problem-workflow ISSUE_ID=PROJ-456 PROVIDER=jira
    /problem-workflow PROBLEM="How to improve cache invalidation" ARTIFACT_DIR_PATH=.agent/artifacts/20260125
    /problem-workflow PROBLEM="Auth flow optimization" PROJECT_ID=cops
model: claude-opus-4-5
---

# Description

**IMPORTANT: Use this workflow when you need to analyze a problem and generate solution ideas.**

Orchestrates the complete problem-solving process by combining `draft-problem-analysis`, `draft-problem-solution`, and `finalize-problem-solution` skills. This workflow analyzes the problem, determines the appropriate approach, generates solution ideas, and then presents results to the user for approval before saving to the destination.

## Parameters

### Problem Source (OneOf, Required)

Provide one of the following to specify the problem:

- `PROBLEM` - Problem description text (e.g., `"How to synchronize state across microservices"`)
- `ISSUE_ID` - Issue ID containing the problem (e.g., `TA-123` or `PROJ-456`)

### Options

- `DOMAIN` - Target domain context to focus the analysis (optional)
- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`. Used with ISSUE_ID or PROJECT_ID.

### Output Destination (OneOf, Optional)

- `ARTIFACT_DIR_PATH` - Artifact directory path (e.g., `.agent/artifacts/20260105-120000`)
- `PROJECT_ID` - Project ID or name to create issue/document in

If not provided and `ISSUE_ID` is provided, the solution will be saved as:
- **Linear**: Document attached to the Issue
- **Jira**: Attachment on the Issue

> **Note**: If `PROBLEM` is used without an output destination, you must ask the user to provide one.

### Finalize Options

- `NEW_ISSUE` - When using PROJECT_ID: `true` creates an Issue (default), `false` creates a Document/Attachment

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Validate Parameters                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Verify problem source (PROBLEM or ISSUE_ID)          │  │
│  │ Resolve output destination if not provided            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Problem Analysis (Phase A)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-problem-analysis                         │  │
│  │ args: create PROBLEM=... [DOMAIN=...]                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│              ┌───────────────┴───────────────┐              │
│              │                               │              │
│          SUCCESS                          AWAIT             │
│              │                               │              │
│              ↓                               ↓              │
│  ┌────────────────────┐    ┌──────────────────────────┐   │
│  │ Returns:           │    │ 1. Load context file     │   │
│  │ DRAFT_PATH         │    │ 2. AskUserQuestion       │   │
│  │ (analysis)         │    │ 3. Fill answers in file  │   │
│  └────────────────────┘    │ 4. Call resume           │   │
│                            └──────────────────────────┘   │
│                                         │                  │
│                                         └──→ Loop until    │
│                                              SUCCESS        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 3: User Review (Analysis)                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Display analysis results to user                      │  │
│  │ Show: Problem restatement, Domain, Specificity,       │  │
│  │       Recommended Approach                            │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ AskUserQuestion: Proceed with analysis or revise?     │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                    │                  │
│          Request Changes              Proceed              │
│                     │                    │                  │
│                     ↓                    │                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-problem-analysis                         │  │
│  │ args: modify DRAFT_PATH=... FEEDBACK="..."            │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                       │
│                     └───────────→ Loop back to display      │
└─────────────────────────────────────────────────────────────┘
                              │ Proceed
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Solution Generation (Phase B)                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: draft-problem-solution                         │  │
│  │ args: create ANALYSIS_PATH=<analysis_draft_path>      │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│              ┌───────────────┴───────────────┐              │
│              │                               │              │
│          SUCCESS                          AWAIT             │
│              │                               │              │
│              ↓                               ↓              │
│  ┌────────────────────┐    ┌──────────────────────────┐   │
│  │ Returns:           │    │ Resume loop (same as     │   │
│  │ DRAFT_PATH         │    │ Step 2)                  │   │
│  │ (solution)         │    └──────────────────────────┘   │
│  └────────────────────┘                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 5: User Review (Solution)                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Display solution to user                              │  │
│  │ Show: Ideas, Top Recommendations, Trade-offs          │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ AskUserQuestion: Approve, Request Changes, or         │  │
│  │                  Re-analyze?                          │  │
│  └──────────────────────────────────────────────────────┘  │
│            │                    │                │          │
│      Re-analyze          Request Changes      Approve      │
│            │                    │                │          │
│            ↓                    ↓                │          │
│  Back to Step 2          Modify solution         │          │
│                          Loop back               │          │
└─────────────────────────────────────────────────────────────┘
                              │ Approve
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Step 6: Finalize                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ skill: finalize-problem-solution                      │  │
│  │ args: DRAFT_PATH=... [ARTIFACT_DIR_PATH=... or        │  │
│  │       ISSUE_ID=... or PROJECT_ID=...]                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ↓                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Returns: Final output location                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Process

### 1. Validate Parameters

1. Verify that exactly one of `PROBLEM` or `ISSUE_ID` is provided
2. Resolve `PROVIDER`:
   - If `PROVIDER` parameter is explicitly provided, use it
   - If not provided, get from project-manage:
     ```
     skill: project-manage
     args: provider
     ```
     Use the returned provider value (or `linear` if project-manage not initialized)
3. If `ISSUE_ID` is provided, extract problem from the issue description
4. If `PROBLEM` is used without output destination:
   - Ask user to provide `ARTIFACT_DIR_PATH` or `PROJECT_ID`

### 2. Problem Analysis (Phase A)

Invoke the `draft-problem-analysis` skill:

```
skill: draft-problem-analysis
args: create PROBLEM="<problem_text>" [DOMAIN="<domain>"]
```

#### Handle Return Status

**SUCCESS** - Analysis complete:
- `DRAFT_PATH` - Path to the analysis document
- Store as `ANALYSIS_PATH` and proceed to Step 3

**AWAIT** - Skill needs user input:
- `CONTEXT_PATH` - Path to the saved context file
- Enter the resume loop:
  1. Load context using `checkpoint load`
  2. Convert questions to `AskUserQuestion` format
  3. Fill answers in context file
  4. Validate with `checkpoint update`
  5. Resume with `draft-problem-analysis resume CONTEXT_PATH=...`
- Loop until SUCCESS

### 3. User Review (Analysis)

1. **Display Analysis Results**
   - Read and display the analysis from `ANALYSIS_PATH`
   - Highlight: Problem Statement, Domain Context, Specificity Level, Recommended Approach

2. **Request User Decision**
   ```
   AskUserQuestion:
     question: "Do you agree with this problem analysis?"
     header: "Analysis Review"
     options:
       - label: "Proceed to Solution"
         description: "Accept analysis and generate solution ideas"
       - label: "Request Changes"
         description: "Provide feedback to revise the analysis"
   ```

3. **Handle User Response**
   - If **"Proceed to Solution"**: Go to Step 4
   - If **"Request Changes"**:
     a. Get feedback from user
     b. Call draft-problem-analysis modify:
        ```
        skill: draft-problem-analysis
        args: modify DRAFT_PATH=<path> FEEDBACK="<user_feedback>"
        ```
     c. Loop back to display the revised analysis

### 4. Solution Generation (Phase B)

Invoke the `draft-problem-solution` skill:

```
skill: draft-problem-solution
args: create ANALYSIS_PATH=<analysis_draft_path>
```

#### Handle Return Status

Same as Step 2 - handle SUCCESS, AWAIT, and ERROR.

Store the result as `SOLUTION_PATH`.

### 5. User Review (Solution)

1. **Display Solution**
   - Read and display the solution from `SOLUTION_PATH`
   - Highlight: Ideas Generated, Top Recommendations, Trade-offs

2. **Request User Decision**
   ```
   AskUserQuestion:
     question: "Do you approve this solution document?"
     header: "Solution Review"
     options:
       - label: "Approve"
         description: "Save the solution to final destination"
       - label: "Request Changes"
         description: "Provide feedback to revise the solution"
       - label: "Re-analyze Problem"
         description: "Go back and revise the problem analysis"
   ```

3. **Handle User Response**
   - If **"Approve"**: Go to Step 6
   - If **"Request Changes"**:
     a. Get feedback from user
     b. Call draft-problem-solution modify:
        ```
        skill: draft-problem-solution
        args: modify DRAFT_PATH=<path> FEEDBACK="<user_feedback>"
        ```
     c. Loop back to display the revised solution
   - If **"Re-analyze Problem"**: Go back to Step 3

### 6. Finalize

Once approved, invoke the `finalize-problem-solution` skill:

- If `ARTIFACT_DIR_PATH` is provided:
  ```
  skill: finalize-problem-solution
  args: DRAFT_PATH=<solution_path> ARTIFACT_DIR_PATH=<artifact_path>
  ```

- If `ISSUE_ID` is provided (or was the original input):
  ```
  skill: finalize-problem-solution
  args: DRAFT_PATH=<solution_path> ISSUE_ID=<issue_id> PROVIDER=<provider>
  ```

- If `PROJECT_ID` is provided:
  ```
  skill: finalize-problem-solution
  args: DRAFT_PATH=<solution_path> PROJECT_ID=<project_id> PROVIDER=<provider> [NEW_ISSUE=<bool>]
  ```

### 7. Report Result

Output the result from the `finalize-problem-solution` skill, including:
- Final output location
- Summary of the problem and recommended solutions
- Analysis approach used

## Output

SUCCESS:
- OUTPUT_LOCATION: Final output path (artifact file, Document ID, or Issue ID)
- PROVIDER: Issue tracker provider used (linear or jira), only for issue output
- PROBLEM_SUMMARY: Brief summary of the problem analyzed
- APPROACH_USED: The ideation approach used (best-practice/analogous/cross-domain)
- TOP_RECOMMENDATIONS: List of top recommended solutions

ERROR: Error message string (e.g., "draft-problem-analysis failed: ...")

### Success Report Format

When the workflow completes successfully, report to the user:

```
STATUS: SUCCESS
OUTPUT:
  OUTPUT_LOCATION: {artifact path or Document/Issue ID}
  PROBLEM_SUMMARY: {brief problem summary}
  APPROACH_USED: {approach}
  TOP_RECOMMENDATIONS:
    - {recommendation 1}
    - {recommendation 2}
    - {recommendation 3}

## Problem Workflow Complete

- **Output Location**: [artifact path or Document/Issue ID]
- **Problem**: [brief summary]
- **Approach Used**: [best-practice/analogous/cross-domain]

### Top Recommendations
1. {recommendation 1}
2. {recommendation 2}
3. {recommendation 3}

[If artifact]: File saved to: .agent/artifacts/YYYYMMDD-HHMMSS/NN_solution.md
[If Linear Document]: Document attached to issue: [ISSUE_ID]
[If Linear Issue]: Issue created: [ISSUE_ID]
[If Jira]: Attachment/Issue created: [ISSUE_KEY]
```

## Quality Checklist

Before completing, verify:

- [ ] **Problem source validated**: Exactly one of PROBLEM or ISSUE_ID provided
- [ ] **Problem extracted**: If ISSUE_ID, problem text extracted from issue
- [ ] **Analysis completed**: draft-problem-analysis returned SUCCESS
- [ ] **Analysis reviewed**: User approved or revised the analysis
- [ ] **Solution generated**: draft-problem-solution returned SUCCESS
- [ ] **Solution approved**: User explicitly approved the solution
- [ ] **Final output saved**: finalize-problem-solution completed successfully
- [ ] **Result reported**: Output location and summary communicated to user

## Notice

### Orchestration Only

This skill performs orchestration only and does not:
- Analyze problems directly (delegated to draft-problem-analysis)
- Generate solutions directly (delegated to draft-problem-solution)
- Write to final destinations (delegated to finalize-problem-solution)

### Dependent Skills

This skill requires the following skills to exist:
- `draft-problem-analysis` - Analyzes problem and recommends approach
- `draft-problem-solution` - Generates solution ideas based on analysis
- `finalize-problem-solution` - Saves approved solution to final destination
- `project-manage` - Resolves default provider (provider-agnostic)
- `checkpoint` - Manages interruptible checkpoint files for resume support

### Two-Phase Problem Solving

This workflow uses a two-phase approach:
1. **Analysis Phase**: Understand the problem, determine specificity, recommend approach
2. **Solution Phase**: Generate ideas based on the recommended approach

Each phase has its own user review step to ensure alignment before proceeding.

### No Auto-Review Loop

Unlike plan-workflow or clarify-workflow, this skill does not have an automated review loop because:
- Problem analysis and solution generation are creative processes
- User judgment is essential at each phase
- There is no corresponding review skill (e.g., no `problem-review` or `solution-review`)

User review happens at two points:
1. After analysis (before solution generation)
2. After solution generation (before finalization)

---
name: plan-issues
description: "Batch planning for project issues. Finds eligible issues, plans in parallel, auto-reviews, and registers to Linear.\n\nArgs:\n  STATE=<state> (Optional) - Issue state filter (default: Todo,Backlog)\n  LIMIT=<n> (Optional) - Max issues to process in parallel (default: 4)\n\nExamples:\n  /plan-issues\n  /plan-issues STATE=Todo\n  /plan-issues LIMIT=6"
model: claude-opus-4-5
---

# Description

> **CRITICAL ROLE CONSTRAINT**
>
> You are an **ORCHESTRATOR**, not an implementer. You delegate planning work to SubAgents and Skills.
> This skill coordinates multiple plan and plan-review executions in parallel.

Batch processes project issues by finding eligible ones, creating plans in parallel, and auto-reviewing before user approval.

## Parameters

### Optional

- `STATE` - Issue state filter. Defaults to `Todo,Backlog`. Comma-separated values supported.
- `LIMIT` - Maximum number of issues to process in parallel. Defaults to `4`.

## Skill Overview

```
Find Issues → Parallel Plan (tmp) → Parallel Review (tmp) → Fix → User Ask → Attach
      ↓              ↓                      ↓             ↓        ↓         ↓
[linear-issue]  [step-by-step]         [step-by-step]    [loop]   [User]   [Phase B]
```

## Process

### Step 1: Find Eligible Issues

1. Use linear-issue skill to list issues:
   ```
   skill: linear:linear-issue
   args: list STATE=$STATE
   ```

2. Filter results to find eligible issues:
   - **Leaf Task**: No sub-issues (children)
   - **No Dependencies**: No blocking issues, or all blocking issues are Done
   - **No Plan Document**: No Document attached to the issue

3. Select up to `LIMIT` issues for processing

4. If no eligible issues found, notify user and exit

### Step 2: Parallel Planning (Temporary Files)

1. For each selected issue, launch step-by-step in parallel using Task tool with `subagent_type: step-by-step-agent`:
   ```
   /plan-workflow ISSUE_ID=$ISSUE_ID
   ```

   > **Note**: The plan skill writes to a temporary file (via mktemp) first,
   > then waits for user approval via AskUserQuestion.
   > **Do NOT respond to this approval request yet** - proceed to Step 3.

2. Collect temporary plan file paths from each step-by-step

3. Track each plan skill's pending approval state

### Step 3: Parallel Review (Auto-Review)

1. For each temporary plan file, launch step-by-step in parallel:
   ```
   Use Task tool:
   - subagent_type: step-by-step-agent
   - prompt: /plan-review PLAN_PATH=$TMP_PLAN_PATH ARTIFACT_DIR_PATH=.agent/tmp
   ```

   > **Note**: plan-review performs automated review instead of human review.
   > Review results (Approved / Revision Needed) are saved to temporary files.

2. Collect review result file paths

### Step 4: Review-Fix Loop

1. Check each review result:

   **If "Revision Needed":**
   - Respond to the plan skill's pending approval with "Revision Needed"
   - Provide the review feedback from the plan-review result
   - The plan skill will revise the temporary file and wait for approval again
   - Re-run Step 3 for this issue
   - Repeat until "Approved"

   **If "Approved":**
   - Mark this issue as ready for final approval
   - Continue to next issue

2. Continue loop until all issues are "Approved"

### Step 5: User Final Approval

1. All plans have passed plan-review at this point

2. Present summary to user:
   - List all issues with their plan summaries
   - Show that all passed automated review

3. Request final approval:
   ```
   Use AskUserQuestion:
   - Question: "The following issues have passed plan-review. Would you like to register them to Linear?"
   - Header: "Final Approval"
   - Options:
     - label: "Approve - Register to Linear"
       description: "Register all plans as Linear Documents"
     - label: "Revision Needed"
       description: "Revise specific plans"
     - label: "Cancel"
       description: "Exit without registering"
   ```

4. Handle response:
   - **"Approve"**: Proceed to Step 6
   - **"Revision Needed"**: Get user feedback, apply to relevant plans, return to Step 4
   - **"Cancel"**: Exit workflow, respond "Cancel" to all pending plan approvals

### Step 6: Complete (Automatic Registration)

1. For each plan skill waiting for approval:
   - Respond with "Approve" to trigger Phase B
   - The plan skill will automatically create the Linear Document and attach to the issue

2. Report completion:
   - List all registered plans
   - Provide links to the issues

## Issue Eligibility Criteria

An issue is eligible for planning if ALL of the following are true:

| Criterion                | How to Check                                                         |
| ------------------------ | -------------------------------------------------------------------- |
| State matches filter     | Issue state matches any value in `STATE` parameter (comma-separated) |
| Is a Leaf Task           | `children` array is empty                                            |
| No blocking dependencies | `relations` with type "blocks" are all Done                          |
| No existing plan         | `attachments` has no Document                                        |

## Error Handling

- If step-by-step fails during planning: Report error, continue with other issues
- If plan-review fails: Report error, ask user whether to skip or retry
- If Linear API fails: Report error, suggest manual registration

## Output

SUCCESS:
- REGISTERED_COUNT: Number of plans registered
- ISSUES: List of registered issue IDs with plan document links

ERROR: Error message string

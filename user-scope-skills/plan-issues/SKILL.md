---
name: plan-issues
description: "Use this skill for batch planning of project issues. Finds eligible issues, plans in parallel, auto-reviews, and registers to issue tracker.\n\nArgs:\n  PROVIDER=linear|jira (Optional) - Issue tracker provider (default: linear)\n  STATE=<state> (Optional) - Issue state filter (default: Todo,Backlog)\n  LIMIT=<n> (Optional) - Max issues to process in parallel (default: 4)\n\nExamples:\n  /plan-issues\n  /plan-issues STATE=Todo\n  /plan-issues LIMIT=6\n  /plan-issues PROVIDER=jira STATE=To Do"
model: claude-opus-4-5
---

# Description

> **CRITICAL ROLE CONSTRAINT**
>
> You are an **ORCHESTRATOR**, not an implementer. You delegate planning work to SubAgents and Skills.
> This skill coordinates multiple plan and plan-review executions in parallel.

Batch processes project issues by finding eligible ones, creating plans in parallel, and auto-reviewing before user approval.

## Subagent Selection

| Task | Subagent Type | Reason |
|------|---------------|--------|
| Planning each issue | `step-by-step-agent` | Executes plan-workflow skill with proper progress tracking |
| Reviewing each plan | `step-by-step-agent` | Executes plan-review skill with proper progress tracking |

## Behavior Rules

**MUST DO:**
- Delegate planning work to `plan-workflow` via Task tool
- Delegate review work to `plan-review` via Task tool
- Coordinate parallel execution of multiple issues
- Handle the review-fix loop between planning and review
- Present aggregated results for user approval

**MUST NOT:**
- Create plans directly (delegate to plan-workflow)
- Review plans directly (delegate to plan-review)
- Write to issue tracker directly (plan-workflow handles finalization)
- Skip the user approval step before registration

## Parameters

### Optional

- `PROVIDER` - Issue tracker provider: `linear` (default) or `jira`.
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

1. List issues based on PROVIDER:

   **For Linear:**
   ```
   skill: project-manage
   args: project PROVIDER=linear
   ```
   → Get PROJECT_ID from result

   ```
   skill: linear:linear-issue
   args: list PROJECT_ID=$PROJECT_ID STATE=$STATE FIRST=$LIMIT
   ```

   **For Jira:**
   ```
   mcp__jira__jira_search(
       jql="status in ($STATE) ORDER BY created DESC",
       limit=$LIMIT
   )
   ```

2. Filter results to find eligible issues:
   - **Leaf Task**: No sub-issues (children/subtasks)
   - **No Dependencies**: No blocking issues, or all blocking issues are Done
   - **No Plan Document/Attachment**: No Document (Linear) or plan attachment (Jira) attached

3. Select up to `LIMIT` issues for processing

4. If no eligible issues found, notify user and exit

### Step 2: Parallel Planning (Temporary Files)

1. For each selected issue, launch in parallel using Task tool:
   ```
   Task tool:
     subagent_type: step-by-step-agent
     prompt: /plan-workflow ISSUE_ID=$ISSUE_ID PROVIDER=$PROVIDER
     description: "Plan for $ISSUE_ID"
   ```

   > **Note**: The plan skill writes to a temporary file (via mktemp) first,
   > then waits for user approval via AskUserQuestion.
   > **Do NOT respond to this approval request yet** - proceed to Step 3.

2. Collect temporary plan file paths from each step-by-step

3. Track each plan skill's pending approval state

### Step 3: Parallel Review (Auto-Review)

1. For each temporary plan file, launch in parallel:
   ```
   Task tool:
     subagent_type: step-by-step-agent
     prompt: /plan-review PLAN_PATH=$TMP_PLAN_PATH ARTIFACT_DIR_PATH=.agent/tmp
     description: "Review plan for $ISSUE_ID"
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
   - Question: "The following issues have passed plan-review. Would you like to register them?"
   - Header: "Final Approval"
   - Options:
     - label: "Approve - Register"
       description: "Register all plans as Documents (Linear) or Attachments (Jira)"
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
   - The plan skill will automatically create the Document (Linear) or Attachment (Jira) and attach to the issue

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
| No existing plan         | No Document (Linear) or plan attachment (Jira) attached              |

## Error Handling

- If step-by-step fails during planning: Report error, continue with other issues
- If plan-review fails: Report error, ask user whether to skip or retry
- If issue tracker API fails: Report error, suggest manual registration

## Output

SUCCESS:
- REGISTERED_COUNT: Number of plans registered
- ISSUES: List of registered issue IDs with plan document links

ERROR: Error message string

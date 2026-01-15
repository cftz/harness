# Implement Workflow Skill

## Intent

Orchestrate a complete implementation cycle from plan execution through automated code review loops until code passes review, then finalize with git operations and Linear state updates. This skill eliminates manual intervention during the review-fix cycle, only requiring user approval at the final Pass result.

## Motivation

Manual implementation workflows require users to repeatedly invoke implement, code-review, and fix skills. This orchestrator automates the review loop, reducing cognitive overhead and ensuring consistent quality gates before finalization.

## Design Decisions

1. **Automated Review Loop**: Unlike plan-workflow and clarify-workflow where user feedback is collected during drafting, implement-workflow runs the review-fix loop automatically until Pass.
2. **USE_TEMP=true for Intermediate Reviews**: Review documents during the loop are saved to temp files since they are intermediate artifacts that may be replaced in subsequent cycles.
3. **User Approval at End**: User confirmation is requested only after code passes review, not during each fix cycle. This reduces interruptions while still providing a gate before finalization.
4. **Idempotent Finalization**: The finalize-implement step uses idempotent operations, making it safe to re-run the workflow.

## Constraints

- This skill should NOT read plan/task documents directly (delegated to implement skill)
- This skill should NOT write review documents (delegated to code-review skill)
- This skill should NOT make implementation decisions (handled by implement skill)
- User approval should NOT be requested during fix cycles, only at the final Pass

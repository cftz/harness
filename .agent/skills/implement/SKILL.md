---
name: implement
description: |
  Use this skill to execute implementation plans. IMPORTANT: Follow the plan strictly without adding extra features.

  Executes implementation plans exactly as specified without adding extra features.

  Commands:
    execute - Execute implementation from plan (default)
      Source (OneOf, Required):
        PLAN_PATH=<path> + TASK_PATH=<path> - Local plan and requirements files
        ISSUE_ID=<id> - Linear Issue ID (plan from Document, requirements from description)
    fix - Fix code based on review feedback
      Source (OneOf, Required):
        PLAN_PATH=<path> + REVIEW_PATH=<path> - Local plan and review files
        ISSUE_ID=<id> [REVIEW_PATH=<path>] - Linear Issue (auto-finds Review Document if REVIEW_PATH omitted)

  Examples:
    /implement execute ISSUE_ID=TA-123
    /implement execute PLAN_PATH=.agent/artifacts/20260107/02_plan.md TASK_PATH=.agent/artifacts/20260107/01_task.md
    /implement fix ISSUE_ID=TA-123
    /implement fix PLAN_PATH=.agent/artifacts/20260107/02_plan.md REVIEW_PATH=.agent/artifacts/20260107/03_review.md
model: claude-opus-4-5
context: fork
agent: step-by-step-agent
---

# Implement Skill

Executes implementation plans exactly as specified. This skill takes a plan document and requirements (from local files or Linear) and implements code strictly according to the plan without adding features or making arbitrary decisions.

## Commands

| Command   | Description                                | Docs                              |
| --------- | ------------------------------------------ | --------------------------------- |
| `execute` | Execute implementation from plan (default) | `{baseDir}/references/execute.md` |
| `fix`     | Fix code based on review feedback          | `{baseDir}/references/fix.md`     |

## Output Format

Report the implementation result:

**On Success**:
```
Implementation completed successfully.

Files created/modified:
- path/to/file1.go
- path/to/file2.go

Verification:
- go build ./... ✓
- go test ./... ✓

Acceptance Criteria:
- [x] AC item 1
- [x] AC item 2
```

**On Problems**:
```
Implementation encountered issues:

Problem: [Description of the problem]
Location: [File and context where it occurred]
Cause: [Why following the plan caused this issue]
Suggestion: [Recommended fix or plan adjustment needed]
```

## Constraints

1. **No Feature Creep**: Implement ONLY what the plan/review specifies
2. **No Arbitrary Decisions**: If something is ambiguous, ask - do not decide
3. **No Over-Engineering**: Do not add error handling, validation, or optimizations beyond the plan
4. **No Extra Comments**: Do not add docstrings or comments not specified in the plan
5. **Strict Adherence**: The plan is your source of truth

## Quality Checklist

Before reporting completion:
- [ ] All files listed in plan are created/modified
- [ ] All function signatures match the plan exactly
- [ ] No extra features or code added beyond the plan
- [ ] All success criteria (if any) are verified
- [ ] Build and tests pass (if specified)
- [ ] Acceptance Criteria from requirements/review are checked

# Linear Review Document

Instructions for fetching a Review Document from Linear when using `ISSUE_ID` without explicit `REVIEW_PATH`.

## Process

### 1. List Documents Attached to Issue

Use the `linear-document` skill to list all documents attached to the issue:

```
skill: linear-document
args: list ISSUE_ID={ISSUE_ID}
```

### 2. Identify Review Document

From the returned list, find the Review Document by filtering:

1. **Title Pattern**: Document title starts with "Review Result"
2. **Status Pattern**: Document contains "Status: Changes Required"

If multiple Review Documents exist, select the **most recently updated** one.

### 3. Fetch Review Content

Once identified, fetch the full content:

```
skill: linear-document
args: get ID={DOCUMENT_ID}
```

### 4. Parse Review Structure

The Review Document follows this structure:

```markdown
# Review Result

**Status**: Changes Required

## Request Summary
[Brief description of what needs to be fixed]

## Acceptance Criteria
- [ ] [Specific fix for violation 1]
- [ ] [Specific fix for violation 2]

## Scope
### In Scope
- Fix identified rule violations

### Out of Scope
- Any other refactoring or improvements

## Violations Found
| File | Line | Rule | Issue | Suggested Fix |
| ... | ... | ... | ... | ... |

## Rules References
- [Rule files that were applied]
```

Extract:
- **Acceptance Criteria**: The checklist of fixes to implement
- **Violations Found**: The detailed table of issues with file:line references
- **Rules References**: The rule files to read for context

## Error Handling

- If no documents are attached to the issue: Report error "No documents attached to issue {ISSUE_ID}"
- If no Review Document is found: Report error "No Review Document found for issue {ISSUE_ID}. Run code-review first."
- If Review Document status is "Pass": Report "Review status is Pass. No fixes required."

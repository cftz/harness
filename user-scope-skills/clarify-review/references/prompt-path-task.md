# Prompt Path Task Loading

Instructions for loading task source from direct file paths.

## When to Use

Use this reference when `PROMPT_PATH` and `DRAFT_PATHS` parameters are provided.

## Process

### 1. Read Prompt File

Read the prompt file from `PROMPT_PATH`:

```
Read: {PROMPT_PATH}
```

Extract from the prompt file:
- **Source type**: REQUEST or ISSUE_ID (from YAML frontmatter)
- **Original request**: Content from "Original Request" section
- **Context**: Additional context (if present)

### 2. Read Draft Files

Read each draft task document from `DRAFT_PATHS` (comma-separated):

```
Read: {draft_path_1}
Read: {draft_path_2}
...
```

For each draft, extract:
- **Task name**: From YAML frontmatter `name` field
- **Dependencies**: From YAML frontmatter `blockedBy` field
- **Acceptance Criteria**: From "Acceptance Criteria" section
- **Scope**: From "Scope" section (In Scope / Out of Scope)
- **Constraints**: From "Constraints" section
- **Questions Resolved**: From "Questions Resolved" section

### 3. Return Loaded Data

Provide the loaded data for review:

```
Prompt:
  Source: {REQUEST | ISSUE_ID}
  Original Request: {content}
  Context: {optional context}

Drafts:
  - Name: {task_name_1}
    Path: {draft_path_1}
    Dependencies: {blockedBy list}
    Acceptance Criteria: {criteria list}
    Scope: {in/out scope}

  - Name: {task_name_2}
    Path: {draft_path_2}
    ...
```

## Error Handling

- If `PROMPT_PATH` file does not exist, report error and stop
- If any file in `DRAFT_PATHS` does not exist, report error and stop
- If YAML frontmatter is malformed, report which file and what's missing

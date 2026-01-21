# Plan Path Task Document

This document defines how to load a plan from a direct file path.

## Input

- `PLAN_PATH` - Direct path to plan file (e.g., `.agent/tmp/plan.md`)

## Process

1. Verify the file exists at `PLAN_PATH`
2. Read the file content using Read tool
3. Parse YAML frontmatter to extract:
   - `title`: Plan title
   - `issueId`: Associated issue ID (optional)
4. Parse content sections:
   - Overview
   - Package Changes (if present)
   - Implementation Steps
   - Summary of Changes

## Output

After reading the plan document, you should have:

- **Plan title**: From frontmatter
- **Issue ID**: From frontmatter (if present)
- **Target file list**: All files mentioned in the plan
- **Implementation details**: Steps with code outlines

## Example

```
PLAN_PATH: .agent/tmp/plan.md

File content:
---
title: Add User Authentication
issueId: TA-123
---

## Overview
...

## Implementation Steps
...

Extracted:
- Title: Add User Authentication
- Issue ID: TA-123
- Target files: internal/service/auth/auth.go, etc.
```

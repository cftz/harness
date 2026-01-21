# Linear Guide

## Intent

A guideline skill to ensure consistent behavior patterns when performing Linear-related tasks. It enforces using Skills instead of MCP and requires specifying mandatory parameters when listing issues.

## Motivation

Problems that occur in Linear tasks:
1. Inconsistent code generation due to mixed use of MCP and Skills
2. Excessive data requests due to missing parameters when listing issues
3. Inefficiency of fetching all issues without project/state filters

This skill provides behavioral guidelines to prevent these problems.

## Design Decisions

1. **user-invocable: false**: Not directly invoked by users, but automatically referenced when performing Linear tasks
2. **Skill-first principle**: MCP is only used for features not supported by Skills
3. **Required parameter specification**: PROJECT_ID, STATE, FIRST are mandatory when listing issues

## Constraints

- This skill does not perform actual Linear operations (provides guidelines only)
- This document needs to be updated when new Linear Skills are added
- MCP usage is allowed as an exception when unavoidable

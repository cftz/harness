# linear-cycle

Manage Linear cycles - get active cycle and add issues to cycles.

## Intent

Provide a reusable interface for Linear cycle operations. This skill enables workflows (like `finalize-plan`) to automatically assign issues to the current active sprint/cycle, improving issue tracking and sprint planning automation.

## Commands

| Command | Description |
|---------|-------------|
| `get-active TEAM_ID=<id>` | Get active cycle for a team |
| `add-issue ISSUE_ID=<id> CYCLE_ID=<id>` | Add issue to a cycle |

## Examples

```bash
# Get active cycle for a team
/linear-cycle get-active TEAM_ID=abc-123-def

# Add issue to cycle
/linear-cycle add-issue ISSUE_ID=TA-123 CYCLE_ID=cycle-uuid-456
```

## Environment Variables

- `LINEAR_API_KEY` - Linear API key for authentication (required)

## See Also

- [SKILL.md](./SKILL.md) - Skill definition
- [references/get-active.md](./references/get-active.md) - get-active command docs
- [references/add-issue.md](./references/add-issue.md) - add-issue command docs

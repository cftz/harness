---
trigger: always_on
globs: **/*.{ts,tsx}
paths: **/*.{ts,tsx}
---

# TypeScript Rules

## Type Assertion Rules

### Avoid type assertions (`as`)

- Prefer type guards or `satisfies` over `as` assertions
- Type assertions bypass TypeScript's type checking and can hide bugs
- Use `as` only in test files or when absolutely necessary

```ts
// Wrong: Type assertion
const trigger = data.trigger as PollingTrigger;
const condition = trigger.condition as FactCondition;

// Correct: Type guard function
function isPollingTrigger(t: Trigger): t is PollingTrigger {
  return t.type === TriggerType.POLLING;
}

if (isPollingTrigger(data.trigger)) {
  // data.trigger is now PollingTrigger
  const condition = data.trigger.condition; // type-safe access
}

// Correct: satisfies (for type checking without widening)
const config = {
  host: 'localhost',
  port: 3000,
} satisfies ServerConfig;
```

### When `as` is acceptable

1. **Test files** (`*.spec.ts`, `*.test.ts`) - Mocking often requires type assertions
2. **Type narrowing after runtime check** - When you've already validated the type
3. **DOM element selection** - `document.querySelector('input') as HTMLInputElement`
4. **External API responses** - After validation with zod/io-ts/etc.

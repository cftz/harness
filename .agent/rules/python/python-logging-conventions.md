---
trigger: always_on
globs: **/src/**/*.py
paths: **/src/**/*.py
---

# Logging Conventions

This document defines logging standards for all Python code under `src/`.

## Logger Injection

**ALWAYS inject logger as the first parameter in constructors:**

```python
import structlog

class UserService:
    def __init__(self, logger: structlog.BoundLogger, repo: UserRepositoryPort):
        self.logger = logger.bind(name="user.service")
        self.repo = repo
```

**Key points:**
- Logger is ALWAYS the first parameter (after `self`)
- Type hint: `structlog.BoundLogger`
- Bind context immediately in `__init__`

## Logger Binding

### Bind in Constructor

ALWAYS bind logger context in `__init__`:

```python
def __init__(self, logger: structlog.BoundLogger, ...):
    self.logger = logger.bind(name="...")  # Bind immediately
```

**Logger naming patterns:**
- See layer-specific files for naming conventions (e.g., [python-inbound.md](./python-inbound.md), [python-outbound.md](./python-outbound.md), [python-service.md](./python-service.md))

## Logging Best Practices

### Include Context in Errors

```python
try:
    result = await self.repo.get(user_id)
except Exception as e:
    self.logger.error("failed to get user", user_id=user_id, error=str(e))
    raise
```

### Log Important State Changes

```python
async def update_status(self, order_id: str, status: OrderStatus):
    self.logger.info("updating order status",
                     order_id=order_id,
                     old_status=old_status,
                     new_status=status)
```

## Summary

- **Inject logger**: First parameter in all constructors (`logger: structlog.BoundLogger`)
- **Bind immediately**: `self.logger = logger.bind(name="...")` in `__init__`
- **Naming patterns**: See layer-specific documentation
- **Structured logging**: Use keyword arguments, not string formatting
- **Appropriate levels**: debug, info, warning, error
- **No sensitive data**: Never log passwords, tokens, or secrets
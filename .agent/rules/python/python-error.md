---
trigger: always_on
globs: **/src/**/*.py
paths: **/src/**/*.py
---

# Error Handling Guidelines

This document defines error handling conventions for all code under `src/`.

## Error Types (errutil)

All application errors are defined in `src/platform/util/errutil/`:

```python
from src.platform.util.errutil import (
    BadRequestError,    # 400 - Invalid input/request
    UnauthorizedError,  # 401 - Authentication required
    ForbiddenError,     # 403 - Permission denied
    NotFoundError,      # 404 - Resource not found
    InternalError,      # 500 - Internal server error
)
```

**Error Hierarchy:**
```
AppError (base)
├── BadRequestError
├── UnauthorizedError
├── ForbiddenError
├── NotFoundError
└── InternalError
```

## Error Handling by Layer

### Service Layer

Distinguish between managed errors (errutil) and external errors:

```python
async def create_agent(self, resource: Resource, agent: Agent) -> Agent:
    # 1. Check permissions
    if not await self.rbac_svc.can_write_agent(resource):
        raise ForbiddenError("Cannot write agent")

    # 2. Business logic with error handling
    try:
        return await self.repo.create(agent)
    except (BadRequestError, NotFoundError, ForbiddenError):
        # Managed errors - re-raise as-is
        raise
    except Exception as e:
        # External/unexpected error - wrap with context
        raise InternalError("Failed to create agent") from e
```

**Rules:**
1. **Managed errors**: Re-raise directly (preserve original exception)
2. **External errors**: Wrap with appropriate errutil exception using `from`
3. **Never suppress**: Always log or re-raise

### Inbound Layer (HTTP Handlers)

Handlers should NOT catch exceptions - let them propagate to the global exception handler:

```python
# CORRECT - Let exceptions propagate
async def get_user(self, user_id: str) -> User:
    result = await self.svc.get_user(user_id)
    if result is None:
        raise NotFoundError(f"User {user_id} not found")
    return result

# WRONG - Don't catch and handle in handler
async def get_user(self, user_id: str) -> User:
    try:
        return await self.svc.get_user(user_id)
    except NotFoundError:
        return JSONResponse(status_code=404, ...)  # Don't do this!
```

### Global Exception Handler (FastAPI)

The global exception handler converts errutil exceptions to HTTP responses:

```python
# Registered in platform/util/fastapiutil/exception_handler.py

async def errutil_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    if isinstance(exc, BadRequestError):
        return JSONResponse(status_code=400, content={"detail": str(exc)})
    elif isinstance(exc, UnauthorizedError):
        return JSONResponse(status_code=401, content={"detail": str(exc)})
    # ... etc
```

**Error Mapping:**

| errutil Error     | HTTP Status               |
| ----------------- | ------------------------- |
| BadRequestError   | 400 Bad Request           |
| UnauthorizedError | 401 Unauthorized          |
| ForbiddenError    | 403 Forbidden             |
| NotFoundError     | 404 Not Found             |
| InternalError     | 500 Internal Server Error |

### Outbound Layer (Repository)

Repositories should raise errutil exceptions:

```python
async def get(self, user_id: str) -> User | None:
    doc = await self.collection.find_one({"_id": ObjectId(user_id)})
    if not doc:
        return None  # Let service layer decide how to handle
    return UserSchema(**doc).to_domain()

async def create(self, user: User) -> User:
    try:
        result = await self.collection.insert_one(...)
    except DuplicateKeyError:
        raise BadRequestError("User already exists")
    # ...
```

## Best Practices

1. **Use errutil exceptions**: All business errors should use errutil types
2. **Preserve stack traces**: Use `raise ... from e` for wrapped exceptions
3. **Include context**: Error messages should include relevant IDs/context
4. **Never suppress**: Always log or re-raise exceptions
5. **Layer responsibility**: Service raises, handler propagates, global handler converts

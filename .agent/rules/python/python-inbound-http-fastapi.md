---
trigger: glob
globs: **/src/service/*/inbound/http/fastapi/*
paths: **/src/service/*/inbound/http/fastapi/*
---

# FastAPI HTTP Inbound Handler Guidelines

This document defines guidelines specific to FastAPI implementation of HTTP handlers.

## Handler Implementation Pattern

### File: `{domain}/inbound/http/fastapi/{feature}.py`

```python
import structlog
from fastapi import APIRouter, status
from src.service.{domain} import Service
from src.platform.domain import {Domain}
from src.service.{domain}.inbound.http.{feature}_handler_port import (
    {Feature}HandlerPort,
    {HandlerName}ReqBody,
)

class {Feature}HTTPHandler({Feature}HandlerPort):  # See python-port-adapter-pattern.md for Protocol pattern
    def __init__(self, logger: structlog.BoundLogger, svc: Service):
        self.logger = logger.bind(name="{domain}.http.fastapi.{feature}")
        self.svc = svc
        self.router = APIRouter(prefix="/{feature}/{version}", tags=["{feature}"])
        self._register_routes()

    def _register_routes(self):
        """Register all routes - called in __init__"""
        self.router.{method}({path})(self.{handlerName})
        # ...

    async def {handlerName}(self, body: {HandlerName}ReqBody) -> {Domain}:
        # Handler method - just call service, exceptions handled by middleware
        return await self.svc.create_{domain}(data)
```

### Key Components

1. **Router Setup**: Create `APIRouter` in `__init__` with prefix and tags
2. **Route Registration**: Register routes in `_register_routes()` method
3. **No Try/Except**: Let exceptions propagate to global exception handler
4. **Type Hints**: Use Pydantic models for request/response

## Error Handling (Global)

For error types and handling patterns, see [python-error.md](./python-error.md).

Error handling is done globally using FastAPI exception handlers defined in `platform/util/fastapiutil`. The global handler converts errutil exceptions to HTTP responses automatically.

### Register in Application

```python
# command/container/register_fastapi.py
from fastapi import FastAPI
from src.platform.util.fastapiutil.exception_handler import register_exception_handlers

def register_fastapi(container: ApplicationContainer) -> FastAPI:
    app = FastAPI()

    # Register exception handlers
    register_exception_handlers(app)

    # Register all HTTP handlers
    for handler in container.http_handlers():
        app.include_router(handler.router)

    return app
```

### Handler Usage

Handlers should **NOT** catch exceptions - let them propagate to the global exception handler:

```python
async def get_user(self, user_id: str) -> User:
    result = await self.svc.get_user(user_id)
    if result is None:
        raise NotFoundError(f"User {user_id} not found")  # Global handler converts to 404
    return result
```

**Key principle**: Handlers raise exceptions, global handler converts to HTTP responses. See [python-error.md](./python-error.md) for error mapping table.

## Complete Example: User Service

```python
# user/inbound/http/fastapi/user.py
import structlog
from fastapi import APIRouter, status
from src.service.user import Service
from src.platform.domain import User
from src.service.user.inbound.http.user_handler_port import (
    UserHandlerPort,
    CreateUserReqBody,
)

class UserHTTPHandler(UserHandlerPort):  # Protocol inheritance required
    def __init__(self, logger: structlog.BoundLogger, svc: Service):
        self.logger = logger.bind(name="user.http.fastapi.user")
        self.svc = svc
        self.router = APIRouter(prefix="/users", tags=["users"])
        self._register_routes()

    def _register_routes(self):
        self.router.post("/")(self.create_user)
        self.router.get("/{user_id}")(self.get_user)

    async def create_user(self, body: CreateUserReqBody) -> User:
        return await self.svc.create_user(body)

    async def get_user(self, user_id: str) -> User | None:
        return await self.svc.get_user(user_id)
```

## Best Practices

1. **Protocol inheritance**: Handlers must inherit Port Protocol (see [python-port-adapter-pattern.md](./python-port-adapter-pattern.md))
2. **Import from handler_port**: Import Protocol and DTOs from `{feature}_handler_port.py`
3. **Class-based handlers**: Use handler classes with `router` attribute
4. **Route registration**: Register routes in `_register_routes()` method
5. **No try/except in handlers**: Let exceptions propagate to global exception handler
6. **Raise NotFoundError**: When resource not found, raise exception (don't return None)
7. **Type hints**: Use Pydantic models for validation (see [python-pydantic.md](./python-pydantic.md))
8. **Async**: Use `async def` for all handler methods
9. **Dependencies**: Use FastAPI's `Depends()` for auth and other cross-cutting concerns
---
trigger: glob
globs: **/src/service/*/inbound/http/**/*
paths: **/src/service/*/inbound/http/**/*
---

# HTTP Inbound Handler Port Guidelines

This document defines HTTP-specific patterns for inbound handlers.

## HTTP-Specific DTO Rules

### Pydantic configurations

For general Pydantic conventions, see [python-pydantic.md](./python-pydantic.md).

HTTP-specific notes:
- **camelCase Serialization**: HTTP APIs typically use camelCase in JSON
- **Field Validation**: Use `Field()` for input validation constraints at the HTTP boundary

### Request/Response Body Naming

**Request Body:** `{HandlerName}ReqBody`
**Response Body:** `{HandlerName}ResBody`

```python
# Request DTOs
class CreateUserReqBody(BaseModel): ...
class UpdateUserReqBody(BaseModel): ...
class LoginReqBody(BaseModel): ...

# Response DTOs (only when necessary - see guidelines below)
class CreateUserResBody(BaseModel): ...
class LoginResBody(BaseModel): ...
```

### Naming Guidelines

- **Action-specific names**: Use specific action verbs (Create, Update, Get, Delete, Login, etc.)
- **Request bodies**: For POST/PUT/PATCH endpoints
- **Response bodies**: Only when return type differs from domain model (see guidelines below)
- **Prefer domain models**: Return domain model directly when appropriate

### Request DTOs - HTTP Exception

**Unlike other layers**, HTTP Request DTOs can be created more liberally because:
- **Validation at boundary**: Need to validate all external input
- **Different constraints**: Validation requirements often differ from domain models
- **Security**: Input structure may not match domain model exactly
- **Type safety**: Catch invalid data before it reaches business logic

This is an **exception** to the general "be conservative with DTOs" rule in [python-port-adapter-pattern.md](./python-port-adapter-pattern.md).

## Port Patterns

HTTP inbound handlers follow the standard inbound adapter pattern. For Port file organization, naming conventions, and Protocol inheritance requirements, see [python-inbound.md](./python-inbound.md).

**See also:**
- [python-inbound-http-fastapi.md](./python-inbound-http-fastapi.md) - FastAPI-specific implementation details

## Examples

### File structure example
```
{domain}/inbound/http/
├── user_handler_port.py    # UserHandlerPort Protocol + DTOs
├── account_handler_port.py # AccountHandlerPort Protocol + DTOs
└── fastapi/
    ├── user_handler.py      # UserHTTPHandler implements UserHandlerPort
    └── account_handler.py   # AccountHTTPHandler implements AccountHandlerPort
```

### Complete Example

```python
# user/inbound/http/user_handler_port.py
from typing import Protocol
from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel
from src.platform.domain import User

# Request DTOs (create freely for validation)
class CreateUserReqBody(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    username: str = Field(min_length=3, max_length=50)
    email: str = Field(pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    password: str = Field(min_length=8)
    age: int = Field(ge=0, le=150)

class UpdateUserReqBody(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    username: str | None = Field(default=None, min_length=3, max_length=50)
    email: str | None = Field(default=None, pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")

# Response DTO (ONLY when domain has sensitive fields)
class UserPublicResBody(BaseModel):
    """Public user info - excludes sensitive fields like password"""
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    id: str
    username: str
    email: str
    # Excludes: password, internal_user_id, etc.

# Handler Port (Protocol)
class UserHandlerPort(Protocol):
    # Return Response DTO when domain has sensitive fields
    async def create_user(self, body: CreateUserReqBody) -> UserPublicResBody: ...
    async def update_user(self, user_id: str, body: UpdateUserReqBody) -> UserPublicResBody: ...

    # Return domain model directly (PREFERRED when safe)
    async def get_user(self, user_id: str) -> User | None: ...
    async def list_users(self, skip: int, limit: int) -> list[User]: ...

    # Simple operations
    async def delete_user(self, user_id: str) -> bool: ...
```

## Best Practices

1. **Be conservative with DTOs**: Prefer domain models, create DTOs only when necessary
2. **Reuse existing models**: Check for shared/common models before creating new ones
3. **Port + DTOs in same file**: Keep Handler Port Protocol and DTOs together in `{feature}_handler_port.py`
4. **Explicit Protocol inheritance**: Handlers must inherit Protocol for pyright enforcement
5. **camelCase serialization**: Always use `ConfigDict(alias_generator=to_camel, populate_by_name=True)`
6. **Field validation**: Use Pydantic `Field` for constraints (min_length, pattern, etc.)
7. **Modern type syntax**: Use `T | None` instead of `Optional[T]`
8. **Optional fields with defaults**: Optional fields must have default values
9. **Descriptive DTO names**: Use specific action names (Create, Update, Get, etc.)
10. **Return domain models by default**: Only create response DTOs when transformation or security requires it
11. **Request DTOs more liberal**: Create request DTOs freely for validation purposes
12. **Validate at boundaries**: DTOs are the validation layer - validate all input here
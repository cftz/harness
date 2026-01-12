---
trigger: glob
globs: **/src/service/**/inbound/**/*, **/src/service/**/outbound/**/*, **/src/platform/outbound/**/*
paths: **/src/service/**/inbound/**/*, **/src/service/**/outbound/**/*, **/src/platform/outbound/**/*
---

# Port/Adapter Pattern (Hexagonal Architecture)

This document explains the Port/Adapter pattern used throughout the codebase for both inbound and outbound dependencies.

**For detailed layer-specific guidelines, see:**
- [python-inbound.md](./python-inbound.md) - Inbound adapter implementation details
- [python-inbound-http.md](./python-inbound-http.md) - HTTP handler specifics
- [python-outbound.md](./python-outbound.md) - Outbound adapter implementation details

## Core Concept

The Port/Adapter pattern (also known as Hexagonal Architecture) separates:
- **Port (Protocol)**: Interface defining what operations are available
- **Adapter (Implementation)**: Concrete implementation of those operations

### Pattern Formula

```
Port (Protocol) → Adapter (Implementation)
```

**Examples:**
```
UserRepositoryPort (Protocol) → MongoUserRepository (Adapter)
UserHandlerPort (Protocol) → UserHTTPHandler (Adapter)
EmailServicePort (Protocol) → SendGridEmailService (Adapter)
```

## Protocol Pattern in Python

### Using typing.Protocol

Python's `typing.Protocol` enables structural subtyping (duck typing with type checking):

```python
from typing import Protocol
from src.platform.domain import User

class UserRepositoryPort(Protocol):
    """Port defining repository operations"""
    async def create(self, user: User) -> User: ...
    async def get(self, user_id: str) -> User | None: ...
    # ...
```

**Key features:**
- Methods end with `...` (Ellipsis)
- No implementation, just signatures
- Defines the contract

## Protocol Implementation Enforcement

### Explicit Inheritance (REQUIRED)

Adapters MUST explicitly inherit Protocol for pyright enforcement:

```python
# Port definition
from typing import Protocol
from src.platform.domain import User

class UserRepositoryPort(Protocol):
    async def create(self, user: User) -> User: ...
    async def get(self, user_id: str) -> User | None: ...

# Adapter implementation
import structlog
from motor.motor_asyncio import AsyncIOMotorDatabase
from src.service.user.outbound.repository.user_repo_port import UserRepositoryPort

class MongoUserRepository(UserRepositoryPort):  # Inherit Protocol explicitly
    """Pyright checks all methods are implemented with correct signatures"""

    def __init__(self, db: AsyncIOMotorDatabase, logger: structlog.BoundLogger):
        self.db = db
        self.logger = logger

    async def create(self, user: User) -> User:
        # Implementation here
        ...

    async def get(self, user_id: str) -> User | None:
        # Implementation here
        ...
```

## DTO Model Patterns

DTOs (Data Transfer Objects) are Pydantic models used in Port definitions for data validation and serialization. This section defines common patterns that apply across all adapters (both inbound and outbound).

### Pydantic Rules

For Pydantic model conventions (ConfigDict, Field validation, etc.), see [python-pydantic.md](./python-pydantic.md).

### DTOs vs Domain Models

**IMPORTANT - Be Conservative with DTOs:**
- **Default to domain models**: Return domain models directly when safe
- **Check for existing models**: Before creating DTOs, verify if shared/common models exist
- **Minimize code**: Only create DTOs when absolutely necessary
- **Avoid symmetry for sake of symmetry**: Don't create response DTOs just because request DTOs exist

#### When to Use DTOs

Create dedicated DTOs **only when**:
1. Domain model contains security-sensitive fields (passwords, internal IDs)
2. Response/output requires computed/derived fields not in domain
3. Data format significantly differs from domain model
4. Need to combine multiple domain models
5. Input validation requirements differ from domain model constraints

#### When to Return Domain Models Directly (PREFERRED)

Return domain models directly when:
1. Domain model is safe to expose (no sensitive fields)
2. No transformation or computation needed
3. Domain model already has proper serialization config
4. Data structure matches domain model

## File Organization Principles

### General Structure

```
{domain}/{layer}/{category}/
├── {name}_port.py      # Port (Protocol) + Models
└── {implementation}/   # Implementation directory
    ├── {helpers}.py    # Optional: Common helper functions
    └── {name}.py       # Adapter (Implementation)
```

**Naming Pattern:** Port and implementation share the same base name

#### Port Files

**Naming:** `{name}_port.py` (e.g., `user_repo_port.py`, `user_handler_port.py`)

**Contents:**
1. **Protocol definition**: Interface with method signatures
2. **Models** (optional): DTOs or data models used by the protocol

**Purpose:**
- Define contract between layers
- Enable multiple implementations
- Provide type safety

#### Adapter Files

**Naming:** `{name}.py` matching the port's base name (e.g., `user_repo.py`, `user_handler.py`)

**Contents:**
- Concrete implementation of Port Protocol
- Technology-specific logic
- Error handling
- Resource management

## Container Integration

**Key principle**: Container injects concrete adapters, but services receive Port types.

```python
import structlog
from src.service.user.outbound.repository.user_repo_port import UserRepositoryPort

class UserService:
    def __init__(self, logger: structlog.BoundLogger, repo: UserRepositoryPort):  # Port type
        self.logger = logger
        self.repo = repo  # Works with any adapter implementing the Port
```

This allows:
- **Flexibility**: Container can inject `MongoUserRepository`, `PostgresUserRepository`, or any adapter
- **Type Safety**: Service depends on Port interface, not concrete implementation
- **Testability**: Easy to inject mock adapters for testing

For detailed container configuration patterns, see [python-container.md](./python-container.md).

## Best Practices

1. **Always use explicit Protocol inheritance**: Adapters must inherit Protocol for type checking
2. **Port in one file**: Keep Protocol and related models together
3. **Consistent naming**: Port (`{name}_port.py`) and implementation (`{name}.py`) share base name
4. **One adapter per file**: Each implementation in its own file
5. **Full type annotations**: All parameters and return types must be typed
6. **Async by default**: Use `async def` for all I/O operations
7. **Ellipsis for Protocol methods**: Use `...` (not `pass`) in Protocol definitions
8. **Descriptive names**: `UserRepositoryPort`, `MongoUserRepository` (not `UserRepo`, `Mongo`)

## Summary

- **Port (Protocol)**: Interface defining operations (`user_repo_port.py`)
- **Adapter (Implementation)**: Concrete technology-specific code (`mongodb/user_repo.py`)
- **Explicit inheritance**: Adapters MUST inherit Protocol for type safety
- **Full type annotations**: All __init__ parameters and method signatures must be typed
- **Consistent naming**: Port and implementation share base name (`user_repo_port.py` → `user_repo.py`)
- **Type safety**: Pyright enforces all methods implemented with correct signatures
- **Flexibility**: Easy to swap implementations (MongoDB → PostgreSQL)
- **Testability**: Easy to mock Port interface for testing

This pattern is used consistently across:
- **Inbound adapters**: HTTP, workers, WebSocket (see [python-inbound.md](./python-inbound.md))
- **Outbound adapters**: Repositories, external services, infrastructure (see [python-outbound.md](./python-outbound.md))
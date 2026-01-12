---
trigger: always_on
globs: **/src/**/*.py
paths: **/src/**/*.py
---

# Src Package Guidelines

This document defines the coding standards and architectural patterns for the Python codebase.

## Architecture Overview

This package follows **Hexagonal Architecture** (Ports and Adapters) with clear separation of concerns:

```
src/
├── platform/     # Shared infrastructure, utilities, and domain models
├── service/      # Business logic organized by domain
└── command/      # Application entry points (moved from cmd/)
```

## General Rules

### Package Structure
- Each service follows the hexagonal pattern with `inbound`, `outbound`, and core business logic
- Dependencies flow inward: `inbound → service → outbound`
- Never import from `inbound` packages into service or outbound layers

### Service Isolation

**CRITICAL RULE: Service Independence**

Each service (except Core) MUST be completely independent. Services cannot directly import or depend on other services.

**FORBIDDEN - Cross-Service Imports:**
- ❌ WRONG: `from src.service.user import Service` in `address` service
- ❌ WRONG: Importing another service's inbound/outbound code

**ALLOWED - Cross-Service Dependencies:**

1. **Core services**: Services under `src/service/core/` can be injected into other services
2. **Platform components**: All platform modules can be used across services:
   - `src/platform/domain/` - Shared domain models
   - `src/platform/util/` - Shared utilities
   - `src/platform/outbound/` - Shared outbound adapters (email, S3, Redis, etc.)

**Examples:**

```python
# ❌ WRONG - address service importing user service directly
from src.service.user import Service  # FORBIDDEN

# ✅ CORRECT - using Core service (if exists)
from src.service.core.auth import AuthService  # OK - Core services can be injected

# ✅ CORRECT - using platform components
from src.platform.domain import User  # OK - shared domain models
from src.platform.util.errutil import NotFoundError  # OK - shared utilities
from src.platform.outbound.email import EmailService  # OK - shared outbound adapters
```

### Dependency Injection
- All dependencies MUST be injected through constructors (`__init__`)
- Use `dependency-injector` for DI container management
- Return concrete types from constructors, not interfaces

### Error Handling
- Use custom exception classes for all error types
- Define exception hierarchy in `platform/util/errutil`
- Raise appropriate exceptions with clear error messages
- Never suppress exceptions without logging

### Async/Await
- Always use `async/await` for I/O operations
- Service methods that perform I/O should be `async`
- Use `asyncio` primitives for concurrency

### Type Usage
- Use type hints for all function signatures
- Use Pydantic models for request/response types (see [python-pydantic.md](./python-pydantic.md))
- Enable pyright strict mode for type checking

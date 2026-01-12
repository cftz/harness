---
trigger: always_on
globs: **/src/platform/**/*
paths: **/src/platform/**/*
---

# Platform Package Guidelines

The platform package contains shared infrastructure, utilities, domain models, and setup code used across all services.

## Directory Structure

```
src/platform/
├── domain/       # Core domain models and business entities
├── outbound/     # External service implementations (storage, etc.)
├── pkg/          # Reusable packages safe for external import
├── setup/        # Application initialization and configuration
├── structure/    # Shared data structures (cursor, resource, etc.)
└── util/         # Utility packages and helpers
```

## Domain Package (`domain/`)

### Domain Models
- Define core business entities (User, Organization, Agent, etc.)
- Use Pydantic BaseModel for all domain models
- Keep domain models framework-agnostic
- Include validation logic within domain models using Pydantic validators

### Naming Conventions
- Domain models: Singular nouns (e.g., `Agent`, `Organization`)
- Enums: Use `StrEnum` (Python 3.11+)

Example:
```python
from pydantic import BaseModel
from enum import StrEnum

class MemberRole(StrEnum):
    OWNER = "owner"
    ADMIN = "admin"
    MEMBER = "member"

class Member(BaseModel):
    id: str
    role: MemberRole
```

### MongoDB Schemas
- Place MongoDB-specific schemas in `domain/mongoschema/`
- Use `{Model}Schema` naming pattern
- Define collection and field constants to avoid magic strings

For detailed mongoschema guidelines, see [python-platform-domain-mongoschema.md](./python-platform-domain-mongoschema.md)

## Outbound Package (`outbound/`)
- Contains common outbound adapters that can be shared across multiple services
- **IMPORTANT**: Add new implementations very conservatively - only when truly reusable
- Most outbound implementations should remain in individual service packages

### Decision Matrix: Platform vs Service Outbound

Use this matrix to decide whether an outbound adapter belongs in `platform/outbound/` or `service/{domain}/outbound/`:

| Criteria | Platform Outbound | Service Outbound |
|----------|-------------------|------------------|
| **Usage** | Used by 3+ services | Used by 1-2 services |
| **Logic** | No domain-specific logic | Contains domain-specific logic |
| **Examples** | Email, SMS, S3, Redis | UserRepository, OrderRepository |
| **Coupling** | Technology coupling only | Business logic coupling |

**Use `platform/outbound` when:**
- Adapter is used by 3 or more different services
- Pure infrastructure concern (email, storage, cache)
- No domain-specific business logic
- Technology-agnostic interface
- Examples: EmailService, S3Storage, RedisCache, SMSGateway, PaymentGateway

**Use `service/{domain}/outbound` when:**
- Domain-specific repository (UserRepository, ProductRepository, OrderRepository)
- Contains domain business logic in queries or transformations
- Used only by this service (or 1-2 services)
- Tightly coupled to domain models
- Examples: UserRepository, ProductRepository, OrderRepository, InvoiceRepository

**When in doubt:**
- Start with `service/{domain}/outbound`
- Move to `platform/outbound` only after 3+ services need it
- Refactor when usage patterns become clear

## Pkg Package (`pkg/`)
- Contains standalone, reusable packages that are safe to be imported by other projects or services
- Code here should be designed as a library with clear interfaces and minimal dependencies on the rest of the monolith if possible
- Example: generic queue implementation

## Setup Package (`setup/`)

### Configuration (`config/`)
- Define all application configuration structures using Pydantic
- Use environment-based configuration
- Provide sensible defaults
- Never hardcode secrets

### Initialization
- Each setup module should provide an `init_*` function
- Function signature: `def init_*(config: Config) -> ReturnType`
- Return initialized clients/connections
- Handle connection failures gracefully
- Log initialization steps

For detailed setup guidelines, see [python-platform-setup.md](./python-platform-setup.md)

## Structure Package (`structure/`)

### Shared Structures
- `CursorParams`: Pagination parameters (Pydantic model)
- `Resource`: Resource identification (OrgID + UserID)
- Common request/response structures

### Conventions
- Use Pydantic models for type safety
- Include default values using `Field(default=...)`
- Validate structures at service layer, not here

## Util Package (`util/`)

### Error Utilities (`errutil/`)

For error types and handling patterns, see [python-error.md](./python-error.md).

### Other Utilities
- **httputil**: HTTP middleware, response helpers, context extractors
- **motorutil**: MongoDB/motor helpers with error conversion to errutil
- **jwtutil**: JWT token operations
- **factory**: External service client initialization

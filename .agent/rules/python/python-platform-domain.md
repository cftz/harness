---
trigger: always_on
globs: **/src/platform/domain/*.py
paths: **/src/platform/domain/*.py
---

# Platform Domain Model Guidelines

Domain models are the core business entities of the application. They should be framework-agnostic and focused on business logic.

## Field Management Rules

### DO NOT create unnecessary fields

**Avoid adding fields that:**
- Can be derived from existing fields
- Are metadata unrelated to business logic (e.g., `created_at`, `updated_at`)
- Represent states that can be inferred from other fields
- Are added "just in case" without immediate need

### Only add fields when explicitly needed

Each field should have a clear business purpose. If you cannot explain why a field is needed for the current requirements, do not add it.

## Naming Conventions

### Entity Names
- Use singular nouns (e.g., `User`, `Address`, `Project`, not `Users`, `Addresses`, `Projects`)
- Use PascalCase for class names

### Field Names
- Use snake_case for field names (Python convention)
- Single ID: `{entity}_id` (e.g., `project_id`, `source_id`, `user_id`)
- ID arrays: Use plural form (e.g., `parent_ids`, `child_ids`)

### Enums
Use `StrEnum` (Python 3.11+):

```python
from enum import StrEnum

class AddressStatus(StrEnum):
    CREATED = "created"
    PROCESSING = "processing"
    DONE = "done"
    REJECTED = "rejected"
```

## Pydantic Model Rules

For general Pydantic conventions (ConfigDict, Field validation, etc.), see [python-pydantic.md](./python-pydantic.md).

Domain models use the standard ConfigDict with camelCase serialization.

### Field Serialization Rules

#### Exclude security-sensitive fields ONLY when necessary

Only exclude fields that pose security risks when exposed in API responses:

```python
class User(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    id: str = Field(exclude=True)  # Internal user ID - security-sensitive
    username: str
    email: str
    accounts: list[Account]
```

**Security-sensitive fields (MUST exclude):**
- Passwords and password hashes
- API keys and tokens (JWT, OAuth tokens)
- Secrets and encryption keys
- Internal user IDs (when exposing them poses security risk)
- Session IDs
- Internal system identifiers not meant for client consumption

**DO NOT exclude:**
- Regular entity IDs (Address, Project, etc.)
- Business identifiers
- Public-facing data

## Complete Example

```python
from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel
from enum import StrEnum

class AddressStatus(StrEnum):
    CREATED = "created"
    PROCESSING = "processing"
    DONE = "done"
    REJECTED = "rejected"

class Address(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
    )

    # IDs (auto-converted to camelCase)
    id: str
    project_id: str  # → projectId in JSON
    source_id: str   # → sourceId in JSON
    parent_ids: list[str] = Field(default_factory=list)  # → parentIds in JSON

    # Optional fields
    step: int | None = None
    opt_out: bool | None = None    # → optOut in JSON
    unique_id: str | None = None   # → uniqueId in JSON

    # Required fields
    status: AddressStatus
    original: str
    normalized: str | None = None
```

## Anti-Patterns to Avoid

### ❌ Using dict instead of Pydantic models
```python
# WRONG
def create_user(data: dict) -> dict:
    ...
```

### ❌ Excluding regular entity IDs
```python
# WRONG
class Address(BaseModel):
    id: str = Field(exclude=True)  # No need to exclude Address ID
```

### ❌ Adding unnecessary metadata fields
```python
# WRONG
class Address(BaseModel):
    id: str
    created_at: datetime  # Not needed
    updated_at: datetime  # Not needed
```

### ❌ Adding redundant status fields
```python
# WRONG
class Address(BaseModel):
    status: AddressStatus
    is_processed: bool  # Redundant with status
    is_done: bool  # Redundant with status
```

## Summary Checklist

When creating a domain model:
- [ ] Use Pydantic `BaseModel` for all domain models (see [python-pydantic.md](./python-pydantic.md))
- [ ] Use singular entity names (PascalCase)
- [ ] Use snake_case for field names
- [ ] Use `StrEnum` for enums
- [ ] Only include necessary business fields
- [ ] Only exclude security-sensitive fields (passwords, tokens, secrets) - NOT regular entity IDs
- [ ] Avoid adding `created_at`, `updated_at`, or other metadata fields
- [ ] Don't add redundant status or derived fields

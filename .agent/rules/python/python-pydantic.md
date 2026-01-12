---
trigger: always_on
globs: **/*.py
paths: **/*.py
---

# Pydantic Guidelines

This document defines Pydantic model conventions for all Python code.

## Model Configuration

### Standard ConfigDict

All Pydantic models MUST use this configuration for JSON serialization:

```python
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

class MyModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,  # Auto-convert snake_case to camelCase
        populate_by_name=True,     # Allow both snake_case and camelCase input
    )

    user_id: str      # Serialized as "userId" in JSON
    first_name: str   # Serialized as "firstName" in JSON
```

**Key points:**
- `alias_generator=to_camel`: Automatic snake_case → camelCase conversion
- `populate_by_name=True`: Accept both formats as input

### MongoDB Schema ConfigDict

For MongoSchema classes that use ObjectId:

```python
from pydantic import BaseModel, ConfigDict

class MySchema(BaseModel):
    model_config = ConfigDict(
        arbitrary_types_allowed=True,  # Required for ObjectId
    )
```

## Field Definitions

### Optional Fields

Use modern union syntax with default values:

```python
class MyModel(BaseModel):
    required_field: str
    optional_field: str | None = None
    optional_with_default: int | None = 0
```

### List Fields

Use `Field(default_factory=...)` for mutable defaults:

```python
from pydantic import Field

class MyModel(BaseModel):
    items: list[str] = Field(default_factory=list)
    metadata: dict[str, str] = Field(default_factory=dict)
```

### Field Validation

Use `Field()` for validation constraints:

```python
from pydantic import Field

class UserInput(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: str = Field(pattern=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    age: int = Field(ge=0, le=150)
    password: str = Field(min_length=8)
```

### Excluding Fields from Serialization

Only exclude security-sensitive fields:

```python
from pydantic import Field

class User(BaseModel):
    id: str = Field(exclude=True)  # Internal ID - security risk
    password_hash: str = Field(exclude=True)  # Secret
    username: str  # Safe to expose
```

## Anti-Patterns

### Manual alias for each field
```python
# WRONG (verbose)
class Address(BaseModel):
    project_id: str = Field(serialization_alias="projectId")
    source_id: str = Field(serialization_alias="sourceId")

# CORRECT (use model_config)
class Address(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)
    project_id: str  # Automatically serialized as "projectId"
```

### Using Optional[] instead of union syntax
```python
# WRONG (old style)
from typing import Optional
field: Optional[str] = None

# CORRECT (Python 3.11+)
field: str | None = None
```

### Mutable default values
```python
# WRONG
class MyModel(BaseModel):
    items: list[str] = []  # Mutable default!

# CORRECT
class MyModel(BaseModel):
    items: list[str] = Field(default_factory=list)
```

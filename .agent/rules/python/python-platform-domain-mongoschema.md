---
trigger: always_on
globs: **/src/platform/domain/mongoschema/*.py
paths: **/src/platform/domain/mongoschema/*.py
---

# Platform Domain MongoSchema Guidelines

MongoSchema files bridge domain models and MongoDB storage by converting between domain objects and MongoDB documents.

## Purpose

The `mongoschema` package:
- Defines independent MongoDB schema models (not inheriting from domain models)
- Converts domain models (string IDs) to MongoDB documents (ObjectId)
- Provides bidirectional conversion methods (from_domain, to_domain)
- Defines collection and field name constants to avoid magic strings

**Important:** Schema models are independent from domain models to maintain type safety and avoid Liskov Substitution Principle violations. While this requires listing all fields explicitly, it ensures clean architectural separation between domain layer (framework-agnostic) and persistence layer (MongoDB-specific).

## Mandatory File Structure

**Files MUST follow this exact order:**

1. Imports
2. Collection name constant
3. Field name constants
4. Schema class definition (independent BaseModel)
5. Class methods (from_domain, to_domain)

## Collection Name Constants

### Pattern
```python
{ENTITY}_COLLECTION = "{collection}"
```

### Example
```python
ADDRESS_COLLECTION = "addresses"
USER_COLLECTION = "users"
```

## Field Name Constants

### Pattern
```python
{ENTITY}_{FIELD}_FIELD = "{bsonName}"
```

### Rules
- Include constants for ALL fields in the schema
- ID fields first, then domain fields
- Values match the field aliases in the schema

### Example
```python
ADDRESS_ID_FIELD = "_id"
ADDRESS_PROJECT_ID_FIELD = "projectId"
ADDRESS_SOURCE_ID_FIELD = "sourceId"
ADDRESS_STATUS_FIELD = "status"
ADDRESS_ORIGINAL_FIELD = "original"
```

## Schema Class Pattern

### Independent Schema (BaseModel)

**Why Independent?** Schema models do NOT inherit from domain models to avoid type safety issues. Inheriting would require overriding `id: str` with `id: ObjectId | None`, which violates Liskov Substitution Principle and triggers Pylance/Pyright errors. Independent schemas maintain clear architectural boundaries.

```python
from bson import ObjectId
from pydantic import BaseModel, ConfigDict, Field
from typing import Self
from src.platform.domain import Address, AddressStatus

class AddressSchema(BaseModel):  # Independent BaseModel, not inheriting Address
    model_config = ConfigDict(
        arbitrary_types_allowed=True,  # Required for ObjectId
    )

    # MongoDB fields with ObjectId for IDs
    id: ObjectId | None = Field(default=None, alias="_id")
    project_id: ObjectId
    source_id: ObjectId
    parent_ids: list[ObjectId] = Field(default_factory=list)

    # Business fields (explicitly defined, matching domain model)
    status: AddressStatus
    original: str
    normalized: str | None = None

    @classmethod
    def from_domain(cls, domain: Address) -> Self:
        """Convert domain model to MongoDB schema"""
        return cls(
            id=ObjectId(domain.id) if domain.id else None,
            project_id=ObjectId(domain.project_id),
            source_id=ObjectId(domain.source_id),
            parent_ids=[ObjectId(pid) for pid in domain.parent_ids],
            status=domain.status,  # StrEnum passed directly
            original=domain.original,
            normalized=domain.normalized,
        )

    def to_domain(self) -> Address:
        """Convert MongoDB schema to domain model"""
        return Address(
            id=str(self.id) if self.id else "",
            project_id=str(self.project_id),
            source_id=str(self.source_id),
            parent_ids=[str(pid) for pid in self.parent_ids],
            status=self.status,  # StrEnum preserved
            original=self.original,
            normalized=self.normalized,
        )
```

**Note**: All fields must be explicitly defined since we're not inheriting from the domain model. StrEnum fields can be used directly, and Pydantic automatically handles serialization (`model_dump()` converts StrEnum to string for MongoDB).

## Conversion Methods

### from_domain (classmethod)

Purpose: Convert domain model to MongoDB schema

```python
@classmethod
def from_domain(cls, domain: Address) -> Self:
    """Convert domain model to MongoDB schema"""
    return cls(
        # Convert string IDs to ObjectId
        id=ObjectId(domain.id) if domain.id else None,
        project_id=ObjectId(domain.project_id),
        # StrEnum and other fields passed directly
        status=domain.status,
        original=domain.original,
        normalized=domain.normalized,
    )
```

**Rules:**
1. Use `@classmethod` decorator
2. Return `Self` type (Python 3.11+)
3. Convert string IDs to `ObjectId`
4. Pass StrEnum and other fields directly
5. Handle optional IDs with conditional

### to_domain (instance method)

Purpose: Convert MongoDB schema to domain model

```python
def to_domain(self) -> Address:
    """Convert MongoDB schema to domain model"""
    return Address(
        # Convert ObjectId to string
        id=str(self.id) if self.id else "",
        project_id=str(self.project_id),
        # StrEnum and other fields passed directly
        status=self.status,
        original=self.original,
        normalized=self.normalized,
    )
```

**Rules:**
1. Regular instance method
2. Convert `ObjectId` to string using `str()`
3. Pass StrEnum and other fields directly
4. Handle None values for optional fields

## Complete Example

```python
from bson import ObjectId
from pydantic import BaseModel, ConfigDict, Field
from typing import Self
from src.platform.domain import Address, AddressStatus

# Collection constant
ADDRESS_COLLECTION = "addresses"

# Field constants
ADDRESS_ID_FIELD = "_id"
ADDRESS_PROJECT_ID_FIELD = "projectId"
ADDRESS_SOURCE_ID_FIELD = "sourceId"
ADDRESS_PARENT_IDS_FIELD = "parentIds"
ADDRESS_STATUS_FIELD = "status"
ADDRESS_ORIGINAL_FIELD = "original"
ADDRESS_NORMALIZED_FIELD = "normalized"

class AddressSchema(BaseModel):  # Independent BaseModel
    model_config = ConfigDict(
        arbitrary_types_allowed=True,
    )

    # MongoDB ID fields as ObjectId
    id: ObjectId | None = Field(default=None, alias="_id")
    project_id: ObjectId
    source_id: ObjectId
    parent_ids: list[ObjectId] = Field(default_factory=list)

    # Business fields (explicitly defined)
    status: AddressStatus
    original: str
    normalized: str | None = None

    @classmethod
    def from_domain(cls, domain: Address) -> Self:
        return cls(
            id=ObjectId(domain.id) if domain.id else None,
            project_id=ObjectId(domain.project_id),
            source_id=ObjectId(domain.source_id),
            parent_ids=[ObjectId(pid) for pid in domain.parent_ids],
            status=domain.status,
            original=domain.original,
            normalized=domain.normalized,
        )

    def to_domain(self) -> Address:
        return Address(
            id=str(self.id) if self.id else "",
            project_id=str(self.project_id),
            source_id=str(self.source_id),
            parent_ids=[str(pid) for pid in self.parent_ids],
            status=self.status,
            original=self.original,
            normalized=self.normalized,
        )
```

## Usage in Repository

```python
async def create(self, address: Address) -> Address:
    # Convert to schema
    schema = AddressSchema.from_domain(address)

    # Insert to MongoDB (StrEnum auto-converted to string by model_dump)
    result = await self.collection.insert_one(
        schema.model_dump(by_alias=True, exclude_none=True)
    )

    # Update ID and return
    address.id = str(result.inserted_id)
    return address

async def get(self, address_id: str) -> Address | None:
    # Find document
    doc = await self.collection.find_one({"_id": ObjectId(address_id)})
    if not doc:
        return None

    # Convert to schema then to domain
    schema = AddressSchema(**doc)
    return schema.to_domain()
```

## Summary Checklist

When creating a MongoSchema file:
- [ ] Follow mandatory file structure order
- [ ] Define `{ENTITY}_COLLECTION` constant
- [ ] Define field constants for ALL fields (`{ENTITY}_{FIELD}_FIELD`)
- [ ] Create independent schema class inheriting from `BaseModel` (NOT from domain model)
- [ ] Use `ConfigDict` with `arbitrary_types_allowed=True` for ObjectId support
- [ ] Define ID fields as `ObjectId` type
- [ ] Define all business fields explicitly (matching domain model fields)
- [ ] Use `alias="_id"` for the id field
- [ ] Implement `from_domain` as classmethod returning `Self`
- [ ] Implement `to_domain` as instance method
- [ ] Pass StrEnum fields directly in conversion methods
- [ ] Handle ID arrays with list comprehensions
- [ ] Use `model_dump(by_alias=True)` when inserting to MongoDB

---
trigger: glob
globs: **/src/service/*/inbound/**/*
paths: **/src/service/*/inbound/**/*
---

# Inbound Adapter Guidelines

Inbound adapters handle incoming requests from external sources (HTTP, workers, etc.) and translate them into service calls.

## Port (Protocol) Pattern

### Inbound-Specific File Organization

Inbound adapters organize files by category (protocol type) and implementation:
- **Port (Protocol)**: Handler interface + DTO models at `{category}/` level
- **Adapter (Implementation)**: Concrete handler at `{category}/{implementation}/` level

```
{domain}/inbound/{category}/
├── {feature}_handler_port.py    # Handler Port Protocol + DTO models
└── {implementation}/
    └── {feature}_handler.py      # Handler implementation
```

**Example (HTTP):**
```
user/inbound/http/
├── user_handler_port.py    # UserHandlerPort Protocol + DTOs
├── account_handler_port.py # AccountHandlerPort Protocol + DTOs
└── fastapi/
    ├── user_handler.py      # UserHTTPHandler implements UserHandlerPort
    └── account_handler.py   # AccountHTTPHandler implements AccountHandlerPort
```

### Handler Port Files

**File:** `{domain}/inbound/{category}/{feature}_handler_port.py`

Contains:
1. **DTO Models**: Request/response data transfer objects
2. **Handler Port (Protocol)**: Interface defining handler methods

**Purpose:**
- Define handler interface contract
- Validate input/output at adapter boundary
- Enable multiple implementations (e.g., FastAPI, Flask, gRPC)

### Protocol Implementation Enforcement

Handlers MUST explicitly inherit Protocol for pyright enforcement. For detailed Protocol pattern, see [python-port-adapter-pattern.md](./python-port-adapter-pattern.md).

### DTO Models

DTO (Data Transfer Object) models validate input at adapter boundary and transform external format to internal domain models.

For general DTO vs Domain Model guidelines, see [python-port-adapter-pattern.md](./python-port-adapter-pattern.md).

**Category-specific DTO patterns:**
- **HTTP**: [python-inbound-http.md](./python-inbound-http.md) - ReqBody/ResBody patterns
- **Worker**: (Future) - Job/Task message patterns
- **WebSocket**: (Future) - Event/Message patterns

## Naming Conventions

### Handler Class Names

**Pattern:** `{Feature}{Protocol}Handler`

```python
# HTTP handlers for different features
class UserHTTPHandler: ...      # Handles /users/* endpoints
class AccountHTTPHandler: ...   # Handles /accounts/* endpoints

# Worker handlers
class SourceWorkerHandler: ...
```

### File Names

**Pattern:** `{feature}_handler.py` for each handler class

```
inbound/http/fastapi/
├── user_handler.py      # UserHTTPHandler class
├── account_handler.py   # AccountHTTPHandler class
└── helpers.py           # Optional: shared helper functions
```

### Constructor Pattern

Use `__init__` method (Python constructor). For logger injection conventions, see [python-logging-conventions.md](./python-logging-conventions.md).

## Handler File Structure

### HTTP Handler Example

```python
# user/inbound/http/fastapi/user_handler.py
import structlog
from fastapi import APIRouter
from src.service.user import Service

class UserHTTPHandler:
    def __init__(self, logger: structlog.BoundLogger, svc: Service):
        self.logger = logger.bind(name="user.http.fastapi.user")
        self.svc = svc
        self.router = APIRouter(prefix="/users", tags=["users"])
        self._register_routes()

    def _register_routes(self):
        """Register all routes to router"""
        self.router.post("/")(self.create_user)
        self.router.get("/{user_id}")(self.get_user)

    async def create_user(self, user_data: UserCreate) -> User:
        """Handler method"""
        return await self.svc.create_user(user_data)

    async def get_user(self, user_id: str) -> User:
        return await self.svc.get_user(user_id)
```

**Key points:**
- Handler has `router` attribute (APIRouter instance)
- Routes registered in `_register_routes()` called from `__init__`
- Container can access `handler.router` to include in FastAPI app

### Worker Handler Example

```python
# source/inbound/worker/queue/source.py
import structlog
from src.service.source import Service

class SourceWorkerHandler:
    def __init__(self, logger: structlog.BoundLogger, svc: Service):
        self.logger = logger.bind(name="source.worker.queue")
        self.svc = svc

    async def start(self):
        """Worker start method - called by container"""
        # Worker loop logic
        ...
```

### File: `helpers.py` (Optional)

**Purpose:** Shared helper functions used by multiple handlers

```python
def parse_cursor(cursor_str: str) -> dict:
    """Helper to parse cursor string"""
    ...

def validate_request(data: dict) -> bool:
    """Helper to validate request data"""
    ...
```

## Container Integration

Handlers are collected by container and registered:

```python
# Container collects handlers
http_handlers = providers.List(
    user.user_handler,      # UserHTTPHandler instance
    user.account_handler,   # AccountHTTPHandler instance
)

# Registration function uses handler.router
def register_http(container: ApplicationContainer) -> FastAPI:
    app = FastAPI()
    for handler in container.http_handlers():
        app.include_router(handler.router)  # Access router attribute
    return app
```

## File Organization Examples

### Single Feature Domain

```
user/inbound/http/fastapi/
└── user_handler.py        # UserHTTPHandler (handles all /users/* endpoints)
```

### Multi-Feature Domain

```
user/inbound/http/fastapi/
├── user_handler.py        # UserHTTPHandler (handles /users/* endpoints)
├── account_handler.py     # AccountHTTPHandler (handles /accounts/* endpoints)
└── helpers.py             # Shared helper functions
```

## Common Mistakes to Avoid

1. **Skipping category directory**
   - ❌ `inbound/fastapi/`
   - ✅ `inbound/http/fastapi/`

2. **Skipping implementation directory**
   - ❌ `inbound/http/user_handler.py`
   - ✅ `inbound/http/fastapi/user_handler.py`

3. **Adding extra nesting**
   - ❌ `inbound/http/fastapi/handlers/user_handler.py`
   - ✅ `inbound/http/fastapi/user_handler.py`

4. **Using generic "handler.py" for multiple features**
   - ❌ `handler.py` (containing both User and Account handlers)
   - ✅ `user_handler.py` + `account_handler.py` (one file per feature)

5. **Forgetting router attribute for HTTP handlers**
   - ❌ Handler without `self.router`
   - ✅ Handler with `self.router = APIRouter(...)`

## Protocol/Implementation-Specific Guidelines

For detailed implementation guidelines, see:
- **HTTP (FastAPI)**: [python-inbound-http-fastapi.md](./python-inbound-http-fastapi.md)
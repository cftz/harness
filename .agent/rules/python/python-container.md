---
trigger: always_on
globs: **/command/container/*.py
paths: **/command/container/*.py
---

# Container Package Guidelines

This document describes the best practices for dependency injection in the `command/container` package using `dependency-injector`.

## Container Organization

### Platform Container
Contains shared infrastructure setup by calling `platform/setup/` initialization functions:

```python
from dependency_injector import containers, providers
import structlog
from motor.motor_asyncio import AsyncIOMotorDatabase

from src.platform.setup import init_mongodb, init_logger

class PlatformContainer(containers.DeclarativeContainer):
    """Container for platform-level dependencies"""

    # Configuration
    config = providers.Configuration()

    # Logging (calls setup/logging.py)
    logger: providers.Singleton[structlog.BoundLogger] = providers.Singleton(
        init_logger,
        config=config,
    )

    # Database (calls setup/mongodb.py)
    mongo_db: providers.Resource[AsyncIOMotorDatabase] = providers.Resource(
        init_mongodb,
        config=config,
        logger=logger,
    )

    # Other platform dependencies (cache, queue, etc.)
```

**IMPORTANT**: Container should NOT contain client initialization logic directly. All setup logic belongs in `src/platform/setup/` modules. For setup guidelines, see [python-platform-setup.md](./python-platform-setup.md).

**What NOT to do:**
```python
# ❌ WRONG - Initialization logic in container
class PlatformContainer(containers.DeclarativeContainer):
    config = providers.Configuration()

    # Don't do this - complex logic belongs in setup/
    mongo_db = providers.Singleton(
        lambda cfg: AsyncIOMotorClient(cfg.mongodb.connection_string)[cfg.mongodb.database],
        config=config,
    )
```

### Domain Container
Contains domain-specific services, repositories, and handlers:

```python
from dependency_injector import containers, providers
import structlog
from motor.motor_asyncio import AsyncIOMotorDatabase

class UserContainer(containers.DeclarativeContainer):
    """Container for user domain dependencies"""

    # Injected from parent
    config = providers.Configuration()
    logger: providers.Dependency[structlog.BoundLogger] = providers.Dependency()
    mongo_db: providers.Dependency[AsyncIOMotorDatabase] = providers.Dependency()

    # Repository
    repository: providers.Singleton[MongoUserRepository] = providers.Singleton(
        MongoUserRepository,
        db=mongo_db,
        logger=logger,
    )

    # Service
    service: providers.Singleton[UserService] = providers.Singleton(
        UserService,
        logger=logger,
        repo=repository,
    )

    # HTTP Handler
    http_handler: providers.Singleton[UserHTTPHandler] = providers.Singleton(
        UserHTTPHandler,
        logger=logger,
        svc=service,
    )
```

### Application Container
Composes all containers and collects handlers:

```python
from dependency_injector import containers, providers

class ApplicationContainer(containers.DeclarativeContainer):
    """Main application container"""

    config = providers.Configuration()

    # Platform container
    platform: providers.Container[PlatformContainer] = providers.Container(
        PlatformContainer,
        config=config,
    )

    # Domain containers
    user: providers.Container[UserContainer] = providers.Container(
        UserContainer,
        config=config,
        logger=platform.logger,
        mongo_db=platform.mongo_db,
    )

    agent: providers.Container[AgentContainer] = providers.Container(
        AgentContainer,
        config=config,
        logger=platform.logger,
        mongo_db=platform.mongo_db,
    )

    # Collect all HTTP handlers (similar to fx group)
    http_handlers: providers.List = providers.List(
        user.http_handler,
        agent.http_handler,
        # Add more handlers here
    )
```

## Provider Types

**IMPORTANT**: All providers MUST have explicit type annotations for Pyright strict mode compatibility.

1. **Singleton**: Single instance shared across the application
   ```python
   mongo_db: providers.Singleton[AsyncIOMotorDatabase] = providers.Singleton(
       init_mongodb,  # Calls setup function
       config=config,  # Pass full config
   )
   ```

2. **Resource**: For async resources (context managers)
   ```python
   mongo_db: providers.Resource[AsyncIOMotorDatabase] = providers.Resource(
       init_mongodb,  # Async setup function
       config=config,
       logger=logger,
   )
   ```

3. **Factory**: New instance on each call
   ```python
   request_handler: providers.Factory[RequestHandler] = providers.Factory(
       RequestHandler,
       service=user_service,
   )
   ```

4. **Dependency**: Injected from parent container
   ```python
   logger: providers.Dependency[structlog.BoundLogger] = providers.Dependency()
   ```

5. **Container**: Nested container
   ```python
   platform: providers.Container[PlatformContainer] = providers.Container(
       PlatformContainer,
       config=config,
   )
   ```

6. **List**: Collect multiple providers (similar to fx group)
   ```python
   http_handlers: providers.List = providers.List(
       user.http_handler,
       agent.http_handler,
   )
   ```

## Registration Pattern

Use `register_{type}.py` files to initialize runtime services from the container (similar to fx.Invoke).
These functions take the `ApplicationContainer` and wire up dependencies into actual running services (FastAPI app, workers, background tasks, etc.):

```python
# command/container/register_fastapi.py
from fastapi import FastAPI
from command.container.application import ApplicationContainer

def register_fastapi(container: ApplicationContainer) -> FastAPI:
    """Create FastAPI app and register all HTTP handlers"""
    app = FastAPI()

    # Register all HTTP handlers
    for handler in container.http_handlers():
        app.include_router(handler.router)

    return app
```

```python
# command/main.py
from command.container import ApplicationContainer
from command.container.register_fastapi import register_fastapi
from src.platform.setup.config import Config

def create_app() -> FastAPI:
    # Load configuration from environment variables
    config = Config()

    # Initialize container
    container = ApplicationContainer()
    container.config.from_pydantic(config)

    # Register HTTP handlers and return app
    return register_fastapi(container)
```

## File Organization

```
command/container/
├── module_platform.py      # Platform container
├── module_{domain}.py      # Domain containers
├── application.py          # ApplicationContainer (composes all)
└── register_{type}.py      # Runtime initialization functions (similar to fx.Invoke)
                            # Takes container and registers dependencies to actual services
```

## Best Practices

1. **Separate setup logic**: All client initialization goes in `src/platform/setup/`, NOT in containers
2. **Pass full Config**: Always pass the complete `Config` object to setup functions
3. **Separate Platform and Domain**: Platform container for infrastructure, Domain containers for business logic
4. **Use List provider for collections**: Group similar providers (handlers, workers) using `providers.List()`
5. **Use register files**: Put service registration logic in `register_{type}.py` files
6. **Register functions take only container**: Registration functions should only take the container as parameter
7. **Use Dependency providers**: Inject cross-cutting dependencies (logger, config, db)
8. **Avoid circular dependencies**: Structure your imports carefully
9. **Type hints**: Use type hints for all provider factory functions
10. **One container per domain**: Each domain gets its own container module

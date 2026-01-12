---
trigger: always_on
globs: **/src/platform/setup/**/*
paths: **/src/platform/setup/**/*
---

# Platform Setup Guidelines

The setup package contains initialization functions for platform-level dependencies (databases, external clients, logging, etc.).

## Function Pattern

Setup functions follow these patterns:

### Root Setup (no dependencies)
```python
def init_{service}(config: Config) -> {ReturnType}:
    """Initialize {service} - no dependencies needed"""
    # Extract config, initialize, return
```

### Dependent Setup (requires other services)
```python
def init_{service}(config: Config, logger: structlog.BoundLogger, ...) -> {ReturnType}:
    """Initialize {service} with dependencies"""
    # Use injected dependencies
    # Extract config, initialize, return
```

### Rules

1. **Function naming**: Always use `init_{service}` pattern
2. **First parameter**: Always `config: Config` (full Config object)
3. **Additional parameters**: Accept required dependencies (logger, other services)
4. **Return type**: Return the initialized client/service instance
5. **Type hints**: Always include type hints for all parameters and return type
6. **Async when needed**: Use `async def` if initialization requires async operations

## Examples

### Logging Initialization (root, no dependencies)

```python
# src/platform/setup/logging.py
import structlog
from src.platform/setup.config import Config

def init_logger(config: Config) -> structlog.BoundLogger:
    """Initialize structured logger"""
    # Configure structlog
    structlog.configure(
        processors=[
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.dev.ConsoleRenderer() if config.logging.dev_mode else structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.BoundLogger,
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
    )

    logger = structlog.get_logger()
    logger.info("Logger initialized", level=config.logging.level)

    return logger
```

### Database Initialization (depends on logger)

```python
# src/platform/setup/mongodb.py
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from src.platform.setup.config import Config
import structlog

async def init_mongodb(config: Config, logger: structlog.BoundLogger) -> AsyncIOMotorDatabase:
    """Initialize MongoDB client and return database"""
    # Extract config
    connection_string = config.mongodb.connection_string
    database_name = config.mongodb.database

    # Initialize client
    client = AsyncIOMotorClient(connection_string)
    db = client[database_name]

    # Log initialization (using injected logger)
    logger.info("MongoDB initialized", database=database_name)

    return db
```

## Configuration Structure

All configuration classes use `pydantic-settings` for automatic environment variable loading.

```python
# src/platform/setup/config.py
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class MongoDBConfig(BaseSettings):
    """MongoDB configuration"""

    uri: str = Field(default="mongodb://localhost:27017")
    database: str = Field(default="alpha")

    model_config = SettingsConfigDict(
        env_prefix="MONGODB_",
        env_file=".meta/.env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

class LoggingConfig(BaseSettings):
    """Logging configuration"""

    level: str = Field(default="INFO")
    dev_mode: bool = Field(default=False)

    model_config = SettingsConfigDict(
        env_prefix="LOGGING_",
        env_file=".meta/.env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

class Config(BaseSettings):
    """Application configuration"""

    logging: LoggingConfig = Field(default_factory=LoggingConfig)
    mongodb: MongoDBConfig = Field(default_factory=MongoDBConfig)

    model_config = SettingsConfigDict(
        env_file=".meta/.env",
        env_file_encoding="utf-8",
        extra="ignore",
    )
```

### Environment Variable Naming
- Use uppercase with underscores (e.g., `MONGODB_URI`, `LOGGING_LEVEL`)
- Use prefixes to group related settings (e.g., `MONGODB_`, `LOGGING_`)
- Map to lowercase field names without prefix in models

### Loading Configuration
```python
# command/main.py
from src.platform.setup.config import Config

async def initialize_app():
    # Automatically loads from .meta/.env
    config = Config()

    container = ApplicationContainer()
    container.config.from_pydantic(config)
```

## Container Integration

```python
# command/container/module_platform.py
from dependency_injector import containers, providers
from src.platform.setup import init_logger, init_mongodb, init_redis

class PlatformContainer(containers.DeclarativeContainer):
    config = providers.Configuration()

    # Root setup - only takes config
    logger = providers.Singleton(
        init_logger,
        config=config,
    )

    # Dependent setup - takes config + logger
    mongo_db = providers.Singleton(
        init_mongodb,
        config=config,
        logger=logger,
    )

    # Another dependent setup
    redis = providers.Singleton(
        init_redis,
        config=config,
        logger=logger,
    )
```

## Best Practices

1. **Always pass full Config**: Functions receive the complete `Config` object, not sub-configs like `config.mongodb`
2. **Extract what you need**: Inside the function, extract only the relevant configuration (e.g., `config.mongodb.host`)
3. **Inject dependencies**: Accept dependencies (logger, other services) as function parameters
4. **Log initialization**: Always log when a service is initialized
5. **Handle errors**: Log and raise clear errors if initialization fails
6. **Test connections**: For external services, test the connection before returning
7. **Async for I/O**: Use `async def` for any initialization that involves network I/O
8. **Type safety**: Use Pydantic for all configuration models
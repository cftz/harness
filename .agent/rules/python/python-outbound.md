---
trigger: always_on
globs: **/src/**/outbound/**/*
paths: **/src/**/outbound/**/*
---

# Outbound Adapters

Follow **Port (Protocol) → Adapter (Implementation)** pattern.

**For core Port/Adapter pattern fundamentals (Protocol definition, explicit inheritance, type safety), see [python-port-adapter-pattern.md](./python-port-adapter-pattern.md)**

## Directory Structure Rule

```
outbound/                   # External dependencies
├── externalsvc/            # External service interfaces (impl in src/service/core/{extsvc}/)
│   └── auth/               # Authentication service interfaces
├── repository/             # Data persistence interfaces
│   ├── user_repo_port.py   # User repository interface (Protocol)
│   ├── post_repo_port.py   # Post repository interface (Protocol)
│   └── mongodb/
│       ├── user_repo.py    # User repository implementation
│       └── post_repo.py    # Post repository implementation
└── {category}/             # Other outbound dependencies
    ├── {name}_port.py      # Interface (Protocol)
    └── {implementation}/   # Implementation package
        └── {name}.py       # Implementation
```

> Omit directories if not needed (e.g., no repository if no data persistence)

**Categories:**
- `repository/` - Data persistence (MongoDB, etc.)
- `externalsvc/` - External service dependencies (interfaces only)
- ... Other categories as needed

## Best Practices

1. **Use Protocol for ports**: Define interfaces with `typing.Protocol` (see [python-port-adapter-pattern.md](./python-port-adapter-pattern.md))
2. **Protocol inheritance**: Repository classes explicitly inherit Protocol for pyright enforcement
3. **Async operations**: All I/O operations should be async
4. **Return None for not found**: Let service layer decide how to handle
5. **Raise errutil exceptions**: Use errutil exceptions for errors (see [python-error.md](./python-error.md))
6. **Use mongoschema**: Always convert through schema layer
7. **Log operations**: Log important operations with context (see [python-logging-conventions.md](./python-logging-conventions.md))
8. **Type hints**: Use type hints for all methods
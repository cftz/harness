---
trigger: always_on
globs: **/src/service/**/*.py, **/src/service/*.py
paths: **/src/service/**/*.py, **/src/service/*.py
---

# Service Package Guidelines

The service package contains all business logic organized by domain following hexagonal architecture.

## Service Directory Structure

```
{domain}/
├── {domain}_service.py         # Core service implementation
├── inbound/                    # Inbound adapters - see python-inbound.md
│   └── {category}/             # Protocol category (http, worker, etc.)
│       └── {implementation}/   # Implementation (fastapi, queue, etc.)
└── outbound/                   # Outbound adapters - see python-outbound.md
    └── {category}/             # Dependency category (repository, etc.)
        ├── {name}_port.py      # Interface (Port) using Protocol
        └── {implementation}/   # Implementation (mongodb, etc.)
```

**For detailed inbound structure rules, see [python-inbound.md](./python-inbound.md)**
**For detailed outbound structure rules, see [python-outbound.md](./python-outbound.md)**

## Structure

For logger injection conventions, see [python-logging-conventions.md](./python-logging-conventions.md).

### Method Pattern
1. Check RBAC permissions first
2. Validate business logic
3. Execute operation (async if I/O involved)
4. Return result or raise exception

### Error Handling Pattern

For error types and handling patterns, see [python-error.md](./python-error.md).

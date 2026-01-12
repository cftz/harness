---
trigger: always_on
globs: **/src/**/*.ts
paths: **/src/**/*.ts
---

# Src Package Guidelines

This document defines the coding standards and architectural patterns for the NestJS codebase.

## Architecture Overview

This package follows **Hexagonal Architecture** (Ports and Adapters) with clear separation of concerns:

```
src/
├── platform/     # Shared infrastructure, utilities, and domain models
├── module/       # Business logic organized by domain
│   ├── core/     # Cross-cutting services (Auth, RBAC, etc.)
│   └── {domain}/ # Domain-specific modules
└── app.module.ts # Application entry point
```

## General Rules

### Package Structure
- Each module follows the hexagonal pattern with `inbound`, `outbound`, and core business logic
- Dependencies flow inward: `inbound → service → outbound`
- Never import from `inbound` packages into service or outbound layers

### Module Isolation

**CRITICAL RULE: Module Independence**

Each module (except Core) MUST be completely independent. Modules cannot directly import or depend on other modules.

**FORBIDDEN - Cross-Module Imports:**
- ❌ WRONG: `import { UserService } from '../user/user.service'` in `order` module
- ❌ WRONG: Importing another module's inbound/outbound code

**ALLOWED - Cross-Module Dependencies:**

1. **Core modules**: Modules under `src/module/core/` can be injected into other modules
2. **Platform components**: All platform modules can be used across modules:
   - `src/platform/domain/` - Shared domain models
   - `src/platform/filter/` - Global exception filters
   - `src/platform/interceptor/` - Global interceptors

**Examples:**

```typescript
// ❌ WRONG - order module importing user module directly
import { UserService } from '../user/user.service'; // FORBIDDEN

// ✅ CORRECT - using Core module (if exists)
import { AuthService } from '../core/auth/auth.service'; // OK - Core modules can be injected

// ✅ CORRECT - using platform components
import { User } from '../../platform/domain/user.entity'; // OK - shared domain models
import { HttpExceptionFilter } from '../../platform/filter/http-exception.filter'; // OK - shared filters
```

### Dependency Injection
- All dependencies MUST be injected through constructors
- Use NestJS built-in DI with `@Injectable()` decorator
- Return concrete types from constructors, not interfaces
- Use abstract classes for Port definitions (see [nestjs-port-adapter-pattern.md](./nestjs-port-adapter-pattern.md))

### Error Handling
- Use NestJS built-in exceptions (`NotFoundException`, `BadRequestException`, etc.)
- Let exceptions propagate to global exception filter
- Never suppress exceptions without logging

### Async/Await
- Always use `async/await` for I/O operations
- Service methods that perform I/O should be `async`

### Type Usage
- Use TypeScript strict mode
- Use class-validator for DTO validation (see [nestjs-dto.md](./nestjs-dto.md))
- Use abstract classes for Port definitions

## Module Directory Structure

```
module/{domain}/
├── {domain}.module.ts              # NestJS Module definition
├── {domain}.service.ts             # Core service implementation
├── {domain}.dto.ts                 # DTOs at service level
├── {domain}.repository.port.ts     # Port definition at service level
│
├── inbound/                        # Inbound adapters
│   ├── {domain}.controller.ts      # HTTP Controller → controllers[]
│   ├── {domain}.scheduler.ts       # Cron jobs → providers[]
│   └── {domain}.processor.ts       # Queue processor → providers[]
│
└── outbound/                       # Outbound adapters
    └── {domain}.repository.mongo.ts # Repository implementation
```

**For detailed inbound structure rules, see [nestjs-inbound.md](./nestjs-inbound.md)**
**For detailed outbound structure rules, see [nestjs-outbound.md](./nestjs-outbound.md)**

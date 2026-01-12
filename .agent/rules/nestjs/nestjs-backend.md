---
trigger: always_on
globs: **/src/**/*.ts
paths: **/src/**/*.ts
---

# NestJS Backend Guidelines

This document defines the coding standards for the NestJS codebase. These rules apply to all TypeScript files in the `src/` directory.

## Style Guide Precedence

When multiple style guides conflict, follow this precedence:
1. Rules in this document and related rule files
2. NestJS official documentation
3. TypeScript best practices

## Architecture Rules

This codebase follows **Hexagonal Architecture**. See [nestjs-hexagonal-layout.md](./nestjs-hexagonal-layout.md) for detailed structure.

### Key Principles

- **Inbound → Service → Outbound**: Dependencies flow inward
- **Module isolation**: Modules cannot import from other modules (except Core)
- **Port/Adapter pattern**: Use abstract classes for ports

## Function Parameters

### Maximum 3 Parameters

Functions should have at most 3 parameters. If more are needed, use a params object.

```typescript
// ❌ WRONG - Too many parameters
async createUser(
  name: string,
  email: string,
  password: string,
  role: string,
  isActive: boolean,
): Promise<User> { }

// ✅ CORRECT - Use DTO
async createUser(dto: CreateUserDto): Promise<User> { }
```

### Exception: Constructor Injection

Constructors can have more than 3 parameters for dependency injection:

```typescript
// ✅ OK - DI constructor
constructor(
  private readonly logger: PinoLogger,
  private readonly userRepo: UserRepositoryPort,
  private readonly authService: AuthService,
  private readonly cacheService: CacheService,
) { }
```

## Related Rules

For layer-specific guidelines, see:

| Layer | Rule File |
|-------|-----------|
| Architecture | [nestjs-hexagonal-layout.md](./nestjs-hexagonal-layout.md) |
| Port/Adapter | [nestjs-port-adapter-pattern.md](./nestjs-port-adapter-pattern.md) |
| Service | [nestjs-service.md](./nestjs-service.md) |
| Module | [nestjs-module.md](./nestjs-module.md) |
| Inbound (common) | [nestjs-inbound.md](./nestjs-inbound.md) |
| Inbound (HTTP) | [nestjs-inbound-http.md](./nestjs-inbound-http.md) |
| Inbound (Scheduler) | [nestjs-inbound-scheduler.md](./nestjs-inbound-scheduler.md) |
| Inbound (Queue) | [nestjs-inbound-queue.md](./nestjs-inbound-queue.md) |
| Outbound | [nestjs-outbound.md](./nestjs-outbound.md) |
| DTO | [nestjs-dto.md](./nestjs-dto.md) |
| Platform | [nestjs-platform.md](./nestjs-platform.md) |
| Platform Setup | [nestjs-platform-setup.md](./nestjs-platform-setup.md) |
| Logging | [nestjs-logging-conventions.md](./nestjs-logging-conventions.md) |

## TypeScript Conventions

### Strict Mode

Enable strict TypeScript:

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": true,
    "noImplicitAny": true
  }
}
```

### Type Annotations

Always provide explicit type annotations for:
- Function parameters
- Function return types
- Class properties

```typescript
// ✅ CORRECT
async createUser(dto: CreateUserDto): Promise<User> {
  return this.repo.create(dto);
}

// ❌ WRONG - Missing return type
async createUser(dto: CreateUserDto) {
  return this.repo.create(dto);
}
```

### Async/Await

Use async/await for all asynchronous operations:

```typescript
// ✅ CORRECT
async getUser(id: string): Promise<User> {
  const user = await this.repo.findById(id);
  return user;
}

// ❌ WRONG - Don't use .then()
getUser(id: string): Promise<User> {
  return this.repo.findById(id).then(user => user);
}
```

## Error Handling

### Use NestJS Built-in Exceptions

```typescript
import { NotFoundException, BadRequestException } from '@nestjs/common';

// Throw in service layer
if (!user) {
  throw new NotFoundException(`User ${id} not found`);
}
```

### Let Exceptions Propagate

Controllers should NOT catch exceptions:

```typescript
// ✅ CORRECT - Let global filter handle
@Get(':id')
async findOne(@Param('id') id: string): Promise<User> {
  return this.userService.getUser(id);
}
```

## Dependency Injection

### Use Constructor Injection

```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly logger: PinoLogger,
    private readonly repo: UserRepositoryPort,
  ) {
    this.logger.setContext('user.service');
  }
}
```

### Depend on Abstractions

Services should depend on Port abstract classes, not concrete implementations:

```typescript
// ✅ CORRECT - Depend on Port
constructor(private readonly repo: UserRepositoryPort) { }

// ❌ WRONG - Depend on concrete implementation
constructor(private readonly repo: MongoUserRepository) { }
```

## File Organization

### One Class Per File

Each file should contain one main class:

```
user.service.ts      # UserService
user.controller.ts   # UserController
user.module.ts       # UserModule
```

### Co-located Related Code

Keep related DTOs and Ports next to their service:

```
module/user/
├── user.module.ts
├── user.service.ts
├── user.dto.ts              # DTOs here
├── user.repository.port.ts  # Port here
├── inbound/
└── outbound/
```

## Best Practices Summary

1. **Hexagonal Architecture**: Follow the layered structure
2. **Module Isolation**: Don't import across modules
3. **Port/Adapter**: Use abstract classes for ports
4. **Max 3 Parameters**: Use DTOs for more
5. **Strict TypeScript**: Enable strict mode
6. **Type Everything**: Explicit types on all signatures
7. **Async/Await**: No .then() chains
8. **NestJS Exceptions**: Use built-in exceptions
9. **Constructor DI**: Inject all dependencies
10. **Depend on Abstractions**: Use Port types

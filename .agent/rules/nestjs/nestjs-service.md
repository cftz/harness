---
trigger: always_on
globs: **/src/module/**/*.service.ts
paths: **/src/module/**/*.service.ts
---

# Service Package Guidelines

The service layer contains all business logic organized by domain following hexagonal architecture.

## Service Directory Structure

```
module/{domain}/
├── {domain}.module.ts              # NestJS Module definition
├── {domain}.service.ts             # Core service implementation
├── {domain}.dto.ts                 # DTOs at service level
├── {domain}.repository.port.ts     # Port definition at service level
│
├── inbound/                        # Inbound adapters - see nestjs-inbound.md
│   └── {domain}.controller.ts
│
└── outbound/                       # Outbound adapters - see nestjs-outbound.md
    └── {domain}.repository.mongo.ts
```

**For detailed inbound structure rules, see [nestjs-inbound.md](./nestjs-inbound.md)**
**For detailed outbound structure rules, see [nestjs-outbound.md](./nestjs-outbound.md)**

## Service Structure

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { PinoLogger } from 'nestjs-pino';
import { UserRepositoryPort } from './user.repository.port';
import { CreateUserDto, UpdateUserDto } from './user.dto';
import { User } from '../../platform/domain/user.entity';

@Injectable()
export class UserService {
  constructor(
    private readonly logger: PinoLogger,
    private readonly repo: UserRepositoryPort,
    // Other dependencies...
  ) {
    this.logger.setContext('user.service');
  }

  async createUser(dto: CreateUserDto): Promise<User> {
    this.logger.info({ dto }, 'Creating user');
    return this.repo.create(dto);
  }

  async getUser(id: string): Promise<User> {
    const user = await this.repo.findById(id);
    if (!user) {
      throw new NotFoundException(`User ${id} not found`);
    }
    return user;
  }
}
```

## Method Pattern

1. Log the operation (optional, for important operations)
2. Check permissions if needed (via Core AuthService)
3. Validate business logic
4. Execute operation via repository
5. Return result

```typescript
async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
  // 1. Log
  this.logger.info({ id, dto }, 'Updating user');

  // 2. Check permissions (if using RBAC)
  // await this.authService.checkPermission(userId, 'user:update');

  // 3. Business logic validation
  const existing = await this.repo.findById(id);
  if (!existing) {
    throw new NotFoundException(`User ${id} not found`);
  }

  // 4. Execute operation
  return this.repo.update(id, dto);
}
```

## Error Handling

Use NestJS built-in exceptions. They are automatically converted to HTTP responses.

```typescript
import {
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
  UnauthorizedException,
} from '@nestjs/common';

// Examples
throw new NotFoundException(`User ${id} not found`);
throw new BadRequestException('Email is required');
throw new ConflictException('Email already exists');
throw new ForbiddenException('Insufficient permissions');
throw new UnauthorizedException('Invalid credentials');
```

**Exception to HTTP Status Mapping:**

| Exception | HTTP Status |
|-----------|-------------|
| `BadRequestException` | 400 |
| `UnauthorizedException` | 401 |
| `ForbiddenException` | 403 |
| `NotFoundException` | 404 |
| `ConflictException` | 409 |
| `InternalServerErrorException` | 500 |

## Dependency Injection

- Inject dependencies through constructor
- Use Port types for repositories (not concrete implementations)
- Logger should be first parameter

```typescript
@Injectable()
export class OrderService {
  constructor(
    private readonly logger: PinoLogger,           // Logger first
    private readonly repo: OrderRepositoryPort,    // Port type
    private readonly authService: AuthService,     // Core service (allowed)
  ) {
    this.logger.setContext('order.service');
  }
}
```

## Logging Conventions

See [nestjs-logging-conventions.md](./nestjs-logging-conventions.md) for detailed logging patterns.

```typescript
// Set context in constructor
this.logger.setContext('user.service');

// Structured logging with context
this.logger.info({ userId, action: 'create' }, 'User created');
this.logger.error({ error, userId }, 'Failed to create user');
```

## Best Practices

1. **Single Responsibility**: Each service handles one domain
2. **Depend on Ports**: Use abstract Port classes, not concrete implementations
3. **Use NestJS Exceptions**: Built-in exceptions auto-convert to HTTP responses
4. **Structured Logging**: Use Pino logger with context and structured data
5. **Async/Await**: All I/O operations should be async
6. **No Cross-Module Imports**: Don't import from other domain modules (only Core allowed)
7. **DTOs at Service Level**: Keep DTOs next to service file

---
trigger: glob
globs: **/src/module/**/inbound/**/*.ts, **/src/module/**/outbound/**/*.ts
paths: **/src/module/**/inbound/**/*.ts, **/src/module/**/outbound/**/*.ts
---

# Port/Adapter Pattern (Hexagonal Architecture)

This document explains the Port/Adapter pattern used throughout the codebase for both inbound and outbound dependencies.

**For detailed layer-specific guidelines, see:**
- [nestjs-inbound.md](./nestjs-inbound.md) - Inbound adapter implementation details
- [nestjs-outbound.md](./nestjs-outbound.md) - Outbound adapter implementation details

## Core Concept

The Port/Adapter pattern (also known as Hexagonal Architecture) separates:
- **Port (Abstract Class)**: Abstract class defining what operations are available
- **Adapter (Implementation)**: Concrete implementation of those operations

### Pattern Formula

```
Port (Abstract Class) → Adapter (Implementation)
```

**Examples:**
```
UserRepositoryPort (Abstract Class) → MongoUserRepository (Adapter)
OrderRepositoryPort (Abstract Class) → PostgresOrderRepository (Adapter)
```

## Abstract Class Definition Pattern in NestJS

NestJS uses abstract classes for ports because they exist at runtime (unlike interfaces):

```typescript
// Port definition - abstract class
export abstract class UserRepositoryPort {
  abstract create(user: CreateUserDto): Promise<User>;
  abstract findById(id: string): Promise<User | null>;
  abstract findByEmail(email: string): Promise<User | null>;
}

// Adapter implementation - @Injectable() class
@Injectable()
export class MongoUserRepository extends UserRepositoryPort {
  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly logger: PinoLogger,
  ) {
    super();
    this.logger.setContext('user.repository.mongo');
  }

  async create(user: CreateUserDto): Promise<User> {
    const created = await this.userModel.create(user);
    return created.toObject();
  }

  async findById(id: string): Promise<User | null> {
    return this.userModel.findById(id).lean().exec();
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userModel.findOne({ email }).lean().exec();
  }
}
```

### Why Abstract Class (Not Interface)?

| Aspect | Abstract Class | Interface + Token |
|--------|---------------|-------------------|
| Runtime existence | Yes | No (interface erased) |
| DI token needed | No (itself is token) | Yes (Symbol/string) |
| Injection syntax | Type only | `@Inject(TOKEN)` required |
| Code complexity | Simple | More boilerplate |

**Use abstract class** - it's simpler and works natively with NestJS DI.

## DTO Model Patterns

**IMPORTANT - Be Conservative with DTOs:**
- **Default to domain models**: Return domain models directly when safe
- **Check for existing models**: Before creating DTOs, verify if shared/common models exist
- **Minimize code**: Only create DTOs when absolutely necessary

### When to Use DTOs

Create dedicated DTOs **only when**:
1. Domain model contains security-sensitive fields (passwords, internal IDs)
2. Response/output requires computed/derived fields not in domain
3. Data format significantly differs from domain model
4. Need to combine multiple domain models
5. Input validation requirements differ from domain model constraints

### When to Return Domain Models Directly (PREFERRED)

Return domain models directly when:
1. Domain model is safe to expose (no sensitive fields)
2. No transformation or computation needed
3. Data structure matches domain model

## File Organization Principles

### Port Location

Ports are defined at the **service level** (same directory as service):

```
module/{domain}/
├── {domain}.module.ts
├── {domain}.service.ts
├── {domain}.dto.ts
├── {domain}.repository.port.ts     # Port here
│
├── inbound/
│   └── {domain}.controller.ts
│
└── outbound/
    └── {domain}.repository.mongo.ts  # Adapter here
```

### Naming Conventions

**Port files:**
```
{domain}.repository.port.ts    # Repository port
{domain}.client.port.ts        # External service client port
```

**Adapter files:**
```
{domain}.repository.mongo.ts      # MongoDB implementation
{domain}.repository.postgres.ts   # PostgreSQL implementation
{domain}.client.stripe.ts         # Stripe client implementation
```

## Module Integration

**Key principle**: Module binds concrete adapters to Port types.

```typescript
// user.service.ts - depends on Port
@Injectable()
export class UserService {
  constructor(
    private readonly logger: PinoLogger,
    private readonly repo: UserRepositoryPort,  // Port type, not concrete
  ) {
    this.logger.setContext('user.service');
  }

  async createUser(dto: CreateUserDto): Promise<User> {
    return this.repo.create(dto);
  }
}

// user.module.ts - binds Adapter to Port
@Module({
  imports: [
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
  ],
  controllers: [UserController],
  providers: [
    UserService,
    {
      provide: UserRepositoryPort,
      useClass: MongoUserRepository,
    },
  ],
})
export class UserModule {}
```

This allows:
- **Flexibility**: Module can inject `MongoUserRepository`, `PostgresUserRepository`, or any adapter
- **Type Safety**: Service depends on Port abstract class, not concrete implementation
- **Testability**: Easy to inject mock adapters for testing

For detailed module configuration patterns, see [nestjs-module.md](./nestjs-module.md).

## Best Practices

1. **Use abstract classes for ports**: They work natively with NestJS DI
2. **Port at service level**: `{domain}.repository.port.ts` next to `{domain}.service.ts`
3. **Consistent naming**: Port (`{Domain}RepositoryPort`) and Adapter (`Mongo{Domain}Repository`)
4. **One adapter per file**: Each implementation in its own file under `outbound/`
5. **Full type annotations**: All parameters and return types must be typed
6. **Async methods**: Use `async` for all I/O operations
7. **Descriptive names**: `UserRepositoryPort`, `MongoUserRepository` (not `UserRepo`, `Mongo`)

## Summary

- **Port (Abstract Class)**: Abstract class defining operations
- **Adapter (Implementation)**: Concrete `@Injectable()` class extending Port
- **Location**: Port at service level, Adapter in `outbound/`
- **Binding**: Module binds Adapter to Port using `{ provide: Port, useClass: Adapter }`
- **Flexibility**: Easy to swap implementations (MongoDB → PostgreSQL)
- **Testability**: Easy to mock Port for testing

This pattern is used consistently across:
- **Inbound adapters**: HTTP Controllers, Schedulers, Queue Processors (see [nestjs-inbound.md](./nestjs-inbound.md))
- **Outbound adapters**: Repositories, external service clients (see [nestjs-outbound.md](./nestjs-outbound.md))

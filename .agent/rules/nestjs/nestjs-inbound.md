---
trigger: glob
globs: **/src/module/**/inbound/**/*.ts
paths: **/src/module/**/inbound/**/*.ts
---

# Inbound Adapter Guidelines

Inbound adapters handle incoming requests from external sources (HTTP, Cron, Queue, etc.) and translate them into service calls.

## Directory Structure

```
module/{domain}/inbound/
├── {domain}.controller.ts    # HTTP Controller
├── {domain}.scheduler.ts     # Cron jobs
└── {domain}.processor.ts     # Queue processor
```

**One file per inbound type** - No nested directories needed.

## Inbound Types and Module Registration

| Type | Decorator | Module Registration | File Naming |
|------|-----------|---------------------|-------------|
| HTTP | `@Controller()` | `controllers: []` | `{domain}.controller.ts` |
| Scheduler | `@Injectable()` + `@Cron()` | `providers: []` | `{domain}.scheduler.ts` |
| Queue | `@Processor()` | `providers: []` | `{domain}.processor.ts` |

**Key Rule**: Only HTTP Controllers go in `controllers[]`. Everything else goes in `providers[]`.

## Naming Conventions

### Class Names

**Pattern:** `{Domain}{Type}`

```typescript
// HTTP Controller
export class UserController { ... }

// Scheduler
export class UserScheduler { ... }

// Queue Processor
export class UserProcessor { ... }
```

### File Names

```
{domain}.controller.ts    # HTTP
{domain}.scheduler.ts     # Cron
{domain}.processor.ts     # Queue
```

## Common Handler Structure

All inbound adapters follow the same pattern:

1. **Inject dependencies** via constructor
2. **Set logger context** in constructor
3. **Call service layer** - don't implement business logic here
4. **Return result** - let exceptions propagate to global handlers

```typescript
@Controller('users')
export class UserController {
  constructor(
    private readonly logger: PinoLogger,
    private readonly userService: UserService,
  ) {
    this.logger.setContext('user.controller');
  }

  @Post()
  async createUser(@Body() dto: CreateUserDto): Promise<User> {
    return this.userService.createUser(dto);
  }
}
```

## Module Registration Example

```typescript
import { UserController } from './inbound/user.controller';
import { UserScheduler } from './inbound/user.scheduler';
import { UserProcessor } from './inbound/user.processor';

@Module({
  imports: [...],
  controllers: [
    UserController,      // HTTP only
  ],
  providers: [
    UserService,
    UserScheduler,       // Cron
    UserProcessor,       // Queue
    { provide: UserRepositoryPort, useClass: MongoUserRepository },
  ],
})
export class UserModule {}
```

## Key Principles

1. **Thin adapters**: Only translate requests to service calls
2. **No business logic**: All logic belongs in service layer
3. **No try/catch**: Let exceptions propagate to global filter
4. **Structured logging**: Set context in constructor

## Protocol-Specific Guidelines

For detailed implementation guidelines, see:
- **HTTP**: [nestjs-inbound-http.md](./nestjs-inbound-http.md)
- **Scheduler**: [nestjs-inbound-scheduler.md](./nestjs-inbound-scheduler.md)
- **Queue**: [nestjs-inbound-queue.md](./nestjs-inbound-queue.md)

## Common Mistakes to Avoid

1. **Putting non-HTTP in controllers[]**
   - ❌ `controllers: [UserScheduler]`
   - ✅ `providers: [UserScheduler]`

2. **Adding business logic in controllers**
   - ❌ Implementing validation/transformation in controller
   - ✅ Call service method and return result

3. **Catching exceptions in handlers**
   - ❌ `try { ... } catch { return errorResponse }`
   - ✅ Let exceptions propagate to global exception filter

4. **Creating nested directories**
   - ❌ `inbound/http/user.controller.ts`
   - ✅ `inbound/user.controller.ts`

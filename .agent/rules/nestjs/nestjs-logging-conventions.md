---
trigger: always_on
globs: **/src/**/*.ts
paths: **/src/**/*.ts
---

# Logging Conventions

This document defines logging standards using **Pino** (via nestjs-pino) as the standard logger.

## Why Pino?

- **Performance**: 5-10x faster than Winston
- **JSON structured**: Native JSON output for log aggregation
- **NestJS integration**: nestjs-pino provides seamless integration

## Package Setup

```bash
npm install nestjs-pino pino-http pino-pretty
```

Configure in PlatformModule:

```typescript
// platform/platform.module.ts
import { LoggerModule } from 'nestjs-pino';

@Global()
@Module({
  imports: [
    LoggerModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        pinoHttp: {
          level: config.get('LOG_LEVEL', 'info'),
          transport:
            config.get('NODE_ENV') !== 'production'
              ? { target: 'pino-pretty', options: { colorize: true } }
              : undefined,
          // Redact sensitive fields
          redact: ['req.headers.authorization', 'password'],
        },
      }),
      inject: [ConfigService],
    }),
  ],
})
export class PlatformModule {}
```

## Logger Injection

### Standard Pattern

```typescript
import { Injectable } from '@nestjs/common';
import { PinoLogger } from 'nestjs-pino';

@Injectable()
export class UserService {
  constructor(private readonly logger: PinoLogger) {
    this.logger.setContext('user.service');
  }
}
```

### Context Naming Convention

**Pattern**: `{domain}.{layer}.{implementation}`

| Layer | Context Example |
|-------|-----------------|
| Service | `user.service` |
| Controller | `user.controller` |
| Repository | `user.repository.mongo` |
| Scheduler | `user.scheduler` |
| Processor | `user.processor` |
| Client | `payment.client.stripe` |

## Logging Methods

### Log Levels

```typescript
this.logger.trace({ data }, 'Detailed trace info');
this.logger.debug({ data }, 'Debug info');
this.logger.info({ data }, 'General info');
this.logger.warn({ data }, 'Warning');
this.logger.error({ error }, 'Error occurred');
this.logger.fatal({ error }, 'Fatal error');
```

### Structured Logging

Always pass context data as first argument:

```typescript
// ✅ CORRECT - Structured data first, message second
this.logger.info({ userId, email }, 'User created');
this.logger.error({ error, userId }, 'Failed to create user');

// ❌ WRONG - Don't use string interpolation
this.logger.info(`User ${userId} created`);
this.logger.error(`Error: ${error.message}`);
```

## Common Logging Patterns

### Service Operations

```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly logger: PinoLogger,
    private readonly repo: UserRepositoryPort,
  ) {
    this.logger.setContext('user.service');
  }

  async createUser(dto: CreateUserDto): Promise<User> {
    this.logger.info({ email: dto.email }, 'Creating user');

    try {
      const user = await this.repo.create(dto);
      this.logger.info({ userId: user.id }, 'User created');
      return user;
    } catch (error) {
      this.logger.error({ error, email: dto.email }, 'Failed to create user');
      throw error;
    }
  }
}
```

### Controller (minimal logging)

```typescript
@Controller('users')
export class UserController {
  constructor(
    private readonly logger: PinoLogger,
    private readonly userService: UserService,
  ) {
    this.logger.setContext('user.controller');
  }

  // HTTP requests are logged automatically by pino-http
  // Only log notable events
  @Post()
  async create(@Body() dto: CreateUserDto): Promise<User> {
    return this.userService.createUser(dto);
  }
}
```

### Scheduler

```typescript
@Injectable()
export class ReportScheduler {
  constructor(
    private readonly logger: PinoLogger,
    private readonly reportService: ReportService,
  ) {
    this.logger.setContext('report.scheduler');
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async handleDailyReport(): Promise<void> {
    this.logger.info('Starting daily report generation');

    try {
      const result = await this.reportService.generateDailyReport();
      this.logger.info({ recordsProcessed: result.count }, 'Daily report completed');
    } catch (error) {
      this.logger.error({ error }, 'Daily report failed');
    }
  }
}
```

### Queue Processor

```typescript
@Processor('email')
export class EmailProcessor extends WorkerHost {
  constructor(
    private readonly logger: PinoLogger,
    private readonly emailService: EmailService,
  ) {
    super();
    this.logger.setContext('email.processor');
  }

  async process(job: Job<SendEmailJobData>): Promise<void> {
    this.logger.info({ jobId: job.id, to: job.data.to }, 'Processing email job');

    await this.emailService.send(job.data);

    this.logger.info({ jobId: job.id }, 'Email sent');
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job, error: Error): void {
    this.logger.error({ jobId: job.id, error }, 'Email job failed');
  }
}
```

## Error Logging

### Basic Error

```typescript
try {
  await this.repo.create(dto);
} catch (error) {
  this.logger.error({ error }, 'Operation failed');
  throw error;
}
```

### With Context

```typescript
try {
  await this.repo.update(id, dto);
} catch (error) {
  this.logger.error(
    { error, userId: id, operation: 'update' },
    'Failed to update user',
  );
  throw error;
}
```

## What to Log

### Always Log

- Service method entry (for important operations)
- Successful completion of important operations
- All errors with full context
- Scheduler/job start and completion
- External API calls (request/response summary)

### Never Log

- Passwords, tokens, secrets
- Full request/response bodies (unless debugging)
- High-frequency operations (use debug level)
- Sensitive personal data

## Environment Configuration

```bash
# .env
LOG_LEVEL=info          # trace, debug, info, warn, error, fatal
NODE_ENV=development    # development: pino-pretty, production: JSON
```

## Best Practices

1. **Set context in constructor**: `this.logger.setContext('domain.layer')`
2. **Structured data first**: `logger.info({ data }, 'message')`
3. **Include correlation IDs**: Pass through request context
4. **Log at appropriate levels**: info for normal, error for failures
5. **Redact sensitive data**: Configure redaction in LoggerModule
6. **Don't over-log**: Avoid logging every minor operation
7. **Error context**: Always include relevant IDs and operation details
8. **JSON format in production**: Disable pino-pretty in production

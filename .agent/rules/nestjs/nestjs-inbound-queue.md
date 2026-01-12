---
trigger: glob
globs: **/src/module/**/inbound/**/*.processor.ts
paths: **/src/module/**/inbound/**/*.processor.ts
---

# Queue Processor Inbound Handler Guidelines

This document defines guidelines specific to Queue Processor implementation using `@nestjs/bullmq`.

**For common patterns, see:**
- [nestjs-inbound.md](./nestjs-inbound.md) - Handler structure, module registration
- [nestjs-logging-conventions.md](./nestjs-logging-conventions.md) - Logger binding

## Package Setup

Install BullMQ packages:

```bash
npm install @nestjs/bullmq bullmq
```

Register `BullModule` in `PlatformModule`:

```typescript
// platform/platform.module.ts
import { BullModule } from '@nestjs/bullmq';

@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        connection: {
          host: config.get('REDIS_HOST'),
          port: config.get('REDIS_PORT'),
        },
      }),
      inject: [ConfigService],
    }),
    // ... other modules
  ],
})
export class PlatformModule {}
```

## Processor Implementation Pattern

### File: `{domain}/inbound/{domain}.processor.ts`

```typescript
import { Processor, WorkerHost, OnWorkerEvent } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PinoLogger } from 'nestjs-pino';
import { EmailService } from '../email.service';
import { SendEmailJobData } from '../email.dto';

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
    this.logger.info({ jobId: job.id, data: job.data }, 'Processing email job');

    await this.emailService.sendEmail(job.data);

    this.logger.info({ jobId: job.id }, 'Email job completed');
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job, error: Error): void {
    this.logger.error(
      { jobId: job.id, error, attempts: job.attemptsMade },
      'Email job failed',
    );
  }

  @OnWorkerEvent('completed')
  onCompleted(job: Job): void {
    this.logger.info({ jobId: job.id }, 'Email job completed successfully');
  }
}
```

## Queue Registration in Domain Module

Register the queue in the domain module:

```typescript
import { BullModule } from '@nestjs/bullmq';
import { EmailProcessor } from './inbound/email.processor';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'email',
    }),
  ],
  controllers: [EmailController],
  providers: [
    EmailService,
    EmailProcessor,  // Processor in providers
    { provide: EmailRepositoryPort, useClass: MongoEmailRepository },
  ],
})
export class EmailModule {}
```

## Adding Jobs to Queue

Inject the queue and add jobs from service:

```typescript
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class EmailService {
  constructor(
    @InjectQueue('email') private readonly emailQueue: Queue,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext('email.service');
  }

  async queueEmail(data: SendEmailJobData): Promise<void> {
    await this.emailQueue.add('send', data, {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 1000,
      },
    });
    this.logger.info({ data }, 'Email job queued');
  }
}
```

## Job Options

Common job options:

```typescript
await this.queue.add('jobName', data, {
  attempts: 3,                    // Retry 3 times
  backoff: {
    type: 'exponential',          // exponential, fixed
    delay: 1000,                  // Initial delay in ms
  },
  delay: 5000,                    // Delay before processing (ms)
  priority: 1,                    // Lower = higher priority
  removeOnComplete: true,         // Remove job data on success
  removeOnFail: false,            // Keep failed jobs for inspection
});
```

## Named Job Handlers

Handle different job types in one processor:

```typescript
@Processor('notification')
export class NotificationProcessor extends WorkerHost {
  async process(job: Job): Promise<void> {
    switch (job.name) {
      case 'email':
        await this.handleEmail(job);
        break;
      case 'sms':
        await this.handleSms(job);
        break;
      case 'push':
        await this.handlePush(job);
        break;
      default:
        this.logger.warn({ jobName: job.name }, 'Unknown job type');
    }
  }

  private async handleEmail(job: Job): Promise<void> {
    // Handle email notification
  }

  private async handleSms(job: Job): Promise<void> {
    // Handle SMS notification
  }

  private async handlePush(job: Job): Promise<void> {
    // Handle push notification
  }
}
```

## Worker Events

Available worker events:

| Event | When |
|-------|------|
| `completed` | Job completed successfully |
| `failed` | Job failed after all retries |
| `error` | Worker error (not job-specific) |
| `active` | Job started processing |
| `progress` | Job reported progress |
| `stalled` | Job stalled (took too long) |

```typescript
@OnWorkerEvent('failed')
onFailed(job: Job, error: Error): void {
  this.logger.error({ jobId: job.id, error }, 'Job failed');
}

@OnWorkerEvent('active')
onActive(job: Job): void {
  this.logger.info({ jobId: job.id }, 'Job started');
}
```

## Error Handling

Errors thrown in `process()` trigger retries (if configured):

```typescript
async process(job: Job<SendEmailJobData>): Promise<void> {
  try {
    await this.emailService.sendEmail(job.data);
  } catch (error) {
    this.logger.error({ jobId: job.id, error }, 'Email sending failed');
    throw error;  // Rethrow to trigger retry
  }
}
```

For permanent failures (no retry):

```typescript
import { UnrecoverableError } from 'bullmq';

async process(job: Job): Promise<void> {
  if (!this.isValidData(job.data)) {
    throw new UnrecoverableError('Invalid job data');  // No retry
  }
  // ...
}
```

## Module Registration

Processors go in `providers[]` (NOT `controllers[]`):

```typescript
@Module({
  imports: [
    BullModule.registerQueue({ name: 'email' }),
  ],
  controllers: [EmailController],
  providers: [
    EmailService,
    EmailProcessor,  // Processor in providers
  ],
})
export class EmailModule {}
```

## Best Practices

1. **Extend WorkerHost**: Required for BullMQ processors
2. **Log job lifecycle**: Log start, completion, and failures with job ID
3. **Configure retries**: Use `attempts` and `backoff` for reliability
4. **Use UnrecoverableError**: For permanent failures that shouldn't retry
5. **Type job data**: Create DTO types for job data
6. **Module in providers[]**: Processors are NOT controllers
7. **Logger context**: Set context in constructor with `setContext()`
8. **Idempotent jobs**: Design jobs to be safely re-runnable

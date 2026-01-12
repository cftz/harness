---
trigger: glob
globs: **/src/module/**/inbound/**/*.scheduler.ts
paths: **/src/module/**/inbound/**/*.scheduler.ts
---

# Scheduler Inbound Handler Guidelines

This document defines guidelines specific to Cron/Scheduler implementation using `@nestjs/schedule`.

**For common patterns, see:**
- [nestjs-inbound.md](./nestjs-inbound.md) - Handler structure, module registration
- [nestjs-logging-conventions.md](./nestjs-logging-conventions.md) - Logger binding

## Package Setup

Install the schedule package:

```bash
npm install @nestjs/schedule
```

Register `ScheduleModule` in `PlatformModule`:

```typescript
// platform/platform.module.ts
import { ScheduleModule } from '@nestjs/schedule';

@Global()
@Module({
  imports: [
    ScheduleModule.forRoot(),
    // ... other modules
  ],
})
export class PlatformModule {}
```

## Scheduler Implementation Pattern

### File: `{domain}/inbound/{domain}.scheduler.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression, Interval, Timeout } from '@nestjs/schedule';
import { PinoLogger } from 'nestjs-pino';
import { ReportService } from '../report.service';

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
      await this.reportService.generateDailyReport();
      this.logger.info('Daily report generation completed');
    } catch (error) {
      this.logger.error({ error }, 'Failed to generate daily report');
      // Don't rethrow - scheduler should continue
    }
  }

  @Cron('0 */6 * * *')  // Every 6 hours
  async handleCleanup(): Promise<void> {
    this.logger.info('Starting cleanup job');

    try {
      await this.reportService.cleanupOldReports();
      this.logger.info('Cleanup completed');
    } catch (error) {
      this.logger.error({ error }, 'Cleanup failed');
    }
  }
}
```

## Cron Decorators

### @Cron()

Use for scheduled jobs at specific times:

```typescript
import { Cron, CronExpression } from '@nestjs/schedule';

// Using CronExpression constants (recommended)
@Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
async handleMidnight(): Promise<void> { }

@Cron(CronExpression.EVERY_HOUR)
async handleHourly(): Promise<void> { }

// Using cron string
@Cron('0 0 * * *')    // Every day at midnight
@Cron('0 */2 * * *')  // Every 2 hours
@Cron('0 9 * * 1-5')  // 9 AM on weekdays
```

### Common CronExpression Constants

| Constant | Schedule |
|----------|----------|
| `EVERY_SECOND` | Every second |
| `EVERY_MINUTE` | Every minute |
| `EVERY_HOUR` | Every hour |
| `EVERY_DAY_AT_MIDNIGHT` | Midnight daily |
| `EVERY_WEEK` | Weekly |
| `EVERY_1ST_DAY_OF_MONTH_AT_MIDNIGHT` | Monthly |

### @Interval()

Use for recurring jobs at fixed intervals:

```typescript
import { Interval } from '@nestjs/schedule';

@Interval(30000)  // Every 30 seconds
async handleHeartbeat(): Promise<void> {
  await this.healthService.sendHeartbeat();
}
```

### @Timeout()

Use for one-time delayed execution:

```typescript
import { Timeout } from '@nestjs/schedule';

@Timeout(5000)  // Once, 5 seconds after app start
async handleStartup(): Promise<void> {
  await this.warmupService.warmCache();
}
```

## Error Handling

**Unlike HTTP controllers, schedulers SHOULD catch exceptions** to prevent job failures from crashing the scheduler:

```typescript
@Cron(CronExpression.EVERY_HOUR)
async handleHourlyJob(): Promise<void> {
  this.logger.info('Starting hourly job');

  try {
    await this.service.processHourlyJob();
    this.logger.info('Hourly job completed');
  } catch (error) {
    // Log error but don't rethrow
    this.logger.error({ error }, 'Hourly job failed');
    // Optionally: send alert, increment failure counter, etc.
  }
}
```

## Module Registration

Schedulers go in `providers[]` (NOT `controllers[]`):

```typescript
import { ReportScheduler } from './inbound/report.scheduler';

@Module({
  controllers: [ReportController],
  providers: [
    ReportService,
    ReportScheduler,  // Scheduler in providers
    { provide: ReportRepositoryPort, useClass: MongoReportRepository },
  ],
})
export class ReportModule {}
```

## Named Jobs and Control

For jobs that need to be controlled dynamically:

```typescript
import { Cron } from '@nestjs/schedule';
import { SchedulerRegistry } from '@nestjs/schedule';

@Injectable()
export class TaskScheduler {
  constructor(
    private readonly schedulerRegistry: SchedulerRegistry,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext('task.scheduler');
  }

  @Cron('0 * * * *', { name: 'hourlyTask' })
  async handleHourlyTask(): Promise<void> {
    // ...
  }

  // Programmatically control jobs
  stopHourlyTask(): void {
    const job = this.schedulerRegistry.getCronJob('hourlyTask');
    job.stop();
    this.logger.info('Stopped hourly task');
  }

  startHourlyTask(): void {
    const job = this.schedulerRegistry.getCronJob('hourlyTask');
    job.start();
    this.logger.info('Started hourly task');
  }
}
```

## Best Practices

1. **Catch exceptions**: Unlike HTTP, scheduler should handle its own errors
2. **Log job lifecycle**: Log start, completion, and failures
3. **Use CronExpression**: Prefer constants over raw cron strings
4. **Name important jobs**: Use `{ name: 'jobName' }` for jobs that need control
5. **Idempotent jobs**: Design jobs to be safely re-runnable
6. **Module in providers[]**: Schedulers are NOT controllers
7. **Logger context**: Set context in constructor with `setContext()`

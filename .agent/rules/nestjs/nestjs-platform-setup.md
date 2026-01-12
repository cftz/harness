---
trigger: glob
globs: **/src/platform/setup/**/*.ts
paths: **/src/platform/setup/**/*.ts
---

# Platform Setup Guidelines

This document describes how to create custom providers when no official NestJS module exists.

**IMPORTANT**: Always check for official modules first. See [nestjs-platform.md](./nestjs-platform.md).

## When to Create Custom Providers

Create custom providers **only when**:
1. No official NestJS module exists for the service
2. Official module doesn't meet requirements
3. Need to wrap a third-party library

## Directory Structure

```
platform/
├── platform.module.ts
└── setup/
    ├── redis.provider.ts
    ├── slack.provider.ts
    └── s3.provider.ts
```

## Custom Provider Pattern

### Basic Provider

```typescript
// platform/setup/redis.provider.ts
import { Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

export const REDIS_CLIENT = 'REDIS_CLIENT';

export const RedisProvider: Provider = {
  provide: REDIS_CLIENT,
  useFactory: (config: ConfigService): Redis => {
    return new Redis({
      host: config.get('REDIS_HOST'),
      port: config.get('REDIS_PORT'),
      password: config.get('REDIS_PASSWORD'),
    });
  },
  inject: [ConfigService],
};
```

### Async Provider with Initialization

```typescript
// platform/setup/slack.provider.ts
import { Provider } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { WebClient } from '@slack/web-api';
import { PinoLogger } from 'nestjs-pino';

export const SLACK_CLIENT = 'SLACK_CLIENT';

export const SlackProvider: Provider = {
  provide: SLACK_CLIENT,
  useFactory: async (
    config: ConfigService,
    logger: PinoLogger,
  ): Promise<WebClient> => {
    logger.setContext('slack.setup');
    logger.info('Initializing Slack client');

    const client = new WebClient(config.get('SLACK_TOKEN'));

    // Test connection
    const auth = await client.auth.test();
    logger.info({ team: auth.team }, 'Slack client connected');

    return client;
  },
  inject: [ConfigService, PinoLogger],
};
```

### Provider with Cleanup (OnModuleDestroy)

For clients that need cleanup, create a wrapper class:

```typescript
// platform/setup/redis.provider.ts
import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PinoLogger } from 'nestjs-pino';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleDestroy {
  public readonly client: Redis;

  constructor(
    private readonly config: ConfigService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext('redis.setup');

    this.client = new Redis({
      host: this.config.get('REDIS_HOST'),
      port: this.config.get('REDIS_PORT'),
    });

    this.client.on('connect', () => {
      this.logger.info('Redis connected');
    });

    this.client.on('error', (error) => {
      this.logger.error({ error }, 'Redis error');
    });
  }

  async onModuleDestroy(): Promise<void> {
    this.logger.info('Closing Redis connection');
    await this.client.quit();
  }
}
```

## Registering in Platform Module

```typescript
// platform/platform.module.ts
import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RedisProvider, REDIS_CLIENT } from './setup/redis.provider';
import { SlackProvider, SLACK_CLIENT } from './setup/slack.provider';

@Global()
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    // ... official modules
  ],
  providers: [
    RedisProvider,
    SlackProvider,
  ],
  exports: [
    REDIS_CLIENT,
    SLACK_CLIENT,
  ],
})
export class PlatformModule {}
```

## Using Custom Providers

### With Token Injection

```typescript
import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../../platform/setup/redis.provider';

@Injectable()
export class CacheService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
  ) {}

  async get(key: string): Promise<string | null> {
    return this.redis.get(key);
  }

  async set(key: string, value: string, ttl?: number): Promise<void> {
    if (ttl) {
      await this.redis.setex(key, ttl, value);
    } else {
      await this.redis.set(key, value);
    }
  }
}
```

### With Service Class

```typescript
import { Injectable } from '@nestjs/common';
import { RedisService } from '../../platform/setup/redis.provider';

@Injectable()
export class CacheService {
  constructor(private readonly redisService: RedisService) {}

  async get(key: string): Promise<string | null> {
    return this.redisService.client.get(key);
  }
}
```

## Provider Token Naming

Use SCREAMING_SNAKE_CASE for tokens:

```typescript
export const REDIS_CLIENT = 'REDIS_CLIENT';
export const SLACK_CLIENT = 'SLACK_CLIENT';
export const S3_CLIENT = 'S3_CLIENT';
export const STRIPE_CLIENT = 'STRIPE_CLIENT';
```

## Best Practices

1. **Check official first**: Always look for official NestJS modules
2. **Token naming**: Use SCREAMING_SNAKE_CASE for injection tokens
3. **Async initialization**: Use async useFactory for clients needing setup
4. **Error handling**: Log and handle initialization errors
5. **Cleanup**: Implement OnModuleDestroy for clients needing cleanup
6. **Export tokens**: Export both provider and token from platform module
7. **ConfigService**: Always use ConfigService for configuration values
8. **Logger context**: Set context in initialization for debugging

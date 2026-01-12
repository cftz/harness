---
trigger: glob
globs: **/src/platform/**/*.ts, **/src/platform/*.ts
paths: **/src/platform/**/*.ts, **/src/platform/*.ts
---

# Platform Module Guidelines

The Platform module contains shared infrastructure, utilities, and domain models used across all domain modules.

## Directory Structure

```
platform/
├── platform.module.ts       # @Global() module definition
├── domain/                  # Shared domain models/entities
│   ├── user.entity.ts
│   └── order.entity.ts
├── filter/                  # Global exception filters
│   └── http-exception.filter.ts
├── interceptor/             # Global interceptors
│   └── logging.interceptor.ts
└── setup/                   # Custom providers (when no official module)
    └── redis.provider.ts
```

## Platform Module Definition

```typescript
// platform/platform.module.ts
import { Global, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { ScheduleModule } from '@nestjs/schedule';
import { BullModule } from '@nestjs/bullmq';
import { LoggerModule } from 'nestjs-pino';

@Global()
@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Logging (Pino)
    LoggerModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        pinoHttp: {
          level: config.get('LOG_LEVEL', 'info'),
          transport:
            config.get('NODE_ENV') !== 'production'
              ? { target: 'pino-pretty' }
              : undefined,
        },
      }),
      inject: [ConfigService],
    }),

    // Database
    MongooseModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGODB_URI'),
      }),
      inject: [ConfigService],
    }),

    // Scheduler
    ScheduleModule.forRoot(),

    // Queue
    BullModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        connection: {
          host: config.get('REDIS_HOST'),
          port: config.get('REDIS_PORT'),
        },
      }),
      inject: [ConfigService],
    }),
  ],
  exports: [],
})
export class PlatformModule {}
```

## @Global() Decorator

The `@Global()` decorator makes the module available everywhere without explicit imports:

```typescript
@Global()
@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true })],
})
export class PlatformModule {}
```

**Benefits:**
- No need to import `PlatformModule` in every domain module
- ConfigService, Logger available everywhere
- Reduces boilerplate imports

## Official Modules First

**Always prefer official NestJS modules** over custom implementations:

| Feature | Official Module | Package |
|---------|----------------|---------|
| Configuration | ConfigModule | `@nestjs/config` |
| MongoDB | MongooseModule | `@nestjs/mongoose` |
| PostgreSQL | TypeOrmModule | `@nestjs/typeorm` |
| Caching | CacheModule | `@nestjs/cache-manager` |
| Scheduling | ScheduleModule | `@nestjs/schedule` |
| Queue | BullModule | `@nestjs/bullmq` |
| HTTP Client | HttpModule | `@nestjs/axios` |

**Only create custom providers** when no official module exists. See [nestjs-platform-setup.md](./nestjs-platform-setup.md).

## Shared Domain Models

Define shared entities in `platform/domain/`:

```typescript
// platform/domain/user.entity.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ default: true })
  isActive: boolean;

  createdAt: Date;
  updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);
```

Usage in domain modules:

```typescript
import { User, UserSchema } from '../../platform/domain/user.entity';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
  ],
})
export class UserModule {}
```

## Global Exception Filter

Define global filters in `platform/filter/`:

```typescript
// platform/filter/http-exception.filter.ts
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { PinoLogger } from 'nestjs-pino';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  constructor(private readonly logger: PinoLogger) {
    this.logger.setContext('exception-filter');
  }

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.message
        : 'Internal server error';

    this.logger.error({ exception, status }, 'Unhandled exception');

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

Register in `main.ts`:

```typescript
import { GlobalExceptionFilter } from './platform/filter/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Get logger instance for filter
  const logger = app.get(PinoLogger);
  app.useGlobalFilters(new GlobalExceptionFilter(logger));

  await app.listen(3000);
}
```

## App Module Integration

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { PlatformModule } from './platform/platform.module';
import { UserModule } from './module/user/user.module';
import { OrderModule } from './module/order/order.module';

@Module({
  imports: [
    PlatformModule,   // Platform first (global)
    UserModule,
    OrderModule,
  ],
})
export class AppModule {}
```

## Best Practices

1. **@Global() for platform**: Makes infrastructure available everywhere
2. **Official modules first**: Only create custom when necessary
3. **forRootAsync**: Use async configuration with ConfigService
4. **Domain models in platform**: Shared entities accessible to all modules
5. **Filters in platform**: Global exception handling
6. **Platform imported first**: Always first in AppModule imports
7. **No business logic**: Platform is infrastructure only

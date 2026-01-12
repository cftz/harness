---
trigger: glob
globs: **/src/module/**/*.module.ts, **/src/app.module.ts
paths: **/src/module/**/*.module.ts, **/src/app.module.ts
---

# Module Guidelines

This document describes the best practices for NestJS module organization and dependency injection patterns.

## Module Structure

### Domain Module

```typescript
// module/user/user.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../../platform/domain/user.entity';
import { UserService } from './user.service';
import { UserRepositoryPort } from './user.repository.port';
import { MongoUserRepository } from './outbound/user.repository.mongo';
import { UserController } from './inbound/user.controller';
import { UserScheduler } from './inbound/user.scheduler';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: User.name, schema: UserSchema }]),
  ],
  controllers: [
    UserController,      // HTTP Controllers only
  ],
  providers: [
    // Service
    UserService,

    // Inbound (non-HTTP)
    UserScheduler,

    // Outbound - Port to Adapter binding
    {
      provide: UserRepositoryPort,
      useClass: MongoUserRepository,
    },
  ],
  exports: [
    UserService,  // Export if other modules need it
  ],
})
export class UserModule {}
```

### App Module

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { PlatformModule } from './platform/platform.module';
import { AuthModule } from './module/core/auth/auth.module';
import { UserModule } from './module/user/user.module';
import { OrderModule } from './module/order/order.module';

@Module({
  imports: [
    PlatformModule,     // Global platform module first
    AuthModule,         // Core modules
    UserModule,         // Domain modules
    OrderModule,
  ],
})
export class AppModule {}
```

## controllers[] vs providers[]

| Registration | Type | Examples |
|--------------|------|----------|
| `controllers[]` | HTTP/gRPC Controllers | `@Controller()` decorated classes |
| `providers[]` | Everything else | Services, Schedulers, Processors, Repositories |

```typescript
@Module({
  controllers: [
    UserController,        // HTTP
    UserGrpcController,    // gRPC (if used)
  ],
  providers: [
    UserService,           // Service
    UserScheduler,         // Cron (@Injectable)
    UserProcessor,         // Queue (@Processor)
    { provide: UserRepositoryPort, useClass: MongoUserRepository },
  ],
})
```

## Port to Adapter Binding

Use `provide/useClass` to bind abstract Port to concrete Adapter:

```typescript
providers: [
  // Standard binding
  {
    provide: UserRepositoryPort,
    useClass: MongoUserRepository,
  },

  // With factory (for complex initialization)
  {
    provide: PaymentClientPort,
    useFactory: (config: ConfigService, logger: PinoLogger) => {
      return new StripePaymentClient(config, logger);
    },
    inject: [ConfigService, PinoLogger],
  },
]
```

## forFeature() Usage

Use `forFeature()` to register domain-specific resources:

### Mongoose

```typescript
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Profile.name, schema: ProfileSchema },
    ]),
  ],
})
```

### BullMQ

```typescript
@Module({
  imports: [
    BullModule.registerQueue({
      name: 'email',
    }),
  ],
})
```

### TypeORM

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([User, Profile]),
  ],
})
```

## Module Exports

Export services that other modules need:

```typescript
@Module({
  providers: [UserService],
  exports: [UserService],  // Other modules can inject UserService
})
export class UserModule {}

// In another module
@Module({
  imports: [UserModule],  // Import to use exported UserService
  providers: [OrderService],
})
export class OrderModule {}
```

**Note**: Avoid cross-module dependencies. Use Core modules for shared services.

## Core Module Pattern

Core modules provide cross-cutting services:

```typescript
// module/core/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from './auth.guard';

@Module({
  providers: [AuthService, AuthGuard],
  exports: [AuthService, AuthGuard],  // Export for other modules
})
export class AuthModule {}
```

Usage in domain modules:

```typescript
@Module({
  imports: [
    AuthModule,  // Import Core module
  ],
  providers: [
    UserService,  // Can inject AuthService
  ],
})
export class UserModule {}
```

## Dynamic Module Configuration

For modules with configuration:

```typescript
@Module({})
export class EmailModule {
  static forRoot(options: EmailModuleOptions): DynamicModule {
    return {
      module: EmailModule,
      providers: [
        {
          provide: 'EMAIL_OPTIONS',
          useValue: options,
        },
        EmailService,
      ],
      exports: [EmailService],
    };
  }

  static forRootAsync(options: EmailModuleAsyncOptions): DynamicModule {
    return {
      module: EmailModule,
      providers: [
        {
          provide: 'EMAIL_OPTIONS',
          useFactory: options.useFactory,
          inject: options.inject || [],
        },
        EmailService,
      ],
      exports: [EmailService],
    };
  }
}
```

## Best Practices

1. **One module per domain**: Each domain gets its own module file
2. **Clear separation**: controllers[] for HTTP, providers[] for everything else
3. **Port binding**: Use `{ provide: Port, useClass: Adapter }` pattern
4. **Minimal exports**: Only export what other modules actually need
5. **Core for shared**: Use Core modules for cross-cutting concerns
6. **forFeature for resources**: Register domain-specific schemas/entities
7. **Platform first**: Import PlatformModule first in AppModule
8. **Avoid circular**: Structure modules to avoid circular dependencies

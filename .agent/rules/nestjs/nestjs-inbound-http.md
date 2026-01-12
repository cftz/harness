---
trigger: glob
globs: **/src/module/**/inbound/**/*.controller.ts
paths: **/src/module/**/inbound/**/*.controller.ts
---

# HTTP Controller Guidelines

This document defines guidelines specific to HTTP Controller implementation.

**For common patterns, see:**
- [nestjs-inbound.md](./nestjs-inbound.md) - Handler structure, module registration
- [nestjs-logging-conventions.md](./nestjs-logging-conventions.md) - Logger binding

## Controller Implementation Pattern

### File: `{domain}/inbound/{domain}.controller.ts`

```typescript
import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { PinoLogger } from 'nestjs-pino';
import { UserService } from '../user.service';
import { CreateUserDto, UpdateUserDto, UserQueryDto } from '../user.dto';
import { User } from '../../../platform/domain/user.entity';

@Controller('users')
export class UserController {
  constructor(
    private readonly logger: PinoLogger,
    private readonly userService: UserService,
  ) {
    this.logger.setContext('user.controller');
  }

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<User> {
    return this.userService.createUser(dto);
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    return this.userService.getUser(id);
  }

  @Get()
  async findAll(@Query() query: UserQueryDto): Promise<User[]> {
    return this.userService.findUsers(query);
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateUserDto,
  ): Promise<User> {
    return this.userService.updateUser(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    return this.userService.deleteUser(id);
  }
}
```

### Key Components

1. **@Controller() decorator**: Define route prefix
2. **Constructor injection**: Logger first, then service
3. **Logger context**: Set in constructor
4. **No try/catch**: Let exceptions propagate to global filter
5. **Type hints**: Use DTOs for request, domain models for response

## Route Decorators

| Decorator | HTTP Method | Example |
|-----------|-------------|---------|
| `@Get()` | GET | `@Get(':id')` |
| `@Post()` | POST | `@Post()` |
| `@Put()` | PUT | `@Put(':id')` |
| `@Patch()` | PATCH | `@Patch(':id')` |
| `@Delete()` | DELETE | `@Delete(':id')` |

## Parameter Decorators

| Decorator | Purpose | Example |
|-----------|---------|---------|
| `@Body()` | Request body | `@Body() dto: CreateUserDto` |
| `@Param()` | URL parameters | `@Param('id') id: string` |
| `@Query()` | Query string | `@Query() query: QueryDto` |
| `@Headers()` | Request headers | `@Headers('authorization') auth: string` |

## Validation (Global)

Validation is handled globally via `ValidationPipe` in `main.ts`:

```typescript
// main.ts
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,      // Strip unknown properties
      transform: true,      // Transform to DTO class
      forbidNonWhitelisted: true,
    }),
  );

  await app.listen(3000);
}
```

DTOs use class-validator decorators for validation:

```typescript
// user.dto.ts
import { IsEmail, IsString, IsOptional, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  @MinLength(2)
  name?: string;

  @IsEmail()
  @IsOptional()
  email?: string;
}
```

For detailed DTO patterns, see [nestjs-dto.md](./nestjs-dto.md).

## Authentication with Guards

Use guards for authentication/authorization:

```typescript
import { UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../core/auth/auth.guard';

@Controller('users')
@UseGuards(AuthGuard)  // Apply to all routes
export class UserController {
  // ...

  @Get(':id')
  @UseGuards(AdminGuard)  // Additional guard for specific route
  async findOne(@Param('id') id: string): Promise<User> {
    return this.userService.getUser(id);
  }
}
```

## Error Handling (Global)

Error handling is done globally. Controllers should NOT catch exceptions:

```typescript
// ❌ WRONG - Don't catch exceptions in controller
@Get(':id')
async findOne(@Param('id') id: string): Promise<User> {
  try {
    return await this.userService.getUser(id);
  } catch (error) {
    throw new NotFoundException('User not found');
  }
}

// ✅ CORRECT - Let service throw, global filter handles
@Get(':id')
async findOne(@Param('id') id: string): Promise<User> {
  return this.userService.getUser(id);  // Service throws NotFoundException
}
```

## Module Registration

Controllers go in `controllers[]`:

```typescript
@Module({
  controllers: [UserController],  // HTTP Controllers here
  providers: [UserService, ...],
})
export class UserModule {}
```

## Best Practices

1. **No try/catch**: Let exceptions propagate to global filter
2. **Thin controllers**: Only call service methods, no business logic
3. **DTOs for input**: Use class-validator decorated DTOs
4. **Domain models for output**: Return domain models directly when safe
5. **Guards for auth**: Use `@UseGuards()` decorator
6. **Logger context**: Set in constructor with `setContext()`
7. **Async all methods**: All controller methods should be `async`

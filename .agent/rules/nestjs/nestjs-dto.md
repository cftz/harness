---
trigger: glob
globs: **/src/module/**/*.dto.ts
paths: **/src/module/**/*.dto.ts
---

# DTO Guidelines

This document defines guidelines for Data Transfer Objects using class-validator and class-transformer.

## File Location

DTOs are defined at the service level:

```
module/{domain}/
├── {domain}.module.ts
├── {domain}.service.ts
├── {domain}.dto.ts          # All DTOs for this domain
└── ...
```

## Package Setup

```bash
npm install class-validator class-transformer
```

Enable in `main.ts`:

```typescript
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // Strip unknown properties
      transform: true,           // Transform to DTO class instances
      forbidNonWhitelisted: true, // Throw on unknown properties
    }),
  );

  await app.listen(3000);
}
```

## DTO Naming Conventions

| Type | Naming | Example |
|------|--------|---------|
| Create | `Create{Domain}Dto` | `CreateUserDto` |
| Update | `Update{Domain}Dto` | `UpdateUserDto` |
| Query | `{Domain}QueryDto` | `UserQueryDto` |
| Response | `{Domain}ResponseDto` | `UserResponseDto` |
| Job Data | `{Action}{Domain}JobData` | `SendEmailJobData` |

## Basic DTO Pattern

```typescript
// user.dto.ts
import {
  IsString,
  IsEmail,
  IsOptional,
  MinLength,
  MaxLength,
  IsBoolean,
  IsNumber,
  Min,
  Max,
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  @MaxLength(50)
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
  @MaxLength(50)
  name?: string;

  @IsEmail()
  @IsOptional()
  email?: string;
}

export class UserQueryDto {
  @IsString()
  @IsOptional()
  search?: string;

  @IsNumber()
  @IsOptional()
  @Min(1)
  page?: number = 1;

  @IsNumber()
  @IsOptional()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
```

## Common Validators

### String Validators

```typescript
import { IsString, MinLength, MaxLength, Matches, IsUUID, IsUrl } from 'class-validator';

@IsString()
@MinLength(2)
@MaxLength(100)
name: string;

@IsUUID()
id: string;

@IsUrl()
website: string;

@Matches(/^[A-Z]{2,3}-\d{4}$/)  // e.g., "AB-1234"
code: string;
```

### Number Validators

```typescript
import { IsNumber, IsInt, Min, Max, IsPositive } from 'class-validator';

@IsNumber()
@Min(0)
@Max(100)
percentage: number;

@IsInt()
@IsPositive()
quantity: number;
```

### Boolean and Enum

```typescript
import { IsBoolean, IsEnum } from 'class-validator';

enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
}

@IsBoolean()
isActive: boolean;

@IsEnum(UserRole)
role: UserRole;
```

### Array and Nested

```typescript
import { IsArray, ValidateNested, ArrayMinSize, ArrayMaxSize, Type } from 'class-validator';

@IsArray()
@IsString({ each: true })
tags: string[];

@IsArray()
@ValidateNested({ each: true })
@Type(() => AddressDto)
addresses: AddressDto[];

@IsArray()
@ArrayMinSize(1)
@ArrayMaxSize(10)
items: string[];
```

### Optional Fields

```typescript
import { IsOptional } from 'class-validator';

// Optional with default
@IsNumber()
@IsOptional()
@Min(1)
page?: number = 1;

// Optional without default
@IsString()
@IsOptional()
nickname?: string;
```

## Transformation

Use class-transformer for type conversion:

```typescript
import { Transform, Type } from 'class-transformer';

// String to number (query params come as strings)
@Type(() => Number)
@IsNumber()
page: number;

// String to boolean
@Transform(({ value }) => value === 'true')
@IsBoolean()
isActive: boolean;

// Trim whitespace
@Transform(({ value }) => value?.trim())
@IsString()
name: string;

// Convert to lowercase
@Transform(({ value }) => value?.toLowerCase())
@IsEmail()
email: string;
```

## Nested DTOs

```typescript
import { ValidateNested, Type } from 'class-validator';

export class AddressDto {
  @IsString()
  street: string;

  @IsString()
  city: string;

  @IsString()
  @Matches(/^\d{5}$/)
  zipCode: string;
}

export class CreateUserDto {
  @IsString()
  name: string;

  @ValidateNested()
  @Type(() => AddressDto)
  address: AddressDto;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AddressDto)
  @IsOptional()
  additionalAddresses?: AddressDto[];
}
```

## Partial DTOs

Use mapped types for update DTOs:

```typescript
import { PartialType, PickType, OmitType, IntersectionType } from '@nestjs/mapped-types';

// All fields optional
export class UpdateUserDto extends PartialType(CreateUserDto) {}

// Only specific fields
export class UpdateEmailDto extends PickType(CreateUserDto, ['email'] as const) {}

// Exclude specific fields
export class CreateUserWithoutPasswordDto extends OmitType(CreateUserDto, ['password'] as const) {}

// Combine DTOs
export class ExtendedUserDto extends IntersectionType(CreateUserDto, AdditionalInfoDto) {}
```

## Custom Validators

```typescript
import {
  registerDecorator,
  ValidationOptions,
  ValidationArguments,
} from 'class-validator';

export function IsStrongPassword(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      name: 'isStrongPassword',
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      validator: {
        validate(value: string) {
          const hasUpperCase = /[A-Z]/.test(value);
          const hasLowerCase = /[a-z]/.test(value);
          const hasNumber = /\d/.test(value);
          const hasMinLength = value.length >= 8;
          return hasUpperCase && hasLowerCase && hasNumber && hasMinLength;
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must contain uppercase, lowercase, number and be at least 8 characters`;
        },
      },
    });
  };
}

// Usage
export class CreateUserDto {
  @IsStrongPassword()
  password: string;
}
```

## Best Practices

1. **One DTO file per domain**: Keep all DTOs in `{domain}.dto.ts`
2. **Use mapped types**: Extend CreateDto for UpdateDto
3. **Transform query params**: Use `@Type(() => Number)` for numeric query params
4. **Validate arrays**: Use `{ each: true }` option for array validation
5. **Custom error messages**: Provide clear validation messages
6. **Trim strings**: Use `@Transform` to trim whitespace
7. **Default values**: Provide sensible defaults for optional fields
8. **Nested validation**: Use `@ValidateNested()` with `@Type()`

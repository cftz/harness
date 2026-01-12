---
trigger: glob
globs: **/src/module/**/outbound/**/*.ts
paths: **/src/module/**/outbound/**/*.ts
---

# Outbound Adapter Guidelines

Outbound adapters handle external dependencies (databases, external APIs, etc.) and implement the Port interfaces defined at the service level.

## Directory Structure

```
module/{domain}/
├── {domain}.service.ts
├── {domain}.repository.port.ts     # Port at service level
│
└── outbound/
    ├── {domain}.repository.mongo.ts      # MongoDB implementation
    ├── {domain}.repository.postgres.ts   # PostgreSQL implementation (if needed)
    └── {domain}.client.stripe.ts         # External API client (if needed)
```

## Naming Conventions

### Port Files (at service level)

```
{domain}.repository.port.ts    # Repository port
{domain}.client.port.ts        # External service client port
```

### Adapter Files (in outbound/)

```
{domain}.repository.mongo.ts      # MongoDB repository
{domain}.repository.postgres.ts   # PostgreSQL repository
{domain}.client.stripe.ts         # Stripe client
{domain}.client.sendgrid.ts       # SendGrid client
```

## Repository Implementation Pattern

### Port Definition

File: `{domain}/{domain}.repository.port.ts`

```typescript
import { User } from '../../platform/domain/user.entity';
import { CreateUserDto, UpdateUserDto } from './user.dto';

export abstract class UserRepositoryPort {
  abstract create(dto: CreateUserDto): Promise<User>;
  abstract findById(id: string): Promise<User | null>;
  abstract findByEmail(email: string): Promise<User | null>;
  abstract findAll(): Promise<User[]>;
  abstract update(id: string, dto: UpdateUserDto): Promise<User>;
  abstract delete(id: string): Promise<void>;
}
```

### MongoDB Implementation

File: `{domain}/outbound/{domain}.repository.mongo.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { PinoLogger } from 'nestjs-pino';
import { UserRepositoryPort } from '../user.repository.port';
import { User, UserDocument } from '../../../platform/domain/user.entity';
import { CreateUserDto, UpdateUserDto } from '../user.dto';

@Injectable()
export class MongoUserRepository extends UserRepositoryPort {
  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly logger: PinoLogger,
  ) {
    super();
    this.logger.setContext('user.repository.mongo');
  }

  async create(dto: CreateUserDto): Promise<User> {
    const created = await this.userModel.create(dto);
    return created.toObject();
  }

  async findById(id: string): Promise<User | null> {
    return this.userModel.findById(id).lean().exec();
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userModel.findOne({ email }).lean().exec();
  }

  async findAll(): Promise<User[]> {
    return this.userModel.find().lean().exec();
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const updated = await this.userModel
      .findByIdAndUpdate(id, dto, { new: true })
      .lean()
      .exec();
    return updated;
  }

  async delete(id: string): Promise<void> {
    await this.userModel.findByIdAndDelete(id).exec();
  }
}
```

## External Client Implementation Pattern

### Port Definition

File: `{domain}/{domain}.client.port.ts`

```typescript
export interface PaymentResult {
  success: boolean;
  transactionId: string;
}

export abstract class PaymentClientPort {
  abstract charge(amount: number, currency: string, source: string): Promise<PaymentResult>;
  abstract refund(transactionId: string): Promise<PaymentResult>;
}
```

### Implementation

File: `{domain}/outbound/{domain}.client.stripe.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PinoLogger } from 'nestjs-pino';
import Stripe from 'stripe';
import { PaymentClientPort, PaymentResult } from '../payment.client.port';

@Injectable()
export class StripePaymentClient extends PaymentClientPort {
  private readonly stripe: Stripe;

  constructor(
    private readonly config: ConfigService,
    private readonly logger: PinoLogger,
  ) {
    super();
    this.logger.setContext('payment.client.stripe');
    this.stripe = new Stripe(this.config.get('STRIPE_SECRET_KEY'));
  }

  async charge(amount: number, currency: string, source: string): Promise<PaymentResult> {
    this.logger.info({ amount, currency }, 'Creating charge');

    const charge = await this.stripe.charges.create({
      amount,
      currency,
      source,
    });

    return {
      success: charge.status === 'succeeded',
      transactionId: charge.id,
    };
  }

  async refund(transactionId: string): Promise<PaymentResult> {
    this.logger.info({ transactionId }, 'Creating refund');

    const refund = await this.stripe.refunds.create({
      charge: transactionId,
    });

    return {
      success: refund.status === 'succeeded',
      transactionId: refund.id,
    };
  }
}
```

## Module Registration

Bind adapter to port in module:

```typescript
import { MongoUserRepository } from './outbound/user.repository.mongo';
import { UserRepositoryPort } from './user.repository.port';

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

## Mongoose Schema Definition

Define schemas in `platform/domain/`:

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

  @Prop()
  password?: string;

  @Prop({ default: true })
  isActive: boolean;

  createdAt: Date;
  updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);
```

## Best Practices

1. **Extend Port abstract class**: Required for proper DI binding
2. **Call super()**: Must call `super()` in constructor
3. **Logger context**: Set specific context (e.g., `user.repository.mongo`)
4. **Use .lean()**: For read operations to get plain objects
5. **Use .exec()**: Always call `.exec()` for proper promise handling
6. **One adapter per file**: Each implementation in its own file
7. **Port at service level**: Port definition next to service file
8. **Adapter in outbound/**: Implementation in `outbound/` directory
9. **Consistent naming**: `Mongo{Domain}Repository`, `Stripe{Domain}Client`

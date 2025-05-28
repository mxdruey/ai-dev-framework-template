# Cloud Deployment Guide

This guide extends the deployment guide with specific instructions for cloud-portable deployments, focusing on AWS but applicable to other cloud providers.

## Overview

The AI Development Framework now includes cloud portability as a core feature, allowing projects to run seamlessly:
- **Locally**: Using Docker Compose with LocalStack for AWS services
- **AWS**: Using ECS, Lambda, or EC2 with managed services
- **Other Clouds**: Adaptable patterns for Azure, GCP, etc.

## Cloud Portability Principles

### 1. Environment Abstraction

```javascript
// config/index.js
const config = {
  isProduction: process.env.NODE_ENV === 'production',
  isLocal: process.env.NODE_ENV === 'development',
  
  // Database configuration works everywhere
  database: {
    host: process.env.DATABASE_HOST || 'localhost',
    port: process.env.DATABASE_PORT || 5432,
    name: process.env.DATABASE_NAME || 'myapp',
    // In AWS: RDS endpoint
    // Locally: Docker postgres container
  },
  
  // Storage abstraction
  storage: {
    provider: process.env.STORAGE_PROVIDER || 'local',
    bucket: process.env.STORAGE_BUCKET || 'local-bucket',
    endpoint: process.env.STORAGE_ENDPOINT,
    // In AWS: Real S3
    // Locally: LocalStack S3
  },
  
  // Cache configuration
  cache: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    // In AWS: ElastiCache
    // Locally: Docker redis container
  }
};

export default config;
```

### 2. Service Abstraction Layer

```typescript
// services/storage.service.ts
import AWS from 'aws-sdk';
import fs from 'fs';
import path from 'path';
import config from '../config';

export class StorageService {
  private s3: AWS.S3;
  
  constructor() {
    if (config.storage.provider === 's3') {
      this.s3 = new AWS.S3({
        endpoint: config.storage.endpoint,
        s3ForcePathStyle: true, // Required for LocalStack
      });
    }
  }
  
  async uploadFile(key: string, buffer: Buffer): Promise<string> {
    if (config.storage.provider === 's3') {
      await this.s3.putObject({
        Bucket: config.storage.bucket,
        Key: key,
        Body: buffer,
      }).promise();
      
      return `s3://${config.storage.bucket}/${key}`;
    } else {
      // Local file system
      const localPath = path.join('./uploads', key);
      await fs.promises.writeFile(localPath, buffer);
      return `file://${localPath}`;
    }
  }
  
  async getFile(key: string): Promise<Buffer> {
    if (config.storage.provider === 's3') {
      const result = await this.s3.getObject({
        Bucket: config.storage.bucket,
        Key: key,
      }).promise();
      
      return result.Body as Buffer;
    } else {
      const localPath = path.join('./uploads', key);
      return await fs.promises.readFile(localPath);
    }
  }
}
```

## Local Development Setup

### 1. Using Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_HOST=postgres
      - REDIS_HOST=redis
      - STORAGE_PROVIDER=s3
      - STORAGE_ENDPOINT=http://localstack:4566
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    depends_on:
      - postgres
      - redis
      - localstack

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=s3,dynamodb,sqs,secretsmanager,lambda
      - DEFAULT_REGION=us-east-1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - localstack_data:/tmp/localstack
      - ./scripts/localstack-init.sh:/etc/localstack/init/ready.d/init-aws.sh

volumes:
  postgres_data:
  redis_data:
  localstack_data:
```

### 2. LocalStack Initialization

```bash
# scripts/localstack-init.sh
#!/bin/bash

# Create S3 buckets
aws --endpoint-url=http://localhost:4566 s3 mb s3://local-bucket

# Create DynamoDB tables if needed
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name sessions \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Create SQS queues
aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name task-queue

echo "LocalStack initialization complete!"
```

## AWS Deployment Options

### 1. ECS Fargate Deployment

```terraform
# infrastructure/terraform/modules/ecs-app/main.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "app"
    image = "${var.ecr_repository_url}:latest"
    
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    
    environment = [
      {
        name  = "NODE_ENV"
        value = var.environment
      },
      {
        name  = "DATABASE_HOST"
        value = var.database_endpoint
      },
      {
        name  = "REDIS_HOST"
        value = var.redis_endpoint
      },
      {
        name  = "STORAGE_PROVIDER"
        value = "s3"
      },
      {
        name  = "STORAGE_BUCKET"
        value = aws_s3_bucket.app_bucket.id
      }
    ]
    
    secrets = [
      {
        name      = "DATABASE_PASSWORD"
        valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
      },
      {
        name      = "JWT_SECRET"
        valueFrom = aws_secretsmanager_secret.jwt_secret.arn
      }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }
}
```

### 2. Lambda Deployment

```typescript
// src/lambda.ts - Lambda handler wrapper
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { app } from './app';
import serverlessExpress from '@vendia/serverless-express';

// Create serverless express instance
const serverlessApp = serverlessExpress({ app });

// Lambda handler
export const handler = async (
  event: APIGatewayProxyEvent,
  context: any
): Promise<APIGatewayProxyResult> => {
  // Warm up container
  if (event.source === 'serverless-plugin-warmup') {
    return {
      statusCode: 200,
      body: 'Lambda is warm!'
    };
  }
  
  // Handle API Gateway events
  return serverlessApp(event, context);
};
```

```yaml
# serverless.yml for Lambda deployment
service: ${self:custom.serviceName}

provider:
  name: aws
  runtime: nodejs18.x
  stage: ${opt:stage, 'dev'}
  region: ${opt:region, 'us-east-1'}
  environment:
    NODE_ENV: ${self:provider.stage}
    DATABASE_HOST: ${cf:rds-stack.DatabaseEndpoint}
    REDIS_HOST: ${cf:elasticache-stack.RedisEndpoint}
    STORAGE_BUCKET: ${self:custom.bucketName}
  
  iamRoleStatements:
    - Effect: Allow
      Action:
        - s3:GetObject
        - s3:PutObject
      Resource: "arn:aws:s3:::${self:custom.bucketName}/*"
    - Effect: Allow
      Action:
        - secretsmanager:GetSecretValue
      Resource: "*"

functions:
  api:
    handler: dist/lambda.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
    vpc:
      securityGroupIds:
        - ${cf:vpc-stack.LambdaSecurityGroup}
      subnetIds:
        - ${cf:vpc-stack.PrivateSubnet1}
        - ${cf:vpc-stack.PrivateSubnet2}
```

## Configuration Management

### 1. AWS Systems Manager Parameter Store

```bash
# scripts/aws-config-setup.sh
#!/bin/bash

ENVIRONMENT=$1
PROJECT_NAME=$2

# Create parameters
aws ssm put-parameter \
  --name "/${PROJECT_NAME}/${ENVIRONMENT}/database_url" \
  --value "postgresql://user:pass@rds-endpoint:5432/db" \
  --type "SecureString"

aws ssm put-parameter \
  --name "/${PROJECT_NAME}/${ENVIRONMENT}/redis_url" \
  --value "redis://elasticache-endpoint:6379" \
  --type "String"

aws ssm put-parameter \
  --name "/${PROJECT_NAME}/${ENVIRONMENT}/jwt_secret" \
  --value "your-secret-key" \
  --type "SecureString"

echo "✓ AWS parameters configured for ${ENVIRONMENT}"
```

### 2. Loading Configuration in Application

```typescript
// config/aws-config-loader.ts
import AWS from 'aws-sdk';

const ssm = new AWS.SSM();

export async function loadAwsConfig(): Promise<void> {
  if (process.env.NODE_ENV === 'development') {
    return; // Use local .env in development
  }
  
  const projectName = process.env.PROJECT_NAME;
  const environment = process.env.NODE_ENV;
  
  const params = await ssm.getParametersByPath({
    Path: `/${projectName}/${environment}/`,
    Recursive: true,
    WithDecryption: true,
  }).promise();
  
  // Set environment variables from Parameter Store
  params.Parameters?.forEach(param => {
    const key = param.Name!.split('/').pop()!.toUpperCase();
    process.env[key] = param.Value;
  });
}
```

## Monitoring and Observability

### 1. Structured Logging

```typescript
// utils/logger.ts
import winston from 'winston';
import config from '../config';

// CloudWatch-compatible format
const cloudWatchFormat = winston.format.printf(({ timestamp, level, message, ...meta }) => {
  return JSON.stringify({
    timestamp,
    level,
    message,
    ...meta,
    environment: config.environment,
    service: config.serviceName,
  });
});

export const logger = winston.createLogger({
  level: config.logLevel,
  format: winston.format.combine(
    winston.format.timestamp(),
    config.isLocal ? winston.format.simple() : cloudWatchFormat
  ),
  transports: [
    new winston.transports.Console(),
  ],
});
```

### 2. Health Checks

```typescript
// routes/health.ts
import { Router } from 'express';
import { checkDatabase, checkRedis, checkS3 } from '../utils/health-checks';

const router = Router();

// Basic health check for load balancer
router.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Detailed health check
router.get('/health/detailed', async (req, res) => {
  const checks = await Promise.allSettled([
    checkDatabase(),
    checkRedis(),
    checkS3(),
  ]);
  
  const results = {
    status: checks.every(c => c.status === 'fulfilled') ? 'healthy' : 'degraded',
    checks: {
      database: checks[0].status === 'fulfilled' ? 'healthy' : 'unhealthy',
      redis: checks[1].status === 'fulfilled' ? 'healthy' : 'unhealthy',
      storage: checks[2].status === 'fulfilled' ? 'healthy' : 'unhealthy',
    },
    timestamp: new Date().toISOString(),
  };
  
  res.status(results.status === 'healthy' ? 200 : 503).json(results);
});

export default router;
```

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: ${{ github.event.repository.name }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Run linter
        run: npm run lint
      
      - name: Build application
        run: npm run build

  deploy-dev:
    needs: test
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: development
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
      
      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:dev-latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:dev-latest
      
      - name: Deploy to ECS Dev
        run: |
          aws ecs update-service \
            --cluster dev-cluster \
            --service $ECR_REPOSITORY-dev \
            --force-new-deployment

  deploy-prod:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      # Similar to dev but with production configurations
      # Includes manual approval via GitHub environments
```

## Best Practices

### 1. Environment Parity
- Use the same Docker images locally and in production
- Match service versions (Postgres, Redis, etc.)
- Use LocalStack to emulate AWS services
- Test with production-like data volumes

### 2. Security
- Never commit secrets to git
- Use AWS Secrets Manager for sensitive data
- Implement least-privilege IAM policies
- Enable encryption at rest and in transit
- Regular security scanning of containers

### 3. Cost Optimization
- Use spot instances for non-critical workloads
- Implement auto-scaling based on metrics
- Use Lambda for sporadic workloads
- Enable S3 lifecycle policies
- Monitor costs with AWS Cost Explorer

### 4. Disaster Recovery
- Automated backups of databases
- Multi-region replication for critical data
- Infrastructure as Code for quick rebuilds
- Documented runbooks for incidents
- Regular disaster recovery drills

## Troubleshooting

### Common Issues

1. **LocalStack Connection Issues**
   ```bash
   # Verify LocalStack is running
   curl http://localhost:4566/_localstack/health
   
   # Check service availability
   aws --endpoint-url=http://localhost:4566 s3 ls
   ```

2. **Container Networking**
   ```bash
   # Inspect Docker network
   docker network inspect bridge
   
   # Test connectivity between containers
   docker exec app ping postgres
   ```

3. **AWS Permissions**
   ```bash
   # Test IAM permissions
   aws sts get-caller-identity
   
   # Verify specific permissions
   aws s3 ls s3://your-bucket/ --dryrun
   ```

---

**Remember: The goal of cloud portability is to maintain the same codebase across all environments. Configuration changes, not code changes!**
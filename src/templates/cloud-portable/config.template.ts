/**
 * Cloud-Portable Configuration Template
 * 
 * This template provides configuration management that works
 * across local development and cloud environments.
 */

import dotenv from 'dotenv';
import AWS from 'aws-sdk';
import { z } from 'zod';

// Load .env file in development
if (process.env.NODE_ENV !== 'production') {
  dotenv.config();
}

// Configuration schema with validation
const configSchema = z.object({
  // Application
  app: z.object({
    name: z.string().default('my-app'),
    env: z.enum(['development', 'staging', 'production']).default('development'),
    port: z.number().positive().default(3000),
    logLevel: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
  }),
  
  // Database
  database: z.object({
    host: z.string(),
    port: z.number().positive().default(5432),
    name: z.string(),
    user: z.string(),
    password: z.string(),
    ssl: z.boolean().default(false),
    poolMin: z.number().positive().default(2),
    poolMax: z.number().positive().default(10),
  }),
  
  // Redis
  redis: z.object({
    host: z.string(),
    port: z.number().positive().default(6379),
    password: z.string().optional(),
    tls: z.boolean().default(false),
  }),
  
  // Storage
  storage: z.object({
    provider: z.enum(['local', 's3']).default('local'),
    bucket: z.string().default('local-bucket'),
    region: z.string().default('us-east-1'),
    endpoint: z.string().optional(),
    localPath: z.string().default('./uploads'),
  }),
  
  // AWS
  aws: z.object({
    region: z.string().default('us-east-1'),
    accountId: z.string().optional(),
  }),
  
  // Security
  security: z.object({
    jwtSecret: z.string().min(32),
    bcryptRounds: z.number().positive().default(10),
    corsOrigins: z.array(z.string()).default(['http://localhost:3000']),
    trustedProxies: z.array(z.string()).default([]),
  }),
  
  // Features
  features: z.object({
    enableMetrics: z.boolean().default(true),
    enableTracing: z.boolean().default(false),
    enableRateLimit: z.boolean().default(true),
    rateLimitWindow: z.number().positive().default(900000), // 15 minutes
    rateLimitMax: z.number().positive().default(100),
  }),
});

type Config = z.infer<typeof configSchema>;

class ConfigurationManager {
  private static instance: ConfigurationManager;
  private config?: Config;
  private ssm?: AWS.SSM;
  private secretsManager?: AWS.SecretsManager;

  private constructor() {
    if (this.isCloudEnvironment()) {
      this.ssm = new AWS.SSM();
      this.secretsManager = new AWS.SecretsManager();
    }
  }

  static getInstance(): ConfigurationManager {
    if (!ConfigurationManager.instance) {
      ConfigurationManager.instance = new ConfigurationManager();
    }
    return ConfigurationManager.instance;
  }

  async load(): Promise<Config> {
    if (this.config) {
      return this.config;
    }

    let rawConfig: any = {};

    if (this.isCloudEnvironment()) {
      // Load from AWS Parameter Store and Secrets Manager
      rawConfig = await this.loadFromAWS();
    } else {
      // Load from environment variables
      rawConfig = this.loadFromEnv();
    }

    // Validate configuration
    try {
      this.config = configSchema.parse(rawConfig);
      return this.config;
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error('Configuration validation failed:', error.errors);
        throw new Error('Invalid configuration');
      }
      throw error;
    }
  }

  get(): Config {
    if (!this.config) {
      throw new Error('Configuration not loaded. Call load() first.');
    }
    return this.config;
  }

  private isCloudEnvironment(): boolean {
    return process.env.NODE_ENV === 'production' || 
           process.env.NODE_ENV === 'staging' ||
           process.env.AWS_EXECUTION_ENV !== undefined;
  }

  private async loadFromAWS(): Promise<any> {
    const projectName = process.env.PROJECT_NAME || 'my-app';
    const environment = process.env.NODE_ENV || 'development';
    
    // Load parameters from Parameter Store
    const parameters = await this.loadParametersFromSSM(
      `/${projectName}/${environment}/`
    );
    
    // Load secrets from Secrets Manager
    const secrets = await this.loadSecretsFromSecretsManager([
      `${projectName}-${environment}-db-password`,
      `${projectName}-${environment}-jwt-secret`,
      `${projectName}-${environment}-redis-auth`,
    ]);
    
    // Merge configuration
    return {
      app: {
        name: projectName,
        env: environment,
        port: parseInt(parameters.port || '3000'),
        logLevel: parameters.log_level || 'info',
      },
      database: {
        host: parameters.database_host || secrets['db-password']?.host,
        port: parseInt(parameters.database_port || '5432'),
        name: parameters.database_name || secrets['db-password']?.dbname,
        user: parameters.database_user || secrets['db-password']?.username,
        password: secrets['db-password']?.password,
        ssl: environment === 'production',
      },
      redis: {
        host: parameters.redis_host || secrets['redis-auth']?.endpoint,
        port: parseInt(parameters.redis_port || '6379'),
        password: secrets['redis-auth']?.auth_token,
        tls: environment === 'production',
      },
      storage: {
        provider: 's3',
        bucket: parameters.storage_bucket,
        region: process.env.AWS_REGION,
      },
      aws: {
        region: process.env.AWS_REGION || 'us-east-1',
        accountId: parameters.aws_account_id,
      },
      security: {
        jwtSecret: secrets['jwt-secret'] || 'dev-secret-change-in-production',
        corsOrigins: parameters.cors_origins?.split(',') || [],
      },
      features: {
        enableMetrics: parameters.enable_metrics === 'true',
        enableTracing: parameters.enable_tracing === 'true',
        enableRateLimit: parameters.enable_rate_limit !== 'false',
      },
    };
  }

  private async loadParametersFromSSM(path: string): Promise<Record<string, string>> {
    const params: Record<string, string> = {};
    let nextToken: string | undefined;
    
    do {
      const result = await this.ssm!.getParametersByPath({
        Path: path,
        Recursive: true,
        WithDecryption: true,
        NextToken: nextToken,
      }).promise();
      
      result.Parameters?.forEach(param => {
        const key = param.Name!.split('/').pop()!;
        params[key] = param.Value!;
      });
      
      nextToken = result.NextToken;
    } while (nextToken);
    
    return params;
  }

  private async loadSecretsFromSecretsManager(
    secretIds: string[]
  ): Promise<Record<string, any>> {
    const secrets: Record<string, any> = {};
    
    for (const secretId of secretIds) {
      try {
        const result = await this.secretsManager!.getSecretValue({
          SecretId: secretId,
        }).promise();
        
        const key = secretId.split('-').slice(-2).join('-');
        secrets[key] = JSON.parse(result.SecretString!);
      } catch (error: any) {
        if (error.code !== 'ResourceNotFoundException') {
          throw error;
        }
        // Secret doesn't exist, continue
      }
    }
    
    return secrets;
  }

  private loadFromEnv(): any {
    return {
      app: {
        name: process.env.APP_NAME,
        env: process.env.NODE_ENV,
        port: parseInt(process.env.PORT || '3000'),
        logLevel: process.env.LOG_LEVEL,
      },
      database: {
        host: process.env.DATABASE_HOST || 'localhost',
        port: parseInt(process.env.DATABASE_PORT || '5432'),
        name: process.env.DATABASE_NAME || 'myapp',
        user: process.env.DATABASE_USER || 'user',
        password: process.env.DATABASE_PASSWORD || 'password',
        ssl: process.env.DATABASE_SSL === 'true',
      },
      redis: {
        host: process.env.REDIS_HOST || 'localhost',
        port: parseInt(process.env.REDIS_PORT || '6379'),
        password: process.env.REDIS_PASSWORD,
        tls: process.env.REDIS_TLS === 'true',
      },
      storage: {
        provider: process.env.STORAGE_PROVIDER as 'local' | 's3' || 'local',
        bucket: process.env.STORAGE_BUCKET,
        region: process.env.AWS_REGION,
        endpoint: process.env.STORAGE_ENDPOINT,
        localPath: process.env.LOCAL_STORAGE_PATH,
      },
      aws: {
        region: process.env.AWS_REGION,
        accountId: process.env.AWS_ACCOUNT_ID,
      },
      security: {
        jwtSecret: process.env.JWT_SECRET || 'dev-secret-change-in-production',
        bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '10'),
        corsOrigins: process.env.CORS_ORIGINS?.split(',') || [],
        trustedProxies: process.env.TRUSTED_PROXIES?.split(',') || [],
      },
      features: {
        enableMetrics: process.env.ENABLE_METRICS !== 'false',
        enableTracing: process.env.ENABLE_TRACING === 'true',
        enableRateLimit: process.env.ENABLE_RATE_LIMIT !== 'false',
        rateLimitWindow: parseInt(process.env.RATE_LIMIT_WINDOW || '900000'),
        rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX || '100'),
      },
    };
  }
}

// Export singleton instance
export const configManager = ConfigurationManager.getInstance();

// Export config type
export type { Config };

// Convenience function to get config
export async function getConfig(): Promise<Config> {
  return configManager.load();
}

// Example usage
if (require.main === module) {
  (async () => {
    try {
      const config = await getConfig();
      console.log('Configuration loaded:', JSON.stringify(config, null, 2));
    } catch (error) {
      console.error('Failed to load configuration:', error);
      process.exit(1);
    }
  })();
}
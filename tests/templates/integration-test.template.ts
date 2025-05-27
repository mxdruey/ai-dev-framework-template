/**
 * Integration Test Template
 * 
 * This template provides a foundation for integration testing
 * with real database and external service connections.
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from '@jest/globals';
import supertest from 'supertest';
import { createApp } from '../src/app';
import { Database } from '../src/database';
import { RedisClient } from '../src/redis';
import { TestDataBuilder } from './helpers/test-data-builder';

let app: any;
let request: supertest.SuperTest<supertest.Test>;
let database: Database;
let redis: RedisClient;
let testData: TestDataBuilder;

describe('API Integration Tests', () => {
  beforeAll(async () => {
    // Set up test environment
    process.env.NODE_ENV = 'test';
    process.env.DATABASE_URL = process.env.TEST_DATABASE_URL;
    
    // Initialize services
    database = new Database();
    redis = new RedisClient();
    
    // Connect to test database
    await database.connect();
    await redis.connect();
    
    // Run migrations
    await database.migrate();
    
    // Create app instance
    app = createApp({ database, redis });
    request = supertest(app);
    
    // Initialize test data builder
    testData = new TestDataBuilder(database);
  });
  
  afterAll(async () => {
    // Clean up connections
    await database.disconnect();
    await redis.disconnect();
  });
  
  beforeEach(async () => {
    // Clean database before each test
    await database.truncateAll();
    await redis.flushAll();
  });
  
  afterEach(async () => {
    // Additional cleanup if needed
  });
  
  describe('Authentication', () => {
    describe('POST /api/auth/register', () => {
      it('should register new user successfully', async () => {
        // Arrange
        const userData = {
          email: 'test@example.com',
          password: 'SecurePassword123!',
          name: 'Test User'
        };
        
        // Act
        const response = await request
          .post('/api/auth/register')
          .send(userData)
          .expect(201);
        
        // Assert
        expect(response.body).toMatchObject({
          success: true,
          data: {
            user: {
              email: userData.email,
              name: userData.name
            },
            token: expect.any(String)
          }
        });
        
        // Verify user was created in database
        const user = await database.users.findByEmail(userData.email);
        expect(user).toBeTruthy();
        expect(user.email).toBe(userData.email);
      });
      
      it('should reject duplicate email registration', async () => {
        // Arrange
        const userData = {
          email: 'existing@example.com',
          password: 'Password123!',
          name: 'Existing User'
        };
        
        // Create existing user
        await testData.createUser(userData);
        
        // Act
        const response = await request
          .post('/api/auth/register')
          .send(userData)
          .expect(409);
        
        // Assert
        expect(response.body).toMatchObject({
          success: false,
          error: {
            code: 'USER_EXISTS',
            message: 'User with this email already exists'
          }
        });
      });
      
      it('should validate password strength', async () => {
        // Arrange
        const userData = {
          email: 'test@example.com',
          password: 'weak',
          name: 'Test User'
        };
        
        // Act
        const response = await request
          .post('/api/auth/register')
          .send(userData)
          .expect(400);
        
        // Assert
        expect(response.body.error.code).toBe('VALIDATION_ERROR');
        expect(response.body.error.details).toContainEqual(
          expect.objectContaining({
            field: 'password',
            message: expect.stringContaining('Password must')
          })
        );
      });
    });
    
    describe('POST /api/auth/login', () => {
      it('should login with valid credentials', async () => {
        // Arrange
        const password = 'Password123!';
        const user = await testData.createUser({
          email: 'user@example.com',
          password,
          name: 'Test User'
        });
        
        // Act
        const response = await request
          .post('/api/auth/login')
          .send({
            email: user.email,
            password
          })
          .expect(200);
        
        // Assert
        expect(response.body).toMatchObject({
          success: true,
          data: {
            user: {
              id: user.id,
              email: user.email
            },
            token: expect.any(String),
            refreshToken: expect.any(String)
          }
        });
        
        // Verify token works
        const profileResponse = await request
          .get('/api/users/profile')
          .set('Authorization', `Bearer ${response.body.data.token}`)
          .expect(200);
        
        expect(profileResponse.body.data.id).toBe(user.id);
      });
      
      it('should reject invalid credentials', async () => {
        // Arrange
        const user = await testData.createUser({
          email: 'user@example.com',
          password: 'RealPassword123!',
          name: 'Test User'
        });
        
        // Act
        const response = await request
          .post('/api/auth/login')
          .send({
            email: user.email,
            password: 'WrongPassword123!'
          })
          .expect(401);
        
        // Assert
        expect(response.body).toMatchObject({
          success: false,
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      });
    });
  });
  
  describe('Resources API', () => {
    let authToken: string;
    let user: any;
    
    beforeEach(async () => {
      // Create authenticated user for tests
      user = await testData.createUser({
        email: 'auth@example.com',
        password: 'Password123!',
        name: 'Auth User'
      });
      
      authToken = await testData.generateAuthToken(user);
    });
    
    describe('GET /api/resources', () => {
      it('should return paginated resources', async () => {
        // Arrange
        const resources = await Promise.all([
          testData.createResource({ name: 'Resource 1', userId: user.id }),
          testData.createResource({ name: 'Resource 2', userId: user.id }),
          testData.createResource({ name: 'Resource 3', userId: user.id })
        ]);
        
        // Act
        const response = await request
          .get('/api/resources')
          .set('Authorization', `Bearer ${authToken}`)
          .query({ page: 1, limit: 2 })
          .expect(200);
        
        // Assert
        expect(response.body).toMatchObject({
          success: true,
          data: expect.arrayContaining([
            expect.objectContaining({ name: 'Resource 1' }),
            expect.objectContaining({ name: 'Resource 2' })
          ]),
          pagination: {
            total: 3,
            page: 1,
            limit: 2,
            pages: 2
          }
        });
        
        expect(response.body.data).toHaveLength(2);
      });
      
      it('should filter resources', async () => {
        // Arrange
        await Promise.all([
          testData.createResource({ name: 'Active Resource', status: 'active', userId: user.id }),
          testData.createResource({ name: 'Inactive Resource', status: 'inactive', userId: user.id }),
          testData.createResource({ name: 'Another Active', status: 'active', userId: user.id })
        ]);
        
        // Act
        const response = await request
          .get('/api/resources')
          .set('Authorization', `Bearer ${authToken}`)
          .query({ filter: JSON.stringify({ status: 'active' }) })
          .expect(200);
        
        // Assert
        expect(response.body.data).toHaveLength(2);
        expect(response.body.data.every((r: any) => r.status === 'active')).toBe(true);
      });
    });
    
    describe('POST /api/resources', () => {
      it('should create new resource', async () => {
        // Arrange
        const resourceData = {
          name: 'New Resource',
          description: 'Test Description',
          tags: ['test', 'integration']
        };
        
        // Act
        const response = await request
          .post('/api/resources')
          .set('Authorization', `Bearer ${authToken}`)
          .send(resourceData)
          .expect(201);
        
        // Assert
        expect(response.body).toMatchObject({
          success: true,
          data: {
            id: expect.any(String),
            ...resourceData,
            userId: user.id,
            createdAt: expect.any(String),
            updatedAt: expect.any(String)
          }
        });
        
        // Verify in database
        const dbResource = await database.resources.findById(response.body.data.id);
        expect(dbResource).toBeTruthy();
        expect(dbResource.name).toBe(resourceData.name);
      });
      
      it('should validate required fields', async () => {
        // Arrange
        const invalidData = {
          description: 'Missing name field'
        };
        
        // Act
        const response = await request
          .post('/api/resources')
          .set('Authorization', `Bearer ${authToken}`)
          .send(invalidData)
          .expect(400);
        
        // Assert
        expect(response.body.error.code).toBe('VALIDATION_ERROR');
        expect(response.body.error.details).toContainEqual(
          expect.objectContaining({
            field: 'name',
            message: expect.stringContaining('required')
          })
        );
      });
    });
    
    describe('DELETE /api/resources/:id', () => {
      it('should delete own resource', async () => {
        // Arrange
        const resource = await testData.createResource({
          name: 'To Be Deleted',
          userId: user.id
        });
        
        // Act
        const response = await request
          .delete(`/api/resources/${resource.id}`)
          .set('Authorization', `Bearer ${authToken}`)
          .expect(200);
        
        // Assert
        expect(response.body).toMatchObject({
          success: true,
          message: 'Resource deleted successfully'
        });
        
        // Verify deletion
        const dbResource = await database.resources.findById(resource.id);
        expect(dbResource).toBeNull();
      });
      
      it('should not delete other users resource', async () => {
        // Arrange
        const otherUser = await testData.createUser({
          email: 'other@example.com',
          password: 'Password123!'
        });
        
        const resource = await testData.createResource({
          name: 'Other User Resource',
          userId: otherUser.id
        });
        
        // Act
        const response = await request
          .delete(`/api/resources/${resource.id}`)
          .set('Authorization', `Bearer ${authToken}`)
          .expect(403);
        
        // Assert
        expect(response.body.error.code).toBe('FORBIDDEN');
        
        // Verify not deleted
        const dbResource = await database.resources.findById(resource.id);
        expect(dbResource).toBeTruthy();
      });
    });
  });
  
  describe('Caching', () => {
    it('should cache frequently accessed data', async () => {
      // Arrange
      const user = await testData.createUser();
      const authToken = await testData.generateAuthToken(user);
      
      // First request - should hit database
      const response1 = await request
        .get('/api/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
      
      // Verify data was cached
      const cachedData = await redis.get(`user:${user.id}`);
      expect(cachedData).toBeTruthy();
      expect(JSON.parse(cachedData)).toMatchObject({
        id: user.id,
        email: user.email
      });
      
      // Second request - should hit cache
      const response2 = await request
        .get('/api/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
      
      // Responses should be identical
      expect(response1.body).toEqual(response2.body);
    });
  });
  
  describe('Rate Limiting', () => {
    it('should enforce rate limits', async () => {
      // Arrange
      const user = await testData.createUser();
      const authToken = await testData.generateAuthToken(user);
      
      // Make requests up to the limit
      const limit = 10;
      const requests = [];
      
      for (let i = 0; i < limit; i++) {
        requests.push(
          request
            .get('/api/resources')
            .set('Authorization', `Bearer ${authToken}`)
            .expect(200)
        );
      }
      
      await Promise.all(requests);
      
      // Make one more request - should be rate limited
      const response = await request
        .get('/api/resources')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(429);
      
      // Assert
      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: 'RATE_LIMITED',
          message: expect.stringContaining('Too many requests')
        }
      });
      
      expect(response.headers['x-ratelimit-limit']).toBe(String(limit));
      expect(response.headers['x-ratelimit-remaining']).toBe('0');
      expect(response.headers['x-ratelimit-reset']).toBeTruthy();
    });
  });
});
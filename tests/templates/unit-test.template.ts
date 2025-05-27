/**
 * Unit Test Template
 * 
 * This template provides a foundation for unit testing
 * with Jest and TypeScript.
 */

import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import { Service } from '../src/services/service';
import { Repository } from '../src/repositories/repository';
import { Logger } from '../src/utils/logger';
import { ServiceError } from '../src/errors/service-error';

// Mock dependencies
jest.mock('../src/repositories/repository');
jest.mock('../src/utils/logger');

describe('Service', () => {
  let service: Service;
  let mockRepository: jest.Mocked<Repository>;
  let mockLogger: jest.Mocked<Logger>;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create mock instances
    mockRepository = new Repository() as jest.Mocked<Repository>;
    mockLogger = new Logger() as jest.Mocked<Logger>;
    
    // Create service instance with mocks
    service = new Service(mockRepository, mockLogger);
  });
  
  afterEach(() => {
    // Cleanup if needed
  });
  
  describe('create', () => {
    it('should create entity successfully', async () => {
      // Arrange
      const input = {
        name: 'Test Entity',
        description: 'Test Description'
      };
      
      const expectedEntity = {
        id: '123',
        ...input,
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      mockRepository.create.mockResolvedValue(expectedEntity);
      
      // Act
      const result = await service.create(input);
      
      // Assert
      expect(result).toEqual(expectedEntity);
      expect(mockRepository.create).toHaveBeenCalledWith(input);
      expect(mockLogger.info).toHaveBeenCalledWith(
        'Creating new entity',
        expect.objectContaining({ data: input })
      );
    });
    
    it('should handle validation errors', async () => {
      // Arrange
      const invalidInput = {
        name: '', // Invalid: empty name
        description: 'Test'
      };
      
      // Act & Assert
      await expect(service.create(invalidInput))
        .rejects
        .toThrow(ServiceError);
      
      expect(mockRepository.create).not.toHaveBeenCalled();
    });
    
    it('should handle repository errors', async () => {
      // Arrange
      const input = { name: 'Test', description: 'Test' };
      const dbError = new Error('Database connection failed');
      
      mockRepository.create.mockRejectedValue(dbError);
      
      // Act & Assert
      await expect(service.create(input))
        .rejects
        .toThrow(ServiceError);
      
      expect(mockLogger.error).toHaveBeenCalledWith(
        'Failed to create entity',
        expect.objectContaining({ error: dbError })
      );
    });
  });
  
  describe('findById', () => {
    it('should return entity when found', async () => {
      // Arrange
      const id = '123';
      const expectedEntity = {
        id,
        name: 'Test Entity',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      mockRepository.findById.mockResolvedValue(expectedEntity);
      
      // Act
      const result = await service.findById(id);
      
      // Assert
      expect(result).toEqual(expectedEntity);
      expect(mockRepository.findById).toHaveBeenCalledWith(id);
    });
    
    it('should return null when entity not found', async () => {
      // Arrange
      const id = 'non-existent';
      mockRepository.findById.mockResolvedValue(null);
      
      // Act
      const result = await service.findById(id);
      
      // Assert
      expect(result).toBeNull();
      expect(mockLogger.warn).toHaveBeenCalledWith(
        'Entity not found',
        expect.objectContaining({ id })
      );
    });
  });
  
  describe('update', () => {
    it('should update entity successfully', async () => {
      // Arrange
      const id = '123';
      const existingEntity = {
        id,
        name: 'Old Name',
        description: 'Old Description',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      const updateData = {
        name: 'New Name',
        description: 'New Description'
      };
      
      const updatedEntity = {
        ...existingEntity,
        ...updateData,
        updatedAt: new Date()
      };
      
      mockRepository.findById.mockResolvedValue(existingEntity);
      mockRepository.update.mockResolvedValue(updatedEntity);
      
      // Act
      const result = await service.update(id, updateData);
      
      // Assert
      expect(result).toEqual(updatedEntity);
      expect(mockRepository.findById).toHaveBeenCalledWith(id);
      expect(mockRepository.update).toHaveBeenCalledWith(
        id,
        expect.objectContaining(updateData)
      );
    });
    
    it('should throw error when entity not found', async () => {
      // Arrange
      const id = 'non-existent';
      const updateData = { name: 'New Name' };
      
      mockRepository.findById.mockResolvedValue(null);
      
      // Act & Assert
      await expect(service.update(id, updateData))
        .rejects
        .toThrow('Entity not found');
      
      expect(mockRepository.update).not.toHaveBeenCalled();
    });
  });
  
  describe('delete', () => {
    it('should delete entity successfully', async () => {
      // Arrange
      const id = '123';
      const existingEntity = {
        id,
        name: 'Test Entity',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      mockRepository.findById.mockResolvedValue(existingEntity);
      mockRepository.delete.mockResolvedValue(undefined);
      
      // Act
      await service.delete(id);
      
      // Assert
      expect(mockRepository.findById).toHaveBeenCalledWith(id);
      expect(mockRepository.delete).toHaveBeenCalledWith(id);
      expect(mockLogger.info).toHaveBeenCalledWith(
        'Entity deleted successfully',
        expect.objectContaining({ entityId: id })
      );
    });
    
    it('should throw error when entity not found', async () => {
      // Arrange
      const id = 'non-existent';
      mockRepository.findById.mockResolvedValue(null);
      
      // Act & Assert
      await expect(service.delete(id))
        .rejects
        .toThrow('Entity not found');
      
      expect(mockRepository.delete).not.toHaveBeenCalled();
    });
  });
  
  describe('list', () => {
    it('should return paginated results', async () => {
      // Arrange
      const options = {
        page: 2,
        limit: 10,
        filter: { status: 'active' },
        sort: { createdAt: 'desc' as const }
      };
      
      const items = [
        { id: '1', name: 'Item 1' },
        { id: '2', name: 'Item 2' }
      ];
      
      const total = 25;
      
      mockRepository.findMany.mockResolvedValue(items);
      mockRepository.count.mockResolvedValue(total);
      
      // Act
      const result = await service.list(options);
      
      // Assert
      expect(result).toEqual({
        items,
        total,
        page: 2,
        limit: 10
      });
      
      expect(mockRepository.findMany).toHaveBeenCalledWith({
        limit: 10,
        offset: 10, // (page - 1) * limit
        where: options.filter,
        orderBy: options.sort
      });
      
      expect(mockRepository.count).toHaveBeenCalledWith(options.filter);
    });
    
    it('should use default pagination values', async () => {
      // Arrange
      const items = [{ id: '1', name: 'Item 1' }];
      const total = 1;
      
      mockRepository.findMany.mockResolvedValue(items);
      mockRepository.count.mockResolvedValue(total);
      
      // Act
      const result = await service.list({});
      
      // Assert
      expect(result.page).toBe(1);
      expect(result.limit).toBe(20);
      
      expect(mockRepository.findMany).toHaveBeenCalledWith({
        limit: 20,
        offset: 0,
        where: undefined,
        orderBy: undefined
      });
    });
  });
});

// Test utilities and helpers
describe('Test Utilities', () => {
  describe('createMockEntity', () => {
    it('should create entity with default values', () => {
      const entity = createMockEntity();
      
      expect(entity).toHaveProperty('id');
      expect(entity).toHaveProperty('createdAt');
      expect(entity).toHaveProperty('updatedAt');
    });
    
    it('should override default values', () => {
      const customData = { name: 'Custom Name' };
      const entity = createMockEntity(customData);
      
      expect(entity.name).toBe('Custom Name');
    });
  });
});

// Helper functions
function createMockEntity(overrides = {}) {
  return {
    id: '123',
    name: 'Test Entity',
    description: 'Test Description',
    createdAt: new Date('2024-01-01'),
    updatedAt: new Date('2024-01-01'),
    ...overrides
  };
}
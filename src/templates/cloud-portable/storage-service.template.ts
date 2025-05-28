/**
 * Cloud-Portable Storage Service Template
 * 
 * This template provides a storage abstraction that works
 * with both local file system and cloud storage (S3).
 */

import AWS from 'aws-sdk';
import fs from 'fs';
import path from 'path';
import { Readable } from 'stream';
import crypto from 'crypto';

interface StorageConfig {
  provider: 'local' | 's3';
  bucket?: string;
  endpoint?: string;
  region?: string;
  localPath?: string;
}

interface UploadOptions {
  contentType?: string;
  metadata?: Record<string, string>;
  public?: boolean;
}

interface StorageObject {
  key: string;
  size: number;
  lastModified: Date;
  etag?: string;
  contentType?: string;
}

export class CloudPortableStorageService {
  private s3?: AWS.S3;
  private config: StorageConfig;
  private localStoragePath: string;
  
  constructor(config: StorageConfig) {
    this.config = config;
    this.localStoragePath = config.localPath || './uploads';
    
    if (config.provider === 's3') {
      this.s3 = new AWS.S3({
        endpoint: config.endpoint,
        region: config.region || process.env.AWS_REGION || 'us-east-1',
        s3ForcePathStyle: true, // Required for LocalStack
        signatureVersion: 'v4',
      });
      
      // Create bucket if using LocalStack
      if (config.endpoint?.includes('localhost')) {
        this.ensureBucket().catch(console.error);
      }
    } else {
      // Ensure local directory exists
      this.ensureLocalDirectory();
    }
  }
  
  /**
   * Upload a file or buffer
   */
  async upload(
    key: string,
    data: Buffer | Readable | string,
    options: UploadOptions = {}
  ): Promise<string> {
    if (this.config.provider === 's3') {
      return this.uploadToS3(key, data, options);
    } else {
      return this.uploadToLocal(key, data, options);
    }
  }
  
  /**
   * Download a file
   */
  async download(key: string): Promise<Buffer> {
    if (this.config.provider === 's3') {
      return this.downloadFromS3(key);
    } else {
      return this.downloadFromLocal(key);
    }
  }
  
  /**
   * Get a readable stream for a file
   */
  async getStream(key: string): Promise<Readable> {
    if (this.config.provider === 's3') {
      return this.s3!.getObject({
        Bucket: this.config.bucket!,
        Key: key,
      }).createReadStream();
    } else {
      const filePath = this.getLocalPath(key);
      return fs.createReadStream(filePath);
    }
  }
  
  /**
   * Delete a file
   */
  async delete(key: string): Promise<void> {
    if (this.config.provider === 's3') {
      await this.s3!.deleteObject({
        Bucket: this.config.bucket!,
        Key: key,
      }).promise();
    } else {
      const filePath = this.getLocalPath(key);
      await fs.promises.unlink(filePath);
    }
  }
  
  /**
   * List files with optional prefix
   */
  async list(prefix?: string): Promise<StorageObject[]> {
    if (this.config.provider === 's3') {
      return this.listFromS3(prefix);
    } else {
      return this.listFromLocal(prefix);
    }
  }
  
  /**
   * Check if a file exists
   */
  async exists(key: string): Promise<boolean> {
    try {
      if (this.config.provider === 's3') {
        await this.s3!.headObject({
          Bucket: this.config.bucket!,
          Key: key,
        }).promise();
        return true;
      } else {
        const filePath = this.getLocalPath(key);
        await fs.promises.access(filePath);
        return true;
      }
    } catch (error) {
      return false;
    }
  }
  
  /**
   * Get a signed URL for temporary access
   */
  async getSignedUrl(key: string, expiresIn: number = 3600): Promise<string> {
    if (this.config.provider === 's3') {
      return this.s3!.getSignedUrlPromise('getObject', {
        Bucket: this.config.bucket!,
        Key: key,
        Expires: expiresIn,
      });
    } else {
      // For local storage, return a URL that your app can handle
      return `http://localhost:${process.env.PORT || 3000}/files/${key}`;
    }
  }
  
  /**
   * Copy a file
   */
  async copy(sourceKey: string, destinationKey: string): Promise<void> {
    if (this.config.provider === 's3') {
      await this.s3!.copyObject({
        Bucket: this.config.bucket!,
        CopySource: `${this.config.bucket}/${sourceKey}`,
        Key: destinationKey,
      }).promise();
    } else {
      const sourcePath = this.getLocalPath(sourceKey);
      const destPath = this.getLocalPath(destinationKey);
      await this.ensureLocalDirectory(path.dirname(destPath));
      await fs.promises.copyFile(sourcePath, destPath);
    }
  }
  
  // Private methods
  private async uploadToS3(
    key: string,
    data: Buffer | Readable | string,
    options: UploadOptions
  ): Promise<string> {
    const params: AWS.S3.PutObjectRequest = {
      Bucket: this.config.bucket!,
      Key: key,
      Body: data,
      ContentType: options.contentType,
      Metadata: options.metadata,
      ACL: options.public ? 'public-read' : 'private',
    };
    
    await this.s3!.putObject(params).promise();
    return `s3://${this.config.bucket}/${key}`;
  }
  
  private async uploadToLocal(
    key: string,
    data: Buffer | Readable | string,
    options: UploadOptions
  ): Promise<string> {
    const filePath = this.getLocalPath(key);
    await this.ensureLocalDirectory(path.dirname(filePath));
    
    if (Buffer.isBuffer(data) || typeof data === 'string') {
      await fs.promises.writeFile(filePath, data);
    } else {
      // Handle stream
      const writeStream = fs.createWriteStream(filePath);
      await new Promise((resolve, reject) => {
        data.pipe(writeStream)
          .on('finish', resolve)
          .on('error', reject);
      });
    }
    
    // Store metadata separately
    if (options.metadata || options.contentType) {
      const metadataPath = `${filePath}.meta`;
      await fs.promises.writeFile(
        metadataPath,
        JSON.stringify({
          contentType: options.contentType,
          metadata: options.metadata,
        })
      );
    }
    
    return `file://${filePath}`;
  }
  
  private async downloadFromS3(key: string): Promise<Buffer> {
    const result = await this.s3!.getObject({
      Bucket: this.config.bucket!,
      Key: key,
    }).promise();
    
    return result.Body as Buffer;
  }
  
  private async downloadFromLocal(key: string): Promise<Buffer> {
    const filePath = this.getLocalPath(key);
    return fs.promises.readFile(filePath);
  }
  
  private async listFromS3(prefix?: string): Promise<StorageObject[]> {
    const params: AWS.S3.ListObjectsV2Request = {
      Bucket: this.config.bucket!,
      Prefix: prefix,
    };
    
    const objects: StorageObject[] = [];
    let continuationToken: string | undefined;
    
    do {
      if (continuationToken) {
        params.ContinuationToken = continuationToken;
      }
      
      const result = await this.s3!.listObjectsV2(params).promise();
      
      if (result.Contents) {
        objects.push(...result.Contents.map((obj) => ({
          key: obj.Key!,
          size: obj.Size!,
          lastModified: obj.LastModified!,
          etag: obj.ETag,
        })));
      }
      
      continuationToken = result.NextContinuationToken;
    } while (continuationToken);
    
    return objects;
  }
  
  private async listFromLocal(prefix?: string): Promise<StorageObject[]> {
    const objects: StorageObject[] = [];
    
    const walkDir = async (dir: string, baseDir: string) => {
      const entries = await fs.promises.readdir(dir, { withFileTypes: true });
      
      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        const relativePath = path.relative(baseDir, fullPath);
        
        if (entry.isFile() && !entry.name.endsWith('.meta')) {
          if (!prefix || relativePath.startsWith(prefix)) {
            const stats = await fs.promises.stat(fullPath);
            const metadataPath = `${fullPath}.meta`;
            let contentType: string | undefined;
            
            try {
              const metadata = JSON.parse(
                await fs.promises.readFile(metadataPath, 'utf-8')
              );
              contentType = metadata.contentType;
            } catch (error) {
              // Metadata file doesn't exist
            }
            
            objects.push({
              key: relativePath,
              size: stats.size,
              lastModified: stats.mtime,
              contentType,
            });
          }
        } else if (entry.isDirectory()) {
          await walkDir(fullPath, baseDir);
        }
      }
    };
    
    await walkDir(this.localStoragePath, this.localStoragePath);
    return objects;
  }
  
  private async ensureBucket(): Promise<void> {
    try {
      await this.s3!.headBucket({ Bucket: this.config.bucket! }).promise();
    } catch (error: any) {
      if (error.statusCode === 404) {
        await this.s3!.createBucket({ Bucket: this.config.bucket! }).promise();
        console.log(`Created bucket: ${this.config.bucket}`);
      }
    }
  }
  
  private ensureLocalDirectory(dir?: string): void {
    const targetDir = dir || this.localStoragePath;
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
    }
  }
  
  private getLocalPath(key: string): string {
    // Ensure key doesn't escape the local storage directory
    const normalized = path.normalize(key).replace(/^\.\.\//, '');
    return path.join(this.localStoragePath, normalized);
  }
  
  /**
   * Generate a unique key for a file
   */
  static generateKey(prefix: string, extension: string): string {
    const timestamp = Date.now();
    const random = crypto.randomBytes(8).toString('hex');
    return `${prefix}/${timestamp}-${random}.${extension}`;
  }
}

// Example usage
export function createStorageService(): CloudPortableStorageService {
  const config: StorageConfig = {
    provider: process.env.STORAGE_PROVIDER as 'local' | 's3' || 'local',
    bucket: process.env.STORAGE_BUCKET || 'my-app-storage',
    endpoint: process.env.STORAGE_ENDPOINT,
    region: process.env.AWS_REGION,
    localPath: process.env.LOCAL_STORAGE_PATH || './uploads',
  };
  
  return new CloudPortableStorageService(config);
}
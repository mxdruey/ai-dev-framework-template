#!/bin/bash
# AI Development Framework - Cloud-Portable Project Setup
# This script creates projects that work seamlessly on local and AWS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Main setup function
setup_project() {
    print_header "AI Development Framework - Cloud-Portable Setup"
    
    # Get project information
    read -p "Project name (lowercase, no spaces): " project_name
    project_name=${project_name// /-}  # Replace spaces with hyphens
    project_name=${project_name,,}      # Convert to lowercase
    
    read -p "Project description: " project_description
    
    echo ""
    echo "Select project type:"
    echo "1) Simple Feature (1-2 weeks)"
    echo "2) Medium Project (2-8 weeks)"
    echo "3) Complex Application (2-6 months)"
    echo "4) AI Agent System"
    read -p "Enter choice (1-4): " project_type
    
    echo ""
    echo "Select deployment target:"
    echo "1) AWS (Lambda, ECS, EC2)"
    echo "2) Local only"
    echo "3) Both (recommended)"
    read -p "Enter choice (1-3): " deployment_target
    
    # Create project directory
    mkdir -p "$project_name"
    cd "$project_name"
    
    print_header "Creating Cloud-Portable Structure"
    
    # Create directory structure
    mkdir -p {src,tests,docs,config,scripts,infrastructure,deployment,.github/workflows}
    mkdir -p config/{local,dev,staging,production}
    mkdir -p infrastructure/{terraform,cloudformation,docker}
    mkdir -p deployment/{kubernetes,scripts}
    
    # Create .env.example for environment variables
    cat > .env.example << 'EOF'
# Application Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=info

# Database Configuration
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
REDIS_URL=redis://localhost:6379

# AWS Configuration (when deployed)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=your-account-id

# API Keys (use AWS Secrets Manager in production)
API_KEY=your-api-key
JWT_SECRET=your-jwt-secret

# Feature Flags
ENABLE_FEATURE_X=false
EOF
    
    # Create config management script
    cat > scripts/config-manager.sh << 'EOF'
#!/bin/bash
# Configuration manager for local and cloud environments

ENVIRONMENT=${1:-local}

case $ENVIRONMENT in
    local)
        cp config/local/.env .env
        echo "✓ Loaded local configuration"
        ;;
    dev|staging|production)
        # In AWS, these would come from Parameter Store or Secrets Manager
        aws ssm get-parameters-by-path \
            --path "/myapp/$ENVIRONMENT" \
            --recursive \
            --with-decryption \
            --query "Parameters[*].[Name,Value]" \
            --output text | \
        while IFS=$'\t' read -r name value; do
            key=$(echo "$name" | sed "s|/myapp/$ENVIRONMENT/||")
            echo "${key^^}=$value"
        done > .env
        echo "✓ Loaded $ENVIRONMENT configuration from AWS"
        ;;
esac
EOF
    chmod +x scripts/config-manager.sh
    
    # Create Dockerfile for cloud deployment
    cat > infrastructure/docker/Dockerfile << 'EOF'
# Multi-stage build for smaller images
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine

WORKDIR /app
RUN apk add --no-cache tini

COPY --from=builder /app/node_modules ./node_modules
COPY . .

EXPOSE 3000

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/index.js"]
EOF
    
    # Create docker-compose for local development
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: 
      context: .
      dockerfile: infrastructure/docker/Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    env_file:
      - .env
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-myapp}
      POSTGRES_USER: ${DB_USER:-user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  localstack:
    image: localstack/localstack
    ports:
      - "4566:4566"
    environment:
      - SERVICES=s3,sqs,dynamodb,secretsmanager
      - DEFAULT_REGION=us-east-1
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - localstack_data:/tmp/localstack

volumes:
  postgres_data:
  localstack_data:
EOF
    
    # Create AWS deployment configuration
    if [[ "$deployment_target" != "2" ]]; then
        print_info "Creating AWS deployment configurations..."
        
        # Terraform configuration
        cat > infrastructure/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configure your backend
    # bucket = "your-terraform-state-bucket"
    # key    = "projects/${var.project_name}/terraform.tfstate"
    # region = "us-east-1"
  }
}

variable "project_name" {
  default = "PROJECT_NAME_PLACEHOLDER"
}

variable "environment" {
  default = "dev"
}

# ECS Fargate setup for containerized apps
module "ecs_app" {
  source = "./modules/ecs-app"
  
  project_name = var.project_name
  environment  = var.environment
  # ... other configuration
}

# Lambda setup for serverless
module "lambda_functions" {
  source = "./modules/lambda"
  
  project_name = var.project_name
  environment  = var.environment
  # ... other configuration
}

# RDS for database
module "database" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  # ... other configuration
}
EOF
        
        # GitHub Actions for CI/CD
        cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to AWS

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: PROJECT_NAME_PLACEHOLDER

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Run linter
        run: npm run lint

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
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
      
      - name: Build, tag, and push image to Amazon ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -f infrastructure/docker/Dockerfile -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
      
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster production \
            --service ${ECR_REPOSITORY}-service \
            --force-new-deployment
EOF
        
        # Create deployment script
        cat > deployment/scripts/deploy-to-aws.sh << 'EOF'
#!/bin/bash
# Deploy to AWS

ENVIRONMENT=${1:-dev}
SERVICE_TYPE=${2:-ecs}  # ecs, lambda, or ec2

echo "Deploying to AWS $ENVIRONMENT as $SERVICE_TYPE..."

case $SERVICE_TYPE in
    ecs)
        echo "Building Docker image..."
        docker build -f infrastructure/docker/Dockerfile -t myapp:latest .
        
        echo "Pushing to ECR..."
        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
        docker tag myapp:latest $ECR_REGISTRY/myapp:latest
        docker push $ECR_REGISTRY/myapp:latest
        
        echo "Updating ECS service..."
        aws ecs update-service --cluster $ENVIRONMENT --service myapp --force-new-deployment
        ;;
    lambda)
        echo "Building Lambda package..."
        npm run build
        zip -r function.zip dist/ node_modules/
        
        echo "Updating Lambda function..."
        aws lambda update-function-code \
            --function-name myapp-$ENVIRONMENT \
            --zip-file fileb://function.zip
        ;;
    ec2)
        echo "Building application..."
        npm run build
        
        echo "Copying to EC2..."
        rsync -avz --exclude='node_modules' ./ ec2-user@$EC2_HOST:/app/
        
        echo "Restarting application..."
        ssh ec2-user@$EC2_HOST "cd /app && npm install && pm2 restart all"
        ;;
esac

echo "✓ Deployment complete!"
EOF
        chmod +x deployment/scripts/deploy-to-aws.sh
    fi
    
    # Update package.json with cloud-portable scripts
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "$project_description",
  "main": "dist/index.js",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "local:start": "docker-compose up",
    "local:stop": "docker-compose down",
    "cloud:deploy": "./deployment/scripts/deploy-to-aws.sh",
    "config:local": "./scripts/config-manager.sh local",
    "config:dev": "./scripts/config-manager.sh dev",
    "config:prod": "./scripts/config-manager.sh production"
  },
  "keywords": ["cloud-portable", "aws", "docker"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.0",
    "dotenv": "^16.0.0",
    "aws-sdk": "^2.1400.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "nodemon": "^3.0.0",
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
    
    # Create cloud-portable CLAUDE.md
    case $project_type in
        1) template="CLAUDE-simple.md" ;;
        2) template="CLAUDE-medium.md" ;;
        3) template="CLAUDE-complex.md" ;;
        4) template="CLAUDE-complex.md" ;;
    esac
    
    curl -s "https://raw.githubusercontent.com/mxdruey/ai-dev-framework-template/main/config/claude-config-templates/$template" > CLAUDE.md
    
    # Add cloud-specific instructions to CLAUDE.md
    cat >> CLAUDE.md << 'EOF'

## Cloud Portability Requirements

This project is designed to run both locally and on AWS. When implementing:

1. **Environment Variables**: Always use environment variables for configuration
2. **File Storage**: Use S3 for file storage, LocalStack locally
3. **Secrets**: Use AWS Secrets Manager (or .env locally)
4. **Database**: Use connection strings that work both locally and in cloud
5. **Logging**: Use structured logging that works with CloudWatch
6. **Health Checks**: Implement /health endpoint for load balancers

## Deployment Commands

- Local: `npm run local:start`
- Deploy to Dev: `npm run cloud:deploy dev`
- Deploy to Prod: `npm run cloud:deploy production`
EOF
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
*.log

# Environment
.env
.env.local
.env.*.local

# Build
dist/
build/
*.zip

# AWS
.aws/
*.pem

# Terraform
*.tfstate
*.tfstate.*
.terraform/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Testing
coverage/
.nyc_output/

# Temporary
tmp/
temp/
EOF
    
    # Initialize git
    git init
    git add .
    git commit -m "Initial project setup with cloud portability"
    
    print_success "Cloud-portable project created successfully!"
    
    print_info "Next steps:"
    echo "  1. cd $project_name"
    echo "  2. cp .env.example .env"
    echo "  3. npm install"
    echo "  4. npm run local:start"
    echo ""
    print_info "For AWS deployment:"
    echo "  1. Configure AWS credentials"
    echo "  2. Update infrastructure/terraform/main.tf"
    echo "  3. Run: npm run cloud:deploy dev"
}

# Run setup
setup_project
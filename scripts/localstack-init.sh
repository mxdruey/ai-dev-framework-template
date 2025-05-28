#!/bin/bash

# LocalStack initialization script
# This script sets up AWS services in LocalStack for local development

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Initializing LocalStack AWS services...${NC}"

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
until aws --endpoint-url=http://localhost:4566 s3 ls &> /dev/null
do
  sleep 1
done

echo -e "${GREEN}✓ LocalStack is ready${NC}"

# Create S3 buckets
echo "Creating S3 buckets..."
aws --endpoint-url=http://localhost:4566 s3 mb s3://local-uploads || true
aws --endpoint-url=http://localhost:4566 s3 mb s3://local-assets || true
aws --endpoint-url=http://localhost:4566 s3 mb s3://local-backups || true
echo -e "${GREEN}✓ S3 buckets created${NC}"

# Create DynamoDB tables
echo "Creating DynamoDB tables..."
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name sessions \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  2>/dev/null || echo "Table 'sessions' already exists"

aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name feature-flags \
  --attribute-definitions \
    AttributeName=flag_name,AttributeType=S \
  --key-schema \
    AttributeName=flag_name,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  2>/dev/null || echo "Table 'feature-flags' already exists"

echo -e "${GREEN}✓ DynamoDB tables created${NC}"

# Create SQS queues
echo "Creating SQS queues..."
aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name task-queue \
  2>/dev/null || echo "Queue 'task-queue' already exists"

aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name task-queue-dlq \
  2>/dev/null || echo "Queue 'task-queue-dlq' already exists"

aws --endpoint-url=http://localhost:4566 sqs create-queue \
  --queue-name notifications \
  2>/dev/null || echo "Queue 'notifications' already exists"

echo -e "${GREEN}✓ SQS queues created${NC}"

# Create SNS topics
echo "Creating SNS topics..."
aws --endpoint-url=http://localhost:4566 sns create-topic \
  --name alerts \
  2>/dev/null || echo "Topic 'alerts' already exists"

aws --endpoint-url=http://localhost:4566 sns create-topic \
  --name events \
  2>/dev/null || echo "Topic 'events' already exists"

echo -e "${GREEN}✓ SNS topics created${NC}"

# Create Secrets Manager secrets
echo "Creating Secrets Manager secrets..."
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name local/db-password \
  --secret-string '{"username":"dbuser","password":"localpass123","engine":"postgres","host":"postgres","port":5432,"dbname":"myapp"}' \
  2>/dev/null || echo "Secret 'local/db-password' already exists"

aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name local/jwt-secret \
  --secret-string 'local-development-jwt-secret-change-in-production' \
  2>/dev/null || echo "Secret 'local/jwt-secret' already exists"

aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name local/api-keys \
  --secret-string '{"stripe":"sk_test_local","sendgrid":"SG.local","twilio":"local"}' \
  2>/dev/null || echo "Secret 'local/api-keys' already exists"

echo -e "${GREEN}✓ Secrets created${NC}"

# Create Parameter Store parameters
echo "Creating Parameter Store parameters..."
aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/local/environment" \
  --value "local" \
  --type "String" \
  --overwrite \
  2>/dev/null

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/local/log_level" \
  --value "debug" \
  --type "String" \
  --overwrite \
  2>/dev/null

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/local/enable_metrics" \
  --value "true" \
  --type "String" \
  --overwrite \
  2>/dev/null

aws --endpoint-url=http://localhost:4566 ssm put-parameter \
  --name "/myapp/local/storage_bucket" \
  --value "local-uploads" \
  --type "String" \
  --overwrite \
  2>/dev/null

echo -e "${GREEN}✓ Parameters created${NC}"

# Create Lambda function (example)
echo "Creating Lambda functions..."
cat > /tmp/lambda_function.py << 'EOF'
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from LocalStack Lambda!'
    }
EOF

cd /tmp && zip lambda_function.zip lambda_function.py

aws --endpoint-url=http://localhost:4566 lambda create-function \
  --function-name test-function \
  --runtime python3.9 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  2>/dev/null || echo "Lambda function 'test-function' already exists"

rm -f /tmp/lambda_function.py /tmp/lambda_function.zip

echo -e "${GREEN}✓ Lambda functions created${NC}"

echo -e "\n${GREEN}✅ LocalStack initialization complete!${NC}"
echo -e "${BLUE}You can now use AWS services locally at http://localhost:4566${NC}"
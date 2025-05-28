# AI Development Framework

> 🚀 A comprehensive framework for building AI-assisted applications with seamless planning and implementation phases, now with **cloud portability** built-in.

## 🌟 What's New: Cloud Portability

The framework now includes full cloud portability, allowing your projects to run seamlessly:
- **Locally**: Using Docker Compose with LocalStack for AWS services
- **AWS**: Using ECS, Lambda, or EC2 with managed services
- **Other Clouds**: Adaptable patterns for Azure, GCP, etc.

### Quick Start with Cloud-Portable Setup

```bash
# Clone the framework
git clone https://github.com/mxdruey/ai-dev-framework-template.git
cd ai-dev-framework-template

# Run the cloud-portable setup
./scripts/setup-cloud-portable.sh
```

This will:
- ✅ Create a project structure that works locally and in AWS
- ✅ Set up Docker Compose with LocalStack for local AWS services
- ✅ Configure GitHub Actions for automated deployment
- ✅ Create Terraform/CloudFormation templates
- ✅ Implement service abstractions (storage, database, cache)

## 🎯 Framework Philosophy

This framework bridges the gap between AI planning capabilities and practical implementation:

1. **Planning Phase** (Claude Desktop - Opus 4): Deep reasoning and comprehensive project design
2. **Implementation Phase** (Claude Code - Sonnet 4): Efficient code generation following the plan
3. **Cloud Deployment**: Seamless deployment to AWS or run locally with identical behavior

## 🏗️ Project Structure

```
my-project/
├── docs/                    # Planning documents
│   ├── prd-*.md            # Product Requirements
│   ├── architecture-*.md   # Technical Architecture
│   └── tasks-*.md          # Implementation Tasks
├── infrastructure/         # Cloud infrastructure (NEW)
│   ├── docker/            # Dockerfiles
│   ├── terraform/         # AWS infrastructure as code
│   └── cloudformation/    # Alternative to Terraform
├── deployment/            # Deployment configurations (NEW)
│   ├── scripts/          # Deploy scripts
│   └── kubernetes/       # K8s manifests
├── config/               # Environment configurations
│   ├── local/           # Local development
│   ├── dev/             # AWS dev environment
│   ├── staging/         # AWS staging
│   └── production/      # AWS production
├── src/                    # Application code
├── tests/                  # Test suites
├── scripts/               # Utility scripts
├── docker-compose.yml     # Local development stack
├── .env.example          # Environment template
└── CLAUDE.md             # AI assistant instructions
```

## 🚀 Getting Started

### Prerequisites

- Node.js 16+ or Python 3.8+ (depending on project type)
- Docker and Docker Compose
- AWS CLI (for cloud deployment)
- Claude Desktop (for planning)
- Claude Code (for implementation)

### 1. Create a New Cloud-Portable Project

```bash
# Use the cloud-portable setup script
./scripts/setup-cloud-portable.sh

# Follow the prompts:
# - Project name
# - Project type (simple/medium/complex/AI agent)
# - Deployment target (AWS/local/both)
```

### 2. Planning Phase with Claude Desktop

Open Claude Desktop and start planning:

```
"I'm using the AI Development Framework from https://github.com/mxdruey/ai-dev-framework-template

I need to build a [describe your project]. 

Please help me create:
1. A comprehensive PRD
2. Technical architecture 
3. Task breakdown for implementation"
```

### 3. Local Development

```bash
# Start all services locally
docker-compose up

# Your app is now running with:
# - PostgreSQL database
# - Redis cache
# - LocalStack (AWS services)
# - Your application

# Access your app
open http://localhost:3000

# Access LocalStack AWS services
aws --endpoint-url=http://localhost:4566 s3 ls
```

### 4. Implementation with Claude Code

```bash
# After planning is complete
./scripts/claude-handoff.sh

# Start implementation
claude "Read all planning documents in docs/ and begin implementation following the task sequence."
```

### 5. Deploy to AWS

```bash
# Configure AWS credentials
aws configure

# Deploy to development
npm run cloud:deploy dev

# Deploy to production
npm run cloud:deploy production
```

## 🌩️ Cloud Portability Features

### Service Abstractions

```typescript
// Storage works locally and in S3
const storage = new CloudPortableStorageService({
  provider: process.env.STORAGE_PROVIDER, // 'local' or 's3'
  bucket: process.env.STORAGE_BUCKET
});

await storage.upload('file.pdf', buffer);
await storage.download('file.pdf');
```

### Configuration Management

```typescript
// Automatically loads from .env locally or AWS Parameter Store in cloud
const config = await getConfig();

// Same code works everywhere
const db = new Database({
  host: config.database.host,
  port: config.database.port
});
```

### Local AWS Services

LocalStack provides local versions of:
- S3 (file storage)
- DynamoDB (NoSQL database)
- SQS (message queues)
- Lambda (serverless functions)
- Secrets Manager
- Parameter Store

## 📊 Framework Components

### Planning Templates
- **PRD Template**: Comprehensive requirements documentation
- **Architecture Template**: System design and technical decisions
- **Task Template**: Detailed implementation roadmap
- **AI Agent Template**: Specialized for AI/ML systems

### Configuration Templates
- **CLAUDE-simple.md**: For small features (1-2 weeks)
- **CLAUDE-medium.md**: For medium projects (2-8 weeks)
- **CLAUDE-complex.md**: For large applications (2-6 months)
- **Cloud deployment configs**: AWS-ready from day one

### Utility Scripts
- `setup-project.sh`: Original project setup
- `setup-cloud-portable.sh`: Cloud-portable project setup
- `validate-framework.sh`: Verify project structure
- `quality-check.sh`: Pre-commit quality checks
- `claude-handoff.sh`: Transition from planning to implementation
- `update-framework.sh`: Update existing projects
- `localstack-init.sh`: Initialize local AWS services

## 🔄 Workflow Example

### Complete E-Commerce Feature Flow

1. **Planning (Claude Desktop)**:
   ```
   "I need to add a wishlist feature to our e-commerce platform that works 
   locally and deploys to AWS Lambda"
   ```
   
   Claude helps create:
   - PRD with user stories
   - Serverless architecture design
   - Database schema (DynamoDB)
   - API specifications
   - 15 implementation tasks

2. **Local Development**:
   ```bash
   docker-compose up
   # Develops with local DynamoDB via LocalStack
   ```

3. **Implementation (Claude Code)**:
   ```bash
   claude "Implement task 1.1: Create DynamoDB tables for wishlist with user_id as partition key"
   ```

4. **Testing**:
   ```bash
   npm test  # Unit tests
   npm run test:integration  # Tests against LocalStack
   ```

5. **Deployment**:
   ```bash
   npm run cloud:deploy dev
   # Deploys to AWS Lambda with real DynamoDB
   ```

## 🏆 Best Practices

### Cloud Portability
1. **Always use environment variables** for configuration
2. **Abstract external services** (storage, queue, cache)
3. **Use the same Docker image** locally and in production
4. **Test with LocalStack** before deploying to AWS
5. **Keep infrastructure as code** in the repository

### Planning Phase
1. **Be specific** about requirements and constraints
2. **Include cloud deployment** needs in planning
3. **Consider cost optimization** from the start
4. **Plan for monitoring** and observability

### Implementation Phase
1. **Follow the task sequence** from planning
2. **Write tests first** when possible
3. **Use service abstractions** for external dependencies
4. **Implement health checks** for cloud deployment

## 📚 Documentation

- [Framework Guide](docs/guides/framework-guide.md) - Detailed workflow instructions
- [Cloud Deployment Guide](docs/guides/cloud-deployment-guide.md) - AWS deployment details
- [Best Practices](docs/guides/best-practices.md) - Tips and recommendations
- [Troubleshooting](docs/guides/troubleshooting.md) - Common issues and solutions
- [Cloud Portability Checklist](docs/guides/cloud-portability-checklist.md) - Ensure full portability

## 🎉 Success Stories

### Projects Built with This Framework

1. **Task Management SaaS** (Medium Complexity)
   - Planning: 4 hours
   - Implementation: 2 weeks
   - Deployment: AWS ECS Fargate
   - Result: 95% test coverage, zero-downtime deployments

2. **AI Customer Service Bot** (Complex)
   - Planning: 2 days
   - Implementation: 6 weeks
   - Deployment: AWS Lambda + API Gateway
   - Result: Handles 10K+ conversations daily

3. **Real-time Analytics Dashboard** (Medium Complexity)
   - Planning: 3 hours
   - Implementation: 10 days
   - Deployment: AWS ECS + ElastiCache
   - Result: Sub-100ms response times

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Areas for Contribution
- Additional cloud provider support (Azure, GCP)
- More project type templates
- Language-specific implementations
- CI/CD pipeline variants
- Monitoring and observability templates

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Anthropic's Claude team for amazing AI assistants
- The open-source community for inspiration
- LocalStack for making cloud development local
- All contributors and users of this framework

---

**Ready to build something amazing? Start with the cloud-portable setup and go from idea to production in record time!** 🚀
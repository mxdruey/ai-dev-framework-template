# Cloud Portability Checklist

Use this checklist to ensure your project is fully cloud-portable between local development and AWS deployment.

## ✅ Project Setup

- [ ] Used `setup-cloud-portable.sh` script to initialize project
- [ ] Project has both local and cloud deployment configurations
- [ ] `.env.example` file documents all required environment variables
- [ ] Docker Compose configured for local development
- [ ] AWS infrastructure defined in Terraform/CloudFormation

## ✅ Configuration Management

- [ ] All configuration uses environment variables
- [ ] No hardcoded URLs, credentials, or environment-specific values
- [ ] Configuration validation implemented
- [ ] AWS Parameter Store integration for cloud config
- [ ] Secrets Manager integration for sensitive data
- [ ] Local `.env` file for development (git-ignored)

## ✅ Service Abstractions

### Database
- [ ] Connection string from environment variables
- [ ] Works with local Docker Postgres
- [ ] Works with AWS RDS
- [ ] Connection pooling configured
- [ ] SSL enabled for production

### Cache
- [ ] Redis connection from environment variables
- [ ] Works with local Docker Redis
- [ ] Works with AWS ElastiCache
- [ ] Auth token support for production

### Storage
- [ ] Storage service abstraction implemented
- [ ] Works with local file system
- [ ] Works with S3
- [ ] LocalStack S3 for local development
- [ ] Proper error handling for both providers

### Message Queue (if applicable)
- [ ] Queue service abstraction
- [ ] Works with local queue (Redis/LocalStack SQS)
- [ ] Works with AWS SQS
- [ ] Dead letter queue configured

## ✅ Application Code

- [ ] Health check endpoint implemented
- [ ] Structured logging (CloudWatch compatible)
- [ ] Graceful shutdown handling
- [ ] Environment-aware error handling
- [ ] No use of local file system for persistent data
- [ ] Proper async/await error handling

## ✅ Docker & Containers

- [ ] Multi-stage Dockerfile for small images
- [ ] Non-root user in container
- [ ] Health check defined in Dockerfile
- [ ] `.dockerignore` configured
- [ ] Same image works locally and in AWS

## ✅ Local Development

- [ ] `docker-compose.yml` includes all dependencies
- [ ] LocalStack configured for AWS services
- [ ] Hot reload working in containers
- [ ] Local volumes for development
- [ ] Seeds/fixtures for local database

## ✅ CI/CD Pipeline

- [ ] GitHub Actions workflow configured
- [ ] Automated testing in pipeline
- [ ] Security scanning (Trivy, OWASP)
- [ ] Build and push to ECR
- [ ] Automated deployment to dev/staging
- [ ] Manual approval for production

## ✅ AWS Infrastructure

- [ ] VPC and networking configured
- [ ] Security groups properly scoped
- [ ] IAM roles follow least privilege
- [ ] Secrets Manager for sensitive data
- [ ] Parameter Store for configuration
- [ ] CloudWatch logs configured
- [ ] Backup strategy implemented

## ✅ Monitoring & Observability

- [ ] Application metrics exported
- [ ] CloudWatch dashboards created
- [ ] Alerts configured for key metrics
- [ ] Log aggregation working
- [ ] Distributed tracing (if applicable)
- [ ] Error tracking implemented

## ✅ Security

- [ ] No secrets in code or git
- [ ] HTTPS/TLS configured
- [ ] Security headers implemented
- [ ] Rate limiting configured
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] XSS prevention measures

## ✅ Testing

- [ ] Unit tests pass locally and in CI
- [ ] Integration tests with test containers
- [ ] E2E tests against local stack
- [ ] Performance tests documented
- [ ] Security tests automated

## ✅ Documentation

- [ ] README includes local setup instructions
- [ ] README includes deployment instructions
- [ ] Architecture diagram created
- [ ] API documentation generated
- [ ] Runbook for common operations
- [ ] Troubleshooting guide written

## ✅ Cost Optimization

- [ ] Auto-scaling configured
- [ ] Unused resources cleaned up
- [ ] S3 lifecycle policies set
- [ ] CloudWatch log retention configured
- [ ] Development environments auto-shutdown
- [ ] Cost alerts configured

## ✅ Disaster Recovery

- [ ] Database backups automated
- [ ] S3 versioning enabled
- [ ] Infrastructure as Code in git
- [ ] Runbook for recovery procedures
- [ ] RTO/RPO defined and tested
- [ ] Multi-region setup (if required)

## 🎯 Quick Validation

Run these commands to validate portability:

```bash
# Local development
docker-compose up
curl http://localhost:3000/health

# Build for production
docker build -t myapp .

# Test configuration loading
NODE_ENV=production node -e "require('./dist/config').getConfig().then(console.log)"

# Validate AWS credentials
aws sts get-caller-identity

# Dry run deployment
terraform plan
```

## 📋 Pre-Deployment Checklist

Before deploying to AWS:

1. [ ] All tests passing
2. [ ] Security scan clean
3. [ ] Documentation updated
4. [ ] Terraform plan reviewed
5. [ ] Rollback plan documented
6. [ ] Monitoring alerts configured
7. [ ] Team notified of deployment

---

**Remember: If it works locally, it should work in the cloud with just configuration changes!**
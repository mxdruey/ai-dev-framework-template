# Troubleshooting Guide

This guide helps you diagnose and resolve common issues when using the AI Development Framework.

## Planning Phase Issues

### Problem: Requirements Are Too Vague

**Symptoms:**
- PRD contains unclear or ambiguous statements
- Acceptance criteria are hard to verify
- Team members interpret requirements differently

**Diagnosis:**
```markdown
❌ Problematic requirement:
"Users should be able to manage their data efficiently"

✅ Clear requirement:
"Users should be able to create, read, update, and delete their profile information within 2 seconds per operation, with confirmation messages for each action"
```

**Solutions:**
1. Use the "5 Whys" technique:
   - Why do users need to manage data?
   - Why does it need to be efficient?
   - Why is 2 seconds the target?
   - Continue until you reach specific, actionable requirements

2. Apply the SMART criteria:
   - **Specific**: Exactly what needs to be done
   - **Measurable**: How you'll know it's complete
   - **Achievable**: Realistic within constraints
   - **Relevant**: Aligns with business goals
   - **Time-bound**: Clear timeline

3. Create concrete examples:
   ```markdown
   Example user story:
   As a registered user
   I want to update my email address
   So that I receive notifications at my current email
   
   Acceptance criteria:
   - Email field is validated for proper format
   - Confirmation email sent to both old and new addresses
   - Change is reflected immediately in user profile
   - Operation completes within 2 seconds
   ```

### Problem: Architecture Seems Over-Complicated

**Symptoms:**
- Architecture diagram has too many components
- Technology choices seem excessive for the problem size
- Implementation timeline is much longer than expected

**Diagnosis:**
Check if you're solving tomorrow's problems today:
```markdown
❌ Over-engineered:
- Microservices for a single-team project
- Message queues for synchronous operations
- Multiple databases for simple data

✅ Right-sized:
- Monolithic architecture with clear boundaries
- Direct API calls for immediate responses
- Single database with proper normalization
```

**Solutions:**
1. Apply the YAGNI principle (You Aren't Gonna Need It)
2. Start with the simplest architecture that meets current requirements
3. Plan evolution points where complexity can be added later
4. Document assumptions about future growth

### Problem: Task Dependencies Are Circular

**Symptoms:**
- Task A depends on Task B, which depends on Task A
- Cannot determine starting point for implementation
- Deadlocks in development planning

**Diagnosis:**
```mermaid
# Circular dependency example
Task A --> Task B
Task B --> Task C  
Task C --> Task A
```

**Solutions:**
1. **Identify the Interface**: Create interfaces/contracts first
   ```typescript
   // Step 1: Define interfaces
   interface UserService {
     createUser(data: UserData): Promise<User>;
   }
   
   interface NotificationService {
     sendWelcomeEmail(user: User): Promise<void>;
   }
   
   // Step 2: Implement with dependency injection
   class UserServiceImpl implements UserService {
     constructor(private notificationService: NotificationService) {}
   }
   ```

2. **Break into phases**:
   - Phase 1: Core functionality without dependencies
   - Phase 2: Add integrations and dependent features

3. **Use mocking/stubbing**:
   ```typescript
   // Temporary stub while developing
   class MockNotificationService implements NotificationService {
     async sendWelcomeEmail(user: User): Promise<void> {
       console.log(`Would send welcome email to ${user.email}`);
     }
   }
   ```

## Implementation Phase Issues

### Problem: Claude Code Doesn't Understand Context

**Symptoms:**
- Claude generates code unrelated to your project
- Ignores project conventions or architecture
- Asks for clarification on things documented in project

**Diagnosis:**
Check your CLAUDE.md file:
```markdown
❌ Insufficient context:
# My Project
This is a web app.

✅ Rich context:
# Claude Code Configuration: E-commerce Platform

## Project Overview
This is a Node.js/TypeScript e-commerce platform using:
- Express.js for API
- PostgreSQL for data persistence
- Redis for caching
- JWT for authentication

## Architecture
[Include architecture details]

## Coding Standards
[Include specific standards]
```

**Solutions:**
1. **Enhance CLAUDE.md**:
   - Add project overview and goals
   - Include architecture decisions
   - Specify coding standards and patterns
   - Document key file locations

2. **Reference documentation in prompts**:
   ```bash
   claude "Read /docs/prd-auth.md and implement user authentication following the security requirements in CLAUDE.md"
   ```

3. **Provide examples**:
   ```markdown
   ## Code Examples
   
   ### API Endpoint Pattern
   ```typescript
   app.post('/api/users', authenticateToken, async (req, res, next) => {
     try {
       const validatedData = validateCreateUser(req.body);
       const user = await userService.createUser(validatedData);
       res.status(201).json({ success: true, data: user });
     } catch (error) {
       next(error);
     }
   });
   ```
   ```

### Problem: Implementation Deviates from Plan

**Symptoms:**
- Actual implementation doesn't match PRD requirements
- Architecture decisions made during coding conflict with design
- Features work differently than specified

**Diagnosis:**
This often happens due to:
- Discovered technical constraints
- Unclear requirements interpretation
- Better solutions found during implementation

**Solutions:**
1. **Update documentation first**:
   ```bash
   # Don't force implementation to match outdated docs
   # Instead, update docs to reflect better understanding
   claude "Update the PRD and architecture documents to reflect the improved approach we discovered during implementation"
   ```

2. **Document decisions**:
   ```markdown
   ## Implementation Notes
   
   ### Change: Authentication Flow
   **Original Plan**: Cookie-based sessions
   **Actual Implementation**: JWT tokens
   **Reason**: Better support for mobile clients and API integrations
   **Impact**: Updated security model and API documentation
   ```

3. **Validate with stakeholders**:
   - Communicate changes and rationale
   - Ensure business requirements are still met
   - Update acceptance criteria if needed

### Problem: Quality Gates Keep Failing

**Symptoms:**
- Tests consistently fail
- Code coverage below targets
- Performance benchmarks not met
- Security scans show vulnerabilities

**Diagnosis by Category:**

**Test Failures:**
```bash
# Check test quality
❌ Testing implementation details
❌ Tests coupled to specific implementations
❌ Missing edge case coverage

# Focus on behavior
✅ Test what the code should do, not how
✅ Test user workflows and business logic
✅ Include error conditions and edge cases
```

**Performance Issues:**
```typescript
// Common performance problems
❌ N+1 database queries
❌ No caching of expensive operations  
❌ Large payload responses
❌ Synchronous operations blocking event loop

// Solutions
✅ Use proper JOINs or eager loading
✅ Cache frequently accessed data
✅ Implement pagination
✅ Use async/await properly
```

**Solutions:**
1. **Review quality standards**:
   - Are they realistic for the project type?
   - Do they align with business requirements?
   - Should they be adjusted based on new information?

2. **Implement incrementally**:
   ```bash
   # Don't try to meet all quality gates at once
   claude "Implement basic functionality first, then incrementally improve test coverage and performance"
   ```

3. **Use appropriate tools**:
   ```bash
   # Automated quality checks
   npm run lint          # Code style
   npm run test:coverage # Test coverage
   npm run security:scan # Security vulnerabilities
   npm run perf:test     # Performance benchmarks
   ```

## Claude Code Specific Issues

### Problem: Claude Code Generates Inconsistent Results

**Symptoms:**
- Different coding styles across files
- Inconsistent error handling patterns
- Variable naming conventions

**Solutions:**
1. **Establish clear patterns in CLAUDE.md**:
   ```markdown
   ## Coding Patterns
   
   ### Error Handling
   ```typescript
   // Always use this pattern
   try {
     const result = await operation();
     return { success: true, data: result };
   } catch (error) {
     logger.error('Operation failed', { error: error.message });
     throw new ServiceError('Operation failed', error);
   }
   ```
   ```

2. **Reference patterns in prompts**:
   ```bash
   claude "Implement user service following the error handling and logging patterns defined in CLAUDE.md"
   ```

### Problem: Claude Code Makes Assumptions

**Symptoms:**
- Implements features not in requirements
- Uses technologies not specified
- Makes architectural decisions without consultation

**Solutions:**
1. **Be explicit about constraints**:
   ```bash
   claude "Implement ONLY the features specified in the PRD. Do not add additional functionality. Use only the technologies listed in the architecture document."
   ```

2. **Use confirmation prompts**:
   ```bash
   claude "Before implementing, confirm your understanding of the requirements and list what you plan to build"
   ```

### Problem: Claude Code Skips Testing

**Symptoms:**
- Implementation provided without tests
- Tests are superficial or incomplete
- No consideration of edge cases

**Solutions:**
1. **Make testing explicit**:
   ```bash
   claude "Implement user authentication with comprehensive test coverage including unit tests, integration tests, and edge cases. Aim for >90% code coverage."
   ```

2. **Use TDD approach**:
   ```bash
   claude "Use test-driven development: write failing tests first, then implement the code to make them pass"
   ```

## AI-Specific Issues

### Problem: AI Agent Outputs Are Unreliable

**Symptoms:**
- Inconsistent responses to similar inputs
- Agent contradicts itself between interactions
- Outputs don't follow expected patterns

**Diagnosis:**
```typescript
// Check system prompt consistency
❌ Vague system prompt:
"You are a helpful assistant"

✅ Specific system prompt:
"You are a customer service agent for TechCorp. 
Always be professional and helpful.
Refer to our knowledge base for technical questions.
Escalate billing issues to human agents.
Format responses using the provided templates."
```

**Solutions:**
1. **Improve system prompts**:
   - Be specific about role and context
   - Provide clear guidelines and constraints
   - Include examples of expected behavior

2. **Add output validation**:
   ```typescript
   function validateAgentResponse(response: string): boolean {
     // Check format, length, content appropriateness
     return response.length > 10 && 
            response.length < 1000 &&
            !containsInappropriateContent(response);
   }
   ```

3. **Implement consistency checks**:
   ```typescript
   class AgentMemory {
     checkConsistency(newResponse: string, context: Context): boolean {
       const previousResponses = this.getRecentResponses(context);
       return !this.detectContradictions(newResponse, previousResponses);
     }
   }
   ```

### Problem: AI Safety Measures Block Legitimate Actions

**Symptoms:**
- Valid requests get filtered out
- Overly restrictive content filtering
- Legitimate actions require manual approval

**Solutions:**
1. **Tune safety thresholds**:
   ```typescript
   const safetyConfig = {
     contentFilter: {
       strictness: 'medium', // vs 'high'
       allowList: ['technical-terms', 'business-jargon'],
       contextAware: true
     }
   };
   ```

2. **Implement contextual safety**:
   ```typescript
   function assessSafety(action: Action, context: Context): SafetyLevel {
     if (context.userRole === 'admin' && action.type === 'system-config') {
       return SafetyLevel.MEDIUM; // Less restrictive for admins
     }
     return assessGeneralSafety(action);
   }
   ```

3. **Add appeal process**:
   ```typescript
   class SafetyAppeal {
     async requestReview(blockedAction: Action, reason: string) {
       // Human review process for borderline cases
     }
   }
   ```

## Performance Issues

### Problem: API Response Times Too Slow

**Diagnosis Tools:**
```bash
# Profile API endpoints
curl -w "@curl-format.txt" -o /dev/null -s "http://localhost:3000/api/users"

# Database query analysis
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

# Application profiling
node --prof app.js
node --prof-process isolate-*.log > processed.txt
```

**Common Issues & Solutions:**

1. **Database Problems**:
   ```sql
   -- ❌ Missing indexes
   SELECT * FROM users WHERE email = 'user@example.com';
   
   -- ✅ Add appropriate indexes
   CREATE INDEX idx_users_email ON users(email);
   ```

2. **N+1 Query Problems**:
   ```typescript
   // ❌ N+1 queries
   const users = await User.findAll();
   for (const user of users) {
     user.profile = await Profile.findByUserId(user.id);
   }
   
   // ✅ Eager loading
   const users = await User.findAll({
     include: [Profile]
   });
   ```

3. **Missing Caching**:
   ```typescript
   // ❌ No caching
   async function getPopularPosts() {
     return await Post.findAll({
       where: { popular: true },
       order: [['views', 'DESC']]
     });
   }
   
   // ✅ With caching
   async function getPopularPosts() {
     const cached = await redis.get('popular-posts');
     if (cached) return JSON.parse(cached);
     
     const posts = await Post.findAll({
       where: { popular: true },
       order: [['views', 'DESC']]
     });
     
     await redis.setex('popular-posts', 300, JSON.stringify(posts));
     return posts;
   }
   ```

### Problem: Memory Usage Too High

**Diagnosis:**
```bash
# Monitor memory usage
node --inspect app.js
# Use Chrome DevTools to profile memory

# Check for memory leaks
node --trace-gc app.js
```

**Common Solutions:**
1. **Stream large data**:
   ```typescript
   // ❌ Loading all data into memory
   const allUsers = await User.findAll();
   const csv = convertToCsv(allUsers);
   
   // ✅ Streaming
   const userStream = User.findAll({ stream: true });
   const csvStream = new CsvTransform();
   userStream.pipe(csvStream).pipe(response);
   ```

2. **Implement pagination**:
   ```typescript
   // ❌ Return all results
   async function getUsers() {
     return await User.findAll();
   }
   
   // ✅ Paginated results
   async function getUsers(page = 1, limit = 20) {
     const offset = (page - 1) * limit;
     return await User.findAndCountAll({ limit, offset });
   }
   ```

## Deployment Issues

### Problem: Environment Configuration Errors

**Symptoms:**
- Application fails to start in production
- Different behavior between environments
- Configuration not found errors

**Solutions:**
1. **Validate environment configuration**:
   ```typescript
   import { z } from 'zod';
   
   const envSchema = z.object({
     NODE_ENV: z.enum(['development', 'staging', 'production']),
     DATABASE_URL: z.string().url(),
     JWT_SECRET: z.string().min(32),
     PORT: z.string().transform(Number).default('3000')
   });
   
   try {
     const env = envSchema.parse(process.env);
   } catch (error) {
     console.error('Environment validation failed:', error);
     process.exit(1);
   }
   ```

2. **Use environment-specific configs**:
   ```typescript
   // config/index.ts
   const configs = {
     development: require('./development'),
     staging: require('./staging'),
     production: require('./production')
   };
   
   export default configs[process.env.NODE_ENV || 'development'];
   ```

### Problem: Database Migration Failures

**Symptoms:**
- Deployment fails during database migration
- Data loss or corruption
- Schema inconsistencies

**Solutions:**
1. **Test migrations in staging**:
   ```bash
   # Always test migrations with production-like data
   npm run db:migrate:staging
   npm run test:migration
   ```

2. **Implement rollback procedures**:
   ```sql
   -- Every migration should have a rollback
   -- migration-001-up.sql
   ALTER TABLE users ADD COLUMN phone VARCHAR(20);
   
   -- migration-001-down.sql
   ALTER TABLE users DROP COLUMN phone;
   ```

3. **Use transaction-based migrations**:
   ```sql
   BEGIN;
   
   -- Migration steps
   ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
   UPDATE users SET email_verified = TRUE WHERE created_at < '2024-01-01';
   
   -- Verify migration
   DO $$
   BEGIN
     IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'email_verified') THEN
       RAISE EXCEPTION 'Migration failed: email_verified column not created';
     END IF;
   END $$;
   
   COMMIT;
   ```

## Getting Help

### When to Seek Additional Support

1. **Technical Issues**:
   - Performance problems persist after optimization
   - Security vulnerabilities cannot be resolved
   - Integration issues with external services

2. **Process Issues**:
   - Team cannot agree on requirements
   - Stakeholders frequently change requirements
   - Timeline consistently underestimated

3. **Quality Issues**:
   - Unable to meet quality standards consistently
   - Testing strategy ineffective
   - Code reviews taking too long

### Resources for Help

1. **Documentation**:
   - Framework guides and examples
   - Technology-specific documentation
   - Best practices guides

2. **Community**:
   - Stack Overflow for technical questions
   - GitHub discussions for framework issues
   - Team knowledge sharing sessions

3. **Professional Support**:
   - Code review services
   - Architecture consultation
   - Performance optimization experts

---

**Remember: Most problems have been encountered before. Document your solutions to help future projects and team members.**
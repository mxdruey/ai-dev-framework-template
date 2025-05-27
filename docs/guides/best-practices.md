# AI Development Framework Best Practices

This guide consolidates best practices learned from using the AI Development Framework across different project types and team sizes.

## Planning Phase Best Practices

### Requirements Gathering

#### Be Ruthlessly Specific
```markdown
❌ "Users should be able to manage their tasks"
✅ "Users should be able to create, edit, delete, and mark tasks as complete. Each task must have a title (required), description (optional), due date (optional), and priority level (Low/Medium/High)."
```

#### Think in User Stories
```markdown
# Good User Story Format
As a [specific user type]
I want to [specific action]
So that [specific benefit/outcome]

# Example
As a project manager
I want to assign tasks to team members with due dates
So that I can track project progress and ensure deadlines are met
```

#### Define Acceptance Criteria Early
```markdown
# For each user story, define:
- What constitutes "done"
- Edge cases and error conditions
- Performance requirements
- Security considerations
- Accessibility requirements
```

#### Question Everything
When gathering requirements, ask:
- What happens when this fails?
- How will this scale?
- Who else might use this feature?
- What data do we need to store?
- How will we know this is successful?

### Architecture Planning

#### Start Simple, Plan for Growth
```typescript
// ❌ Over-engineered from the start
class UserServiceFactoryBean implements IUserServiceFactory {
  createUserService(): IUserService {
    return new UserServiceImpl(
      new UserRepositoryImpl(
        new DatabaseConnectionPoolManager()
      )
    );
  }
}

// ✅ Simple but extensible
class UserService {
  constructor(private userRepository: UserRepository) {}
  
  async createUser(userData: CreateUserData): Promise<User> {
    // Implementation that can be easily extended
  }
}
```

#### Document Architectural Decisions
```markdown
# Architecture Decision Record (ADR) Template

## Decision: [Short title]

### Status
[Proposed/Accepted/Rejected/Superseded]

### Context
[What is the issue that we're seeing that is motivating this decision?]

### Decision
[What is the change that we're proposing or have agreed to implement?]

### Consequences
[What becomes easier or more difficult to do and any risks introduced?]
```

#### Consider Non-Functional Requirements Early
- **Performance**: Response times, throughput, scalability
- **Security**: Authentication, authorization, data protection
- **Reliability**: Uptime, error handling, disaster recovery
- **Maintainability**: Code quality, documentation, team knowledge
- **Compliance**: Legal, regulatory, industry standards

## Implementation Best Practices

### Code Quality

#### Follow the Boy Scout Rule
"Always leave the code cleaner than you found it."

#### Write Self-Documenting Code
```typescript
// ❌ Unclear code requiring comments
function calc(x: number, y: number): number {
  // Calculate compound interest
  return x * Math.pow(1 + 0.05, y);
}

// ✅ Self-documenting code
function calculateCompoundInterest(
  principal: number,
  years: number,
  interestRate: number = 0.05
): number {
  return principal * Math.pow(1 + interestRate, years);
}
```

#### Use TypeScript Effectively
```typescript
// ❌ Weak typing
function updateUser(id: any, data: any): Promise<any> {
  // Implementation
}

// ✅ Strong typing
type UpdateUserData = {
  name?: string;
  email?: string;
  preferences?: UserPreferences;
};

function updateUser(
  id: UserId,
  data: UpdateUserData
): Promise<User> {
  // Implementation
}
```

#### Handle Errors Properly
```typescript
// ❌ Poor error handling
async function fetchUser(id: string) {
  try {
    const user = await userRepository.findById(id);
    return user;
  } catch (error) {
    console.log(error);
    throw error;
  }
}

// ✅ Proper error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new UserNotFoundError(`User with ID ${id} not found`);
    }
    return user;
  } catch (error) {
    logger.error('Failed to fetch user', {
      userId: id,
      error: error.message,
      stack: error.stack
    });
    
    if (error instanceof UserNotFoundError) {
      throw error;
    }
    
    throw new ServiceError('User fetch failed', error);
  }
}
```

### Testing Strategies

#### Follow the Test Pyramid
```
     /\
    /e2e\
   /______\
  /        \
 /integration\
/____________\
/            \
/    unit     \
/______________\
```

- **Unit Tests (70%)**: Fast, isolated, test business logic
- **Integration Tests (20%)**: Test component interactions
- **E2E Tests (10%)**: Test complete user workflows

#### Write Tests First (TDD)
```typescript
// 1. Write failing test
describe('UserService', () => {
  it('should create user with valid data', async () => {
    const userData = { name: 'John', email: 'john@example.com' };
    const user = await userService.createUser(userData);
    
    expect(user.id).toBeDefined();
    expect(user.name).toBe(userData.name);
    expect(user.email).toBe(userData.email);
  });
});

// 2. Write minimal implementation to pass
// 3. Refactor and improve
```

#### Test Edge Cases
```typescript
describe('Email validation', () => {
  const validEmails = [
    'user@example.com',
    'user+tag@example.co.uk',
    'user.name@sub.example.org'
  ];
  
  const invalidEmails = [
    '',
    'not-an-email',
    '@example.com',
    'user@',
    'user@.com',
    null,
    undefined
  ];
  
  validEmails.forEach(email => {
    it(`should accept valid email: ${email}`, () => {
      expect(validateEmail(email)).toBe(true);
    });
  });
  
  invalidEmails.forEach(email => {
    it(`should reject invalid email: ${email}`, () => {
      expect(validateEmail(email)).toBe(false);
    });
  });
});
```

## Claude Code Best Practices

### Effective Prompting

#### Provide Rich Context
```bash
# ❌ Vague prompt
claude "Add user authentication"

# ✅ Specific prompt with context
claude "Read /docs/prd-auth.md and implement JWT-based authentication following the security requirements. Include user registration, login, token refresh, and logout endpoints with proper validation and error handling."
```

#### Use Progressive Disclosure
```bash
# Break complex tasks into phases
claude "Phase 1: Set up authentication middleware and JWT utilities"
claude --continue "Phase 2: Implement user registration with email validation"
claude --continue "Phase 3: Add login endpoint with rate limiting"
```

#### Leverage "Think" Modes Strategically
- **"think"**: Standard implementation decisions
- **"think hard"**: Architecture choices, complex algorithms
- **"ultrathink"**: System design, performance optimization

#### Verify and Iterate
```bash
# After implementation
claude --continue "Review the authentication implementation against the PRD requirements. Run tests and verify all acceptance criteria are met."

# For refinement
claude --continue "Optimize the authentication flow for better performance and add additional security headers."
```

### Documentation Integration

#### Keep Documentation Current
```bash
# Update docs as you implement
claude --continue "Update the API documentation to reflect the new authentication endpoints and add usage examples."
```

#### Use Claude for Documentation
```bash
claude "Generate comprehensive API documentation for the authentication endpoints, including request/response examples, error codes, and security considerations."
```

## Team Collaboration Best Practices

### Shared Standards

#### Establish Team Conventions
```markdown
# Team Coding Standards

## File Naming
- Components: PascalCase (e.g., UserProfile.tsx)
- Utilities: camelCase (e.g., formatDate.ts)
- Constants: SCREAMING_SNAKE_CASE (e.g., API_ENDPOINTS.ts)

## Code Organization
- Group related functionality together
- Separate concerns (presentation, business logic, data access)
- Use consistent folder structure across projects

## Git Workflow
- Feature branches for all changes
- Descriptive commit messages
- Code review required before merge
- Squash related commits
```

#### Create Reusable Templates
```typescript
// Standard service template
export class BaseService<T, CreateDto, UpdateDto> {
  constructor(
    protected readonly repository: Repository<T>,
    protected readonly logger: Logger
  ) {}
  
  async create(data: CreateDto): Promise<T> {
    // Standard implementation with logging, validation, error handling
  }
  
  async findById(id: string): Promise<T | null> {
    // Standard implementation
  }
  
  // ... other CRUD operations
}
```

### Code Review Process

#### Review Checklist
- [ ] Code follows team standards and conventions
- [ ] All acceptance criteria met
- [ ] Tests written and passing
- [ ] Error handling appropriate
- [ ] Performance considerations addressed
- [ ] Security best practices followed
- [ ] Documentation updated
- [ ] No obvious bugs or edge cases missed

#### Effective Review Comments
```markdown
# ❌ Unhelpful comments
"This is wrong"
"Fix this"
"Bad code"

# ✅ Constructive feedback
"Consider using a Map instead of an object for O(1) lookups"
"This function could benefit from input validation for the email parameter"
"Great error handling! Consider adding a specific error type for better debugging"
```

## Project-Specific Best Practices

### Simple Projects
- Keep solutions straightforward
- Avoid over-engineering
- Focus on meeting requirements efficiently
- Document decisions for future reference

### Medium Projects
- Invest in proper architecture
- Plan for moderate scale and growth
- Implement comprehensive testing
- Document integration points

### Complex Projects
- Follow enterprise patterns
- Implement comprehensive monitoring
- Plan for high availability
- Document everything thoroughly

### AI Agent Systems
- Safety first - implement multiple safety layers
- Monitor everything - agent behavior, performance, safety
- Plan for human oversight and intervention
- Test extensively including edge cases and failure modes

## Performance Best Practices

### Database Optimization
```sql
-- ❌ N+1 query problem
SELECT * FROM users WHERE active = true;
-- Then for each user:
SELECT * FROM user_profiles WHERE user_id = ?;

-- ✅ Join to fetch data in one query
SELECT u.*, up.* 
FROM users u 
LEFT JOIN user_profiles up ON u.id = up.user_id 
WHERE u.active = true;
```

### Caching Strategy
```typescript
// ❌ No caching
async function getUser(id: string): Promise<User> {
  return await userRepository.findById(id);
}

// ✅ With caching
async function getUser(id: string): Promise<User> {
  const cacheKey = `user:${id}`;
  const cached = await cache.get(cacheKey);
  
  if (cached) {
    return JSON.parse(cached);
  }
  
  const user = await userRepository.findById(id);
  if (user) {
    await cache.setex(cacheKey, 300, JSON.stringify(user)); // 5 min TTL
  }
  
  return user;
}
```

### API Optimization
```typescript
// ❌ Overfetching
app.get('/api/users', async (req, res) => {
  const users = await userRepository.findAll();
  res.json(users); // Returns all user data including sensitive fields
});

// ✅ Selective fields and pagination
app.get('/api/users', async (req, res) => {
  const { page = 1, limit = 20, fields = 'id,name,email' } = req.query;
  
  const users = await userRepository.findMany({
    page: Number(page),
    limit: Number(limit),
    select: fields.split(','),
    where: { active: true }
  });
  
  res.json({
    data: users,
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: await userRepository.count({ active: true })
    }
  });
});
```

## Security Best Practices

### Input Validation
```typescript
import { z } from 'zod';

// Define validation schema
const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  password: z.string().min(8).regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  age: z.number().int().min(18).max(120).optional()
});

// Use in endpoint
app.post('/api/users', async (req, res, next) => {
  try {
    const validatedData = CreateUserSchema.parse(req.body);
    const user = await userService.createUser(validatedData);
    res.status(201).json({ data: user });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        error: 'Validation failed',
        details: error.errors
      });
    }
    next(error);
  }
});
```

### Authentication & Authorization
```typescript
// JWT middleware
const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

// Role-based authorization
const requireRole = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};

// Usage
app.delete('/api/users/:id', 
  authenticateToken, 
  requireRole(['admin']), 
  deleteUserHandler
);
```

## Monitoring & Observability

### Structured Logging
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'app.log' }),
    new winston.transports.Console()
  ]
});

// Usage
logger.info('User created', {
  userId: user.id,
  email: user.email,
  correlationId: req.correlationId
});

logger.error('Database connection failed', {
  error: error.message,
  stack: error.stack,
  timestamp: new Date().toISOString()
});
```

### Health Checks
```typescript
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    externalAPI: await checkExternalAPI(),
    timestamp: new Date().toISOString()
  };
  
  const healthy = Object.values(checks).every(check => 
    typeof check === 'boolean' ? check : check.status === 'ok'
  );
  
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    checks
  });
});
```

## Deployment Best Practices

### Environment Configuration
```typescript
// config/environment.ts
import { z } from 'zod';

const EnvironmentSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  PORT: z.string().transform(Number),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  API_RATE_LIMIT: z.string().transform(Number).default('100')
});

export const env = EnvironmentSchema.parse(process.env);
```

### Docker Best Practices
```dockerfile
# Multi-stage build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs dist ./dist
COPY --chown=nodejs:nodejs package.json ./

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
```

## Common Pitfalls to Avoid

### Planning Pitfalls
- **Scope Creep**: Stick to defined requirements
- **Vague Requirements**: Make everything specific and testable
- **Ignoring Non-Functionals**: Consider performance, security, scalability early
- **No Success Metrics**: Define how you'll measure success

### Implementation Pitfalls
- **Premature Optimization**: Focus on working software first
- **Over-Engineering**: Start simple, evolve as needed
- **Poor Error Handling**: Plan for failure scenarios
- **Inadequate Testing**: Test the right things at the right level

### Claude Code Pitfalls
- **Insufficient Context**: Provide rich context for better results
- **Skipping Verification**: Always verify implementations
- **Monolithic Prompts**: Break complex tasks into phases
- **Ignoring Quality Gates**: Don't skip verification steps

---

**Remember: Best practices are guidelines, not rigid rules. Adapt them to your specific context, team, and project requirements.**
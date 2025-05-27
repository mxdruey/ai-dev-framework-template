# Agentic AI System Template

## Goal
Provide specialized guidance for designing and implementing AI agent systems, including multi-agent coordination, tool integration, memory management, and safety considerations.

## When to Use
- **Single AI Agent Systems**: Autonomous agents with tool integration
- **Multi-Agent Systems**: Coordinated agents working together
- **Human-in-the-Loop AI**: Agents requiring human oversight
- **Tool-Integrated AI**: Agents using external APIs and services
- **Conversational AI**: Chat-based or interactive agent systems

## AI Agent System Types

### Type 1: Single Autonomous Agent
- **Characteristics**: Independent operation, tool usage, goal-oriented
- **Use Cases**: Personal assistants, automated workflows, content generation
- **Complexity**: Medium
- **Examples**: Email assistant, document processor, data analyzer

### Type 2: Multi-Agent Collaborative System
- **Characteristics**: Multiple specialized agents, coordination protocols
- **Use Cases**: Complex problem solving, distributed tasks, expert systems
- **Complexity**: High
- **Examples**: Software development team, research assistants, trading systems

### Type 3: Human-Agent Hybrid System
- **Characteristics**: Human oversight, approval workflows, escalation paths
- **Use Cases**: High-stakes decisions, creative work, quality assurance
- **Complexity**: Medium-High
- **Examples**: Content review, medical diagnosis support, legal research

### Type 4: Reactive Agent System
- **Characteristics**: Event-driven, real-time responses, monitoring-based
- **Use Cases**: System monitoring, customer support, security response
- **Complexity**: Medium
- **Examples**: IT incident response, customer service bots, fraud detection

## AI System Architecture Template

### Step 1: Agent System Requirements
Extend standard PRD with AI-specific requirements:

```markdown
# AI Agent System PRD: [System Name]

## AI Agent Specifications

### Agent Types and Roles
- **[Agent Name 1]**: [Role, responsibilities, capabilities]
- **[Agent Name 2]**: [Role, responsibilities, capabilities]
- **Coordination Agent**: [If multi-agent system]

### AI Model Requirements
- **Primary Model**: [Claude, GPT-4, Custom model]
- **Model Configuration**: [Temperature, max tokens, system prompts]
- **Fallback Models**: [Backup options for reliability]
- **Cost Considerations**: [Budget constraints, optimization strategies]

### Tool Integration Requirements
- **External APIs**: [List of APIs agents will use]
- **Database Access**: [Read/write permissions, data access patterns]
- **File System**: [File operations, storage requirements]
- **Web Scraping**: [If applicable, sites and data types]
- **Communication Tools**: [Email, Slack, webhooks]

### Memory and State Management
- **Conversation Memory**: [How agents remember context]
- **Task Memory**: [Progress tracking, intermediate results]
- **Knowledge Base**: [Long-term information storage]
- **State Persistence**: [Between sessions, across restarts]

### Safety and Monitoring
- **Output Filtering**: [Content safety, harmful output prevention]
- **Action Limits**: [Rate limiting, scope restrictions]
- **Human Oversight**: [When and how humans intervene]
- **Audit Logging**: [All agent actions and decisions]
- **Emergency Stops**: [How to halt agent operations]

### Performance Requirements
- **Response Time**: [Acceptable latency for different operations]
- **Throughput**: [Requests per minute/hour]
- **Availability**: [Uptime requirements]
- **Scalability**: [Handling increased load]
```

### Step 2: Agent Architecture Design

```markdown
# AI Agent System Architecture

## System Components

### Agent Core Components
```
Agent System Architecture

┌──────────────────────────────────────────────────────────────┐
│                    Agent Orchestrator                       │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐ │
│  │  Task Router  │  │  Agent Pool   │  │  Result Merger  │ │
│  └───────────────┘  └───────────────┘  └─────────────────┘ │
└──────────────────────────────────────────────────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  Agent A        │  │  Agent B        │  │  Agent C        │
│  ┌─────────────┐│  │  ┌─────────────┐│  │  ┌─────────────┐│
│  │ LLM Core    ││  │  │ LLM Core    ││  │  │ LLM Core    ││
│  │ Memory      ││  │  │ Memory      ││  │  │ Memory      ││
│  │ Tools       ││  │  │ Tools       ││  │  │ Tools       ││
│  │ Safety      ││  │  │ Safety      ││  │  │ Safety      ││
│  └─────────────┘│  │  └─────────────┘│  │  └─────────────┘│
└─────────────────┘  └─────────────────┘  └─────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│                    Shared Services                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Knowledge  │  │  Tool       │  │  Monitoring &       │ │
│  │  Base       │  │  Registry   │  │  Logging            │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Individual Agent Structure
```typescript
interface AIAgent {
  id: string;
  type: AgentType;
  capabilities: string[];
  tools: Tool[];
  memory: AgentMemory;
  config: AgentConfig;
  safetyWrapper: SafetyWrapper;
}

interface AgentMemory {
  conversationHistory: Message[];
  taskContext: TaskContext;
  knowledgeBase: KnowledgeEntry[];
  workingMemory: any;
}

interface Tool {
  name: string;
  description: string;
  parameters: ToolParameter[];
  execute: (params: any) => Promise<ToolResult>;
  rateLimits: RateLimit;
}
```

### Multi-Agent Coordination Patterns

#### Sequential Processing
```
Task → Agent A → Agent B → Agent C → Result
```
- **Use Case**: Pipeline processing, step-by-step refinement
- **Example**: Research → Analysis → Report Generation

#### Parallel Processing
```
        ┌─ Agent A ─┐
Task ──┼─ Agent B ─┼── Merge → Result
        └─ Agent C ─┘
```
- **Use Case**: Independent subtasks, speed optimization
- **Example**: Multi-source data gathering, parallel analysis

#### Hierarchical Coordination
```
    Coordinator Agent
         │
    ┌────┼────┐
    │    │    │
Agent A │ Agent C
     Agent B
```
- **Use Case**: Complex decision making, specialized roles
- **Example**: Project management, expert consultation

#### Peer-to-Peer Collaboration
```
Agent A ←→ Agent B
   ↕        ↕
Agent D ←→ Agent C
```
- **Use Case**: Collaborative problem solving, consensus building
- **Example**: Multi-perspective analysis, debate systems

## Tool Integration Architecture

### Tool Categories

#### Information Retrieval Tools
- **Web Search**: Search engines, specific site searches
- **Database Query**: SQL, NoSQL, vector databases
- **API Calls**: REST APIs, GraphQL endpoints
- **File Access**: Local files, cloud storage, documents

#### Action Tools
- **Communication**: Email, Slack, webhooks, notifications
- **File Operations**: Create, update, delete files
- **API Operations**: POST/PUT requests, data submission
- **System Commands**: Script execution, system operations

#### Analysis Tools
- **Data Processing**: Statistical analysis, data transformation
- **Image Analysis**: Computer vision, image processing
- **Text Analysis**: NLP, sentiment analysis, extraction
- **Code Analysis**: Static analysis, code review, testing

### Tool Integration Patterns

```typescript
// Tool Registry Pattern
class ToolRegistry {
  private tools: Map<string, Tool> = new Map();
  
  register(tool: Tool): void {
    this.tools.set(tool.name, tool);
  }
  
  get(name: string): Tool | undefined {
    return this.tools.get(name);
  }
  
  list(): Tool[] {
    return Array.from(this.tools.values());
  }
}

// Tool Execution with Safety
class SafeToolExecutor {
  async execute(tool: Tool, params: any, agent: AIAgent): Promise<ToolResult> {
    // Pre-execution safety checks
    await this.validateParameters(tool, params);
    await this.checkRateLimits(tool, agent);
    await this.checkPermissions(tool, agent);
    
    // Execute with monitoring
    const startTime = Date.now();
    try {
      const result = await tool.execute(params);
      
      // Post-execution processing
      await this.logExecution(tool, params, result, Date.now() - startTime);
      return this.sanitizeResult(result);
    } catch (error) {
      await this.logError(tool, params, error);
      throw error;
    }
  }
}
```

## Memory Management Architecture

### Memory Types

#### Short-term Memory (Working Memory)
- **Purpose**: Current task context, immediate conversation
- **Duration**: Single session or task
- **Storage**: In-memory, fast access
- **Size Limits**: Token limits, memory constraints

#### Long-term Memory (Persistent Memory)
- **Purpose**: Knowledge base, learned patterns, history
- **Duration**: Persistent across sessions
- **Storage**: Database, vector store, file system
- **Retrieval**: Semantic search, keyword matching

#### Episodic Memory
- **Purpose**: Specific experiences, past interactions
- **Duration**: Long-term with decay/compression
- **Storage**: Structured records, timestamped
- **Usage**: Learning from experience, avoiding repeats

### Memory Implementation

```typescript
class AgentMemory {
  private workingMemory: WorkingMemory;
  private longTermMemory: LongTermMemory;
  private episodicMemory: EpisodicMemory;
  
  async store(type: MemoryType, data: any): Promise<void> {
    switch (type) {
      case 'working':
        this.workingMemory.store(data);
        break;
      case 'longterm':
        await this.longTermMemory.store(data);
        break;
      case 'episodic':
        await this.episodicMemory.store(data);
        break;
    }
  }
  
  async retrieve(query: string, type?: MemoryType): Promise<any[]> {
    const results = [];
    
    if (!type || type === 'working') {
      results.push(...this.workingMemory.search(query));
    }
    
    if (!type || type === 'longterm') {
      results.push(...await this.longTermMemory.search(query));
    }
    
    if (!type || type === 'episodic') {
      results.push(...await this.episodicMemory.search(query));
    }
    
    return this.rankResults(results, query);
  }
}
```

## Safety and Monitoring System

### Safety Layers

#### Input Safety
- **Prompt Injection Detection**: Identify malicious prompts
- **Content Filtering**: Remove harmful or inappropriate content
- **Parameter Validation**: Ensure tool parameters are safe
- **Rate Limiting**: Prevent abuse and excessive usage

#### Output Safety
- **Content Screening**: Filter harmful or inappropriate outputs
- **Action Validation**: Verify actions are within allowed scope
- **Confidence Thresholds**: Require high confidence for critical actions
- **Human Approval**: Require human approval for sensitive operations

#### Runtime Safety
- **Resource Monitoring**: CPU, memory, network usage
- **Execution Timeouts**: Prevent infinite loops or hanging
- **Error Handling**: Graceful failure and recovery
- **Emergency Stops**: Ability to halt all agent operations

### Monitoring Implementation

```typescript
class AgentMonitor {
  private metrics: MetricsCollector;
  private logger: Logger;
  private alertManager: AlertManager;
  
  async monitorAgentExecution(agent: AIAgent, task: Task): Promise<void> {
    const executionId = this.generateExecutionId();
    
    try {
      // Pre-execution monitoring
      await this.logTaskStart(executionId, agent, task);
      this.metrics.incrementCounter('tasks.started');
      
      // Monitor during execution
      const monitor = this.startRealTimeMonitoring(executionId);
      
      // Execute task with monitoring
      const result = await this.executeWithMonitoring(agent, task);
      
      // Post-execution monitoring
      await this.logTaskCompletion(executionId, result);
      this.metrics.incrementCounter('tasks.completed');
      
      return result;
    } catch (error) {
      await this.logTaskError(executionId, error);
      this.metrics.incrementCounter('tasks.failed');
      await this.alertManager.sendAlert('task_failure', { executionId, error });
      throw error;
    }
  }
}
```

## Human-in-the-Loop Integration

### Approval Workflows

#### Automatic Approval
- **Low-risk actions**: Information retrieval, read-only operations
- **Confidence threshold**: High-confidence actions within known parameters
- **Pre-approved patterns**: Actions matching established safe patterns

#### Human Review Required
- **High-impact actions**: Financial transactions, data deletion, system changes
- **Low-confidence results**: When agent confidence below threshold
- **New patterns**: Actions not seen before or outside normal parameters
- **Error recovery**: When automatic recovery fails

#### Implementation Pattern

```typescript
class HumanApprovalSystem {
  async requestApproval(action: AgentAction): Promise<ApprovalResult> {
    const riskLevel = await this.assessRisk(action);
    
    if (riskLevel === 'LOW') {
      return { approved: true, automatic: true };
    }
    
    // Create approval request
    const request = await this.createApprovalRequest(action, riskLevel);
    
    // Notify human reviewers
    await this.notifyReviewers(request);
    
    // Wait for approval with timeout
    return await this.waitForApproval(request, APPROVAL_TIMEOUT);
  }
  
  private async assessRisk(action: AgentAction): Promise<RiskLevel> {
    const factors = {
      impactLevel: this.assessImpact(action),
      confidence: action.confidence,
      previousPatterns: await this.checkPreviousPatterns(action),
      resourceRequirements: this.assessResources(action)
    };
    
    return this.calculateRiskLevel(factors);
  }
}
```

## Implementation Guidance for Claude Code

### Project Structure

```
ai-agent-system/
├── src/
│   ├── agents/
│   │   ├── base/
│   │   │   ├── Agent.ts              # Base agent class
│   │   │   ├── AgentMemory.ts        # Memory management
│   │   │   └── SafetyWrapper.ts      # Safety mechanisms
│   │   ├── specialized/
│   │   │   ├── ResearchAgent.ts      # Research specialist
│   │   │   ├── AnalysisAgent.ts      # Data analysis specialist
│   │   │   └── CoordinatorAgent.ts   # Multi-agent coordination
│   │   └── index.ts
│   ├── tools/
│   │   ├── base/
│   │   │   ├── Tool.ts               # Base tool interface
│   │   │   ├── ToolRegistry.ts       # Tool management
│   │   │   └── ToolExecutor.ts       # Safe execution
│   │   ├── implementations/
│   │   │   ├── WebSearchTool.ts      # Web search capability
│   │   │   ├── DatabaseTool.ts       # Database operations
│   │   │   ├── EmailTool.ts          # Email integration
│   │   │   └── FileTool.ts           # File operations
│   │   └── index.ts
│   ├── memory/
│   │   ├── WorkingMemory.ts          # Short-term memory
│   │   ├── LongTermMemory.ts         # Persistent memory
│   │   ├── EpisodicMemory.ts         # Experience memory
│   │   └── VectorStore.ts            # Semantic search
│   ├── coordination/
│   │   ├── TaskRouter.ts             # Task distribution
│   │   ├── AgentPool.ts              # Agent management
│   │   ├── ResultMerger.ts           # Result aggregation
│   │   └── CoordinationProtocols.ts  # Communication patterns
│   ├── safety/
│   │   ├── SafetyChecker.ts          # Safety validation
│   │   ├── ContentFilter.ts          # Content screening
│   │   ├── RateLimiter.ts            # Usage limits
│   │   └── AuditLogger.ts            # Action logging
│   ├── monitoring/
│   │   ├── AgentMonitor.ts           # Performance monitoring
│   │   ├── MetricsCollector.ts       # Metrics gathering
│   │   ├── AlertManager.ts           # Alert system
│   │   └── Dashboard.ts              # Monitoring UI
│   ├── human-integration/
│   │   ├── ApprovalSystem.ts         # Human approval workflows
│   │   ├── NotificationService.ts    # Human notifications
│   │   └── ReviewInterface.ts        # Review UI
│   ├── config/
│   │   ├── AgentConfigs.ts           # Agent configurations
│   │   ├── ModelConfigs.ts           # LLM model settings
│   │   ├── SafetyConfigs.ts          # Safety parameters
│   │   └── EnvironmentConfig.ts      # Environment settings
│   ├── utils/
│   │   ├── Logger.ts                 # Logging utilities
│   │   ├── ErrorHandler.ts           # Error management
│   │   ├── ValidationUtils.ts        # Input validation
│   │   └── CryptoUtils.ts            # Security utilities
│   └── app.ts                        # Application entry point
├── tests/
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   ├── e2e/                          # End-to-end tests
│   └── safety/                       # Safety testing
├── docs/
│   ├── agent-specifications.md       # Agent behavior specs
│   ├── tool-documentation.md         # Tool usage guides
│   ├── safety-guidelines.md          # Safety procedures
│   └── deployment-guide.md           # Deployment instructions
├── config/
│   ├── development.json              # Dev environment config
│   ├── staging.json                  # Staging config
│   ├── production.json               # Production config
│   └── safety-rules.json             # Safety rule definitions
└── scripts/
    ├── setup-agents.sh               # Agent initialization
    ├── deploy.sh                     # Deployment script
    └── monitor.sh                    # Monitoring setup
```

### Implementation Commands for Claude Code

```bash
# Phase 1: Core Agent Infrastructure
claude "Set up AI agent system following the architecture. Start with base Agent class, AgentMemory, and SafetyWrapper. Include TypeScript interfaces and basic error handling."

# Phase 2: Tool System
claude --continue "Implement tool system with ToolRegistry, base Tool interface, and SafeToolExecutor. Include rate limiting and safety validation."

# Phase 3: Memory Management
claude --continue "Implement memory management system with WorkingMemory, LongTermMemory, and vector-based retrieval capabilities."

# Phase 4: Multi-Agent Coordination
claude --continue "Implement TaskRouter, AgentPool, and coordination protocols for multi-agent collaboration."

# Phase 5: Safety and Monitoring
claude --continue "Implement comprehensive safety system with content filtering, rate limiting, audit logging, and monitoring."

# Phase 6: Human Integration
claude --continue "Implement human-in-the-loop approval system with notification service and review interfaces."

# Phase 7: Testing and Documentation
claude --continue "Create comprehensive test suite including safety testing and complete documentation for agent system."
```

## AI-Specific Quality Gates

### Safety Verification
- [ ] All agent outputs filtered for harmful content
- [ ] Rate limiting implemented and tested
- [ ] Human approval workflows working for high-risk actions
- [ ] Emergency stop functionality tested
- [ ] Audit logging capturing all agent actions

### Performance Verification
- [ ] Response times meet requirements under load
- [ ] Memory usage optimized and monitored
- [ ] Tool execution within timeout limits
- [ ] Multi-agent coordination efficient
- [ ] Resource usage stays within bounds

### Reliability Verification
- [ ] Graceful handling of model API failures
- [ ] Proper error recovery and fallback mechanisms
- [ ] State persistence working across restarts
- [ ] Tool failures handled without system crash
- [ ] Agent coordination resilient to individual failures

### Ethical and Legal Verification
- [ ] Data privacy requirements met
- [ ] Consent mechanisms implemented where required
- [ ] Bias testing completed for decision-making agents
- [ ] Transparency and explainability features working
- [ ] Compliance with relevant regulations verified

## Common AI System Patterns

### Research Assistant Pattern
```typescript
class ResearchAssistant extends BaseAgent {
  async conductResearch(query: string): Promise<ResearchResult> {
    // 1. Query planning and decomposition
    const searchQueries = await this.planQueries(query);
    
    // 2. Parallel information gathering
    const results = await Promise.all(
      searchQueries.map(q => this.searchTool.execute(q))
    );
    
    // 3. Information synthesis
    const synthesized = await this.synthesizeResults(results);
    
    // 4. Quality verification and fact-checking
    return await this.verifyAndRank(synthesized);
  }
}
```

### Decision Support Pattern
```typescript
class DecisionSupportAgent extends BaseAgent {
  async analyzeDecision(context: DecisionContext): Promise<DecisionAnalysis> {
    // 1. Gather relevant information
    const data = await this.gatherContext(context);
    
    // 2. Generate alternatives
    const alternatives = await this.generateAlternatives(data);
    
    // 3. Analyze pros/cons for each
    const analysis = await this.analyzeAlternatives(alternatives);
    
    // 4. Recommend with confidence scores
    const recommendation = await this.generateRecommendation(analysis);
    
    // 5. Request human review if low confidence
    if (recommendation.confidence < CONFIDENCE_THRESHOLD) {
      await this.requestHumanReview(recommendation);
    }
    
    return recommendation;
  }
}
```

### Workflow Automation Pattern
```typescript
class WorkflowAgent extends BaseAgent {
  async executeWorkflow(workflow: WorkflowDefinition): Promise<WorkflowResult> {
    const context = new WorkflowContext();
    
    for (const step of workflow.steps) {
      try {
        // Execute step with safety checks
        const result = await this.executeStep(step, context);
        context.addResult(step.id, result);
        
        // Check if human approval needed
        if (step.requiresApproval) {
          await this.requestApproval(step, result);
        }
        
      } catch (error) {
        // Handle step failure
        await this.handleStepFailure(step, error, context);
        
        if (step.critical) {
          throw new WorkflowFailureError(step, error);
        }
      }
    }
    
    return this.finalizeWorkflow(context);
  }
}
```

---

**This template provides comprehensive guidance for implementing AI agent systems with Claude Code. Focus on safety, monitoring, and human oversight throughout the development process.**
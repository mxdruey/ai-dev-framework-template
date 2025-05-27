# AI Development Framework Guide

## Quick Start

### 1. Choose Your Project Type

**Simple Feature** (< 1 week)
- Single functionality addition
- Minimal external dependencies
- Basic quality requirements
- **Templates**: Basic PRD, Simple task structure

**Medium Project** (1-4 weeks)
- Multiple integrated features
- External API integrations
- Moderate complexity
- **Templates**: Comprehensive PRD, Architecture overview, Detailed tasks

**Complex Application** (> 1 month)
- Full-stack applications
- Enterprise requirements
- High availability needs
- **Templates**: Full documentation suite, Detailed architecture, Risk assessment

**Agentic AI System** (Variable)
- AI agent implementations
- Multi-agent coordination
- Tool integration needs
- **Templates**: AI-specific PRD, Agent architecture, Safety guidelines

### 2. Planning Phase (Claude Desktop - Opus 4)

Start your planning session with this prompt:

```
I want to build [describe your project/feature in detail].

This appears to be a [Simple/Medium/Complex/Agentic AI] project.

Please use the appropriate templates from this AI Development Framework to help me create comprehensive planning documents:

1. Start with /docs/templates/create-prd.md to create a detailed PRD
2. If Medium/Complex, use /docs/templates/architecture-template.md for technical architecture
3. If Agentic AI, use /docs/templates/agentic-ai-template.md for AI-specific considerations
4. Use /docs/templates/generate-tasks.md to create implementation tasks
5. Generate a project-specific CLAUDE.md configuration

Ask me clarifying questions to ensure we capture all requirements properly. Optimize everything for Claude Code implementation.
```

### 3. Repository Setup

```bash
# Option 1: Use as GitHub template
gh repo create my-new-project --template mxdruey/ai-dev-framework-template
cd my-new-project

# Option 2: Clone and customize
git clone https://github.com/mxdruey/ai-dev-framework-template.git my-project
cd my-project
rm -rf .git
git init
git add .
git commit -m "Initial project setup from AI dev framework template"

# Copy planning documents from Claude Desktop session
# Add your generated docs to /docs/ directory

# Customize CLAUDE.md for your specific project
# Update README.md with project-specific information

git add .
git commit -m "Add project planning documents"
```

### 4. Implementation Phase (Claude Code - Sonnet 4)

```bash
# Navigate to your project
cd my-project

# Start Claude Code
claude

# Begin implementation
claude "Read all planning documents in /docs/ and implement this project following the task sequence. Start with the first task in the implementation plan."
```

## Detailed Workflow

### Planning Phase Deep Dive

#### Step 1: Requirements Gathering
Use the planning templates to systematically gather requirements:

**For All Projects:**
- Problem statement and goals
- Target users and use cases
- Functional requirements
- Success metrics
- Non-goals and constraints

**For Medium/Complex Projects:**
- Technical architecture requirements
- Integration needs
- Performance requirements
- Security considerations
- Deployment strategy

**For AI Systems:**
- Agent specifications
- Tool integration requirements
- Safety and monitoring needs
- Human oversight requirements
- Ethical considerations

#### Step 2: Architecture Planning

**Simple Projects:**
- Basic component structure
- Technology stack selection
- Simple data flow

**Medium/Complex Projects:**
- Detailed system architecture
- Database design
- API specifications
- Security architecture
- Performance optimization
- Monitoring and observability

**AI Systems:**
- Agent architecture design
- Multi-agent coordination patterns
- Tool integration architecture
- Memory management system
- Safety and monitoring systems

#### Step 3: Task Breakdown
Generate detailed implementation tasks with:
- Clear acceptance criteria
- Dependency relationships
- Claude Code execution commands
- Quality gates and verification steps
- Estimated timelines

#### Step 4: Documentation Generation
Create comprehensive documentation:
- **PRD**: Product requirements and specifications
- **Architecture**: Technical design and decisions
- **Tasks**: Implementation roadmap
- **CLAUDE.md**: Project-specific Claude Code configuration

### Implementation Phase Deep Dive

#### Phase Structure

**Phase 1: Foundation**
- Project setup and configuration
- Core data models and types
- Basic infrastructure setup
- Development environment configuration

**Phase 2: Core Implementation**
- Main business logic implementation
- API development (if applicable)
- Database integration
- Core feature functionality

**Phase 3: Integration & Testing**
- External service integration
- Comprehensive test suite
- Performance optimization
- Security implementation

**Phase 4: Polish & Deployment**
- Documentation completion
- Deployment preparation
- Monitoring setup
- Final quality assurance

#### Quality Gates

At each phase, verify:
- [ ] All phase tasks completed
- [ ] Tests passing for implemented functionality
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Performance requirements met (if applicable)
- [ ] Security requirements verified
- [ ] No critical issues outstanding

#### Claude Code Execution Patterns

**Sequential Execution (Recommended for beginners):**
```bash
# Execute tasks one by one
claude "Implement Task 1.1 from the implementation plan"
claude --continue "Move to Task 1.2 after verifying Task 1.1 is complete"
# Continue through all tasks systematically
```

**Batch Processing (For experienced users):**
```bash
# Process entire phases
claude "Implement all Phase 1 tasks following the specifications"
claude --continue "Continue with Phase 2 implementation"
```

**Adaptive Execution (For complex projects):**
```bash
# Start with planning verification
claude "Review the implementation plan and suggest any improvements based on current best practices"
# Then proceed with implementation
claude --continue "Begin implementation starting with the highest priority tasks"
```

## Best Practices

### Planning Best Practices

#### Requirements Gathering
- **Be Specific**: Avoid vague requirements; make everything testable
- **Consider Edge Cases**: Think through error scenarios and boundary conditions
- **Plan for Scale**: Consider how requirements change with growth
- **Document Assumptions**: Capture all assumptions and constraints
- **Prioritize Ruthlessly**: Distinguish must-haves from nice-to-haves

#### Architecture Design
- **Start Simple**: Begin with the simplest architecture that meets requirements
- **Plan for Change**: Make architecture adaptable to requirement changes
- **Security First**: Build security considerations into the foundation
- **Monitor Everything**: Plan observability from the beginning
- **Document Decisions**: Capture rationale for all major architectural choices

#### Task Breakdown
- **Small Batches**: Keep tasks small enough to complete in a day or less
- **Clear Dependencies**: Make task dependencies explicit and manageable
- **Testable Outcomes**: Each task should have clear, testable acceptance criteria
- **Risk Mitigation**: Identify and plan for high-risk tasks early
- **Parallel Paths**: Structure tasks to enable parallel development where possible

### Implementation Best Practices

#### Code Quality
- **Follow Standards**: Use consistent coding conventions throughout
- **Test Early**: Write tests as you implement functionality
- **Document Intent**: Comment the "why", not just the "what"
- **Handle Errors**: Implement comprehensive error handling
- **Security Mindset**: Validate inputs, sanitize outputs, follow security best practices

#### Claude Code Usage
- **Provide Context**: Always ensure Claude Code has access to relevant documentation
- **Verify Results**: Review each implementation step before proceeding
- **Use Quality Gates**: Don't skip verification steps
- **Iterate When Needed**: Don't hesitate to refine approaches based on results
- **Maintain Documentation**: Keep project documentation updated as implementation progresses

#### Testing Strategy
- **Test Pyramid**: Unit tests > Integration tests > E2E tests
- **Test Coverage**: Aim for >90% coverage on business logic
- **Edge Cases**: Test boundary conditions and error scenarios
- **Performance Testing**: Verify performance requirements are met
- **Security Testing**: Include security-focused test cases

### AI System Best Practices

#### Safety First
- **Multiple Safety Layers**: Implement input filtering, output screening, and action validation
- **Human Oversight**: Build in human approval for high-risk actions
- **Rate Limiting**: Prevent abuse through proper rate limiting
- **Audit Everything**: Log all agent actions for review and compliance
- **Emergency Stops**: Always have a way to immediately halt agent operations

#### Performance Optimization
- **Model Selection**: Choose appropriate models for each task (cost vs capability)
- **Caching**: Cache expensive operations and frequent queries
- **Parallel Processing**: Use multi-agent patterns for parallelizable tasks
- **Resource Management**: Monitor and limit resource usage
- **Graceful Degradation**: Handle model API failures gracefully

#### Monitoring and Observability
- **Comprehensive Logging**: Log agent decisions, tool usage, and outcomes
- **Performance Metrics**: Track response times, success rates, and resource usage
- **Business Metrics**: Monitor task completion rates and user satisfaction
- **Alert Systems**: Set up alerts for failures, performance issues, and safety concerns
- **Dashboard Views**: Create dashboards for different stakeholders

## Troubleshooting Guide

### Common Planning Issues

**Problem**: Requirements are too vague or broad
**Solution**: Use the template questions to drill down into specifics. Ask "How will we know this is successful?" for each requirement.

**Problem**: Architecture seems too complex for the problem
**Solution**: Start with the simplest architecture that meets core requirements. Plan to evolve it as needed.

**Problem**: Task dependencies are circular or unclear
**Solution**: Map out dependencies visually. Break circular dependencies by identifying which parts can be stubbed or mocked.

**Problem**: Timeline estimates are wildly inaccurate
**Solution**: Break tasks down further. Use historical data. Add buffer time for unknowns.

### Common Implementation Issues

**Problem**: Claude Code doesn't understand the context
**Solution**: Ensure CLAUDE.md is comprehensive and up-to-date. Reference specific documentation files in your commands.

**Problem**: Implementation deviates significantly from plan
**Solution**: Update planning documents to reflect new understanding. Don't force implementation to match outdated plans.

**Problem**: Quality gates are failing consistently
**Solution**: Review requirements and standards. Adjust either the implementation approach or the quality criteria as appropriate.

**Problem**: Performance requirements can't be met
**Solution**: Revisit architecture decisions. Consider if requirements are realistic. Implement performance optimizations incrementally.

### AI System Specific Issues

**Problem**: AI agent outputs are inconsistent or unreliable
**Solution**: Review system prompts and examples. Implement output validation. Consider fine-tuning or different models.

**Problem**: Safety measures are blocking legitimate operations
**Solution**: Review safety rules and thresholds. Implement more sophisticated safety checks. Add human review workflows.

**Problem**: Multi-agent coordination is causing conflicts
**Solution**: Review coordination protocols. Implement better state management. Add conflict resolution mechanisms.

**Problem**: Tool integration is unreliable
**Solution**: Implement proper retry logic and fallback mechanisms. Add comprehensive error handling for external services.

## Framework Customization

### Adapting Templates

The framework templates are designed to be customized for your specific needs:

#### Organization-Specific Customization
- Add your coding standards and conventions
- Include your preferred technology stacks
- Incorporate your security and compliance requirements
- Add your deployment and infrastructure patterns

#### Domain-Specific Customization
- Add industry-specific requirements templates
- Include domain-specific architecture patterns
- Add specialized quality gates and verification steps
- Include regulatory and compliance considerations

#### Team-Specific Customization
- Adjust for team size and expertise
- Include your preferred communication and collaboration tools
- Add your code review and approval processes
- Incorporate your project management methodologies

### Contributing Back

If you develop improvements or new templates:
1. Fork the framework repository
2. Add your enhancements
3. Submit a pull request with clear description
4. Share your experiences and learnings

### Maintaining Your Framework

- **Regular Updates**: Keep templates updated with lessons learned
- **Feedback Integration**: Incorporate feedback from team members
- **Best Practice Evolution**: Update practices as industry standards evolve
- **Tool Integration**: Add new tools and technologies as they become available

---

**This framework is designed to evolve with your development practices. Start with the basics, customize for your needs, and continuously improve based on your experiences.**
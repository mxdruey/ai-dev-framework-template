# Claude Code Configuration: AI Dev Framework Template

## Project Overview
This is the **AI Development Framework Template** - a comprehensive foundation for AI-assisted development using Claude Desktop (Opus 4) for strategic planning and Claude Code (Sonnet 4) for systematic implementation.

**Framework Philosophy**: Optimize development workflow through structured handoff between planning and implementation phases.

## Quick Reference
- **Templates**: `/docs/templates/` - Planning and development templates
- **Examples**: `/docs/examples/` - Real-world implementation examples  
- **Guides**: `/docs/guides/` - Usage instructions and best practices
- **Config**: `/config/` - Configuration templates for different project types

## Development Workflow

### Getting Started with This Template
1. **Fork/Clone**: Use this repository as a template for new projects
2. **Customize**: Select appropriate templates based on project complexity
3. **Plan**: Use Claude Desktop with planning templates to create project documentation
4. **Implement**: Use Claude Code with generated documentation for systematic development

### Project Planning Phase (Claude Desktop - Opus 4)
Before implementation, use the planning templates:
- **`/docs/templates/create-prd.md`** - Product Requirements Document creation
- **`/docs/templates/generate-tasks.md`** - Task breakdown methodology
- **`/docs/templates/architecture-template.md`** - Technical architecture planning
- **`/docs/templates/agentic-ai-template.md`** - AI agent systems (if applicable)

### Implementation Phase (Claude Code - Sonnet 4)
Use the generated planning documents for systematic implementation:
1. Read project documentation in `/docs/` directory
2. Follow task sequence from planning phase
3. Implement with built-in quality gates
4. Verify against requirements and acceptance criteria

## Implementation Standards

### Code Quality
- Follow language-specific best practices and conventions
- Implement comprehensive error handling and logging
- Maintain test coverage >90% for business logic
- Use TypeScript/type safety where applicable
- Document complex business logic and architectural decisions

### Testing Requirements
- **Unit Tests**: All business logic and utility functions
- **Integration Tests**: API endpoints and service integrations
- **Edge Cases**: Error conditions and boundary cases
- **Performance Tests**: Critical paths and scalability requirements

### Documentation Standards
- Keep README.md updated with setup and usage instructions
- Document API endpoints with request/response examples
- Include architecture diagrams for complex systems
- Maintain changelog for significant updates

### Git Workflow
- Use descriptive commit messages with task/feature references
- Create feature branches for significant changes
- Include tests in the same commit as implementation
- Squash related commits before merging

## Project Type Guidance

### Simple Features (< 1 week)
- Use streamlined templates from `/docs/templates/`
- Focus on core functionality with basic quality gates
- Minimal documentation requirements
- Direct implementation approach

### Medium Projects (1-4 weeks)
- Use comprehensive planning templates
- Include architecture documentation
- Full testing strategy implementation
- Integration with external services

### Complex Applications (> 1 month)
- Complete planning documentation required
- Detailed architecture and design documents
- Enterprise-grade quality standards
- Full deployment and monitoring strategy

### Agentic AI Systems
- Use AI-specific templates in `/docs/templates/agentic-ai-template.md`
- Focus on multi-agent coordination patterns
- Implement comprehensive safety and monitoring
- Include tool integration and memory management

## Framework Commands

### Template Usage
```bash
# Initialize new project from template
./scripts/setup-project.sh

# Generate project documentation (use with Claude Desktop)
# "Use /docs/templates/create-prd.md to plan my [project description]"

# Begin implementation (use with Claude Code)
# "Read planning documents and implement following task sequence"
```

### Quality Verification
```bash
# Run all tests
npm test

# Check code quality
npm run lint

# Verify test coverage
npm run test:coverage

# Run security audit
npm audit
```

## File Structure Expectations

### For New Projects Created from This Template
```
your-new-project/
├── docs/
│   ├── prd-[feature].md        # Generated from templates
│   ├── tasks-[feature].md      # Implementation roadmap
│   └── architecture.md         # Technical design (if needed)
├── src/
│   ├── [feature]/
│   │   ├── index.ts
│   │   ├── types.ts
│   │   ├── utils.ts
│   │   └── [feature].test.ts
├── tests/
├── config/
├── CLAUDE.md                   # Project-specific configuration
└── README.md
```

### For This Template Repository
```
ai-dev-framework-template/
├── docs/
│   ├── templates/              # Planning templates
│   ├── examples/               # Implementation examples
│   └── guides/                 # Usage documentation
├── config/                     # Configuration templates
├── scripts/                    # Automation scripts
├── src/templates/              # Code templates
├── tests/templates/            # Test templates
└── CLAUDE.md                   # This file
```

## Implementation Guidance

### Starting a New Project
1. **Use Template**: Create new repository from this template
2. **Select Complexity**: Choose simple/medium/complex approach
3. **Plan with Claude Desktop**: Use planning templates to create documentation
4. **Configure**: Update CLAUDE.md for project-specific requirements
5. **Implement with Claude Code**: Follow systematic implementation approach

### Working with Planning Documents
- Always read and understand PRD before implementation
- Follow task sequence for optimal dependency management
- Use quality gates to verify progress against requirements
- Update documentation when requirements change

### Code Implementation Patterns
- Start with data models and types
- Implement core business logic with comprehensive testing
- Add integration points and external service connections
- Polish with documentation, optimization, and monitoring

### When Stuck or Facing Issues
- Review planning documents for clarification
- Use "ultrathink" for complex architectural decisions
- Break down problems into smaller, manageable components
- Consider alternative approaches and document decisions
- Refer to examples in `/docs/examples/` for similar patterns

## Quality Checklist

Before completing any significant implementation:
- [ ] All functional requirements from planning documents implemented
- [ ] User stories working as specified
- [ ] Test coverage >90% for business logic
- [ ] Code follows project standards and conventions
- [ ] Documentation updated and accurate
- [ ] Performance requirements met
- [ ] Security considerations addressed
- [ ] Integration points tested and verified

## Success Criteria

### Framework Template Success
- Templates are comprehensive and easy to use
- Examples cover common project types
- Documentation is clear and actionable
- Automation scripts work reliably

### Project Implementation Success
- All planning requirements implemented
- Quality gates met consistently
- Code is maintainable and well-documented
- Performance and security requirements satisfied
- Ready for deployment and production use

## Framework Evolution

This template is designed to evolve with your development practices:
- **Update templates** based on project learnings
- **Add new examples** for different project types
- **Improve automation** scripts and quality gates
- **Share improvements** back to the community

---

**This CLAUDE.md file serves as the master configuration for the framework template. When using this template for specific projects, customize this file with project-specific requirements, technology stack details, and implementation guidelines.**

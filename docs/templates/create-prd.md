# PRD Creation Framework

## Goal
Create a comprehensive Product Requirements Document optimized for Claude Code implementation, with complexity assessment and structured handoff guidance.

## Process

### Step 1: Project Complexity Assessment
Determine the project scale to select appropriate template depth:

- **Simple** (< 1 week): Single feature, minimal dependencies, basic integration
- **Medium** (1-4 weeks): Multiple features, external integrations, moderate complexity
- **Complex** (> 1 month): Full applications, enterprise requirements, extensive architecture
- **Agentic AI** (Variable): AI agent systems, multi-agent coordination, tool integration

### Step 2: Requirements Gathering

#### Core Questions (All Projects)
1. **Problem Statement**: What specific problem does this solve for users?
2. **Target Users**: Who is the primary audience? What are their characteristics?
3. **User Stories**: What are the key user journeys? (As a [user], I want [goal] so that [benefit])
4. **Success Criteria**: How will you measure success? What are the key metrics?
5. **Non-Goals**: What should this explicitly NOT do? What are the boundaries?

#### Technical Questions (Medium/Complex/AI)
6. **Technology Stack**: What languages, frameworks, and tools are required/preferred?
7. **Integration Requirements**: What existing systems, APIs, or services need integration?
8. **Performance Requirements**: Response times, throughput, scalability expectations?
9. **Security Considerations**: Authentication, authorization, data protection needs?
10. **Deployment Environment**: Where and how will this be deployed?

#### Scale Questions (Complex/AI Only)
11. **Load Expectations**: Expected user volume, data volume, concurrent usage?
12. **Compliance Requirements**: GDPR, HIPAA, SOX, industry-specific regulations?
13. **Maintenance Model**: Who will maintain this? What's the support strategy?
14. **Long-term Vision**: How does this fit into broader product roadmap?

#### AI-Specific Questions (Agentic AI Systems)
15. **Agent Architecture**: Single agent or multi-agent system?
16. **Tool Integration**: What external tools/APIs will agents use?
17. **Memory Requirements**: What state/memory do agents need to maintain?
18. **Safety Considerations**: What safety measures and monitoring are needed?
19. **Human Oversight**: What level of human intervention is required?

### Step 3: Generate PRD Structure

Create `/docs/prd-[feature-name].md` with complexity-appropriate sections:

#### Simple Projects
```markdown
# PRD: [Feature Name]

## Overview
[Brief description of feature and problem it solves]

## Goals
- [Specific, measurable objective 1]
- [Specific, measurable objective 2]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- As a [user type], I want to [action] so that [benefit]

## Functional Requirements
1. The system must [specific requirement]
2. The system must [specific requirement]
3. Users should be able to [specific capability]

## Non-Goals (Out of Scope)
- [What this feature will NOT include]
- [Boundaries and limitations]

## Success Metrics
- [How success will be measured]
- [Specific KPIs or benchmarks]

## Claude Code Implementation Notes
- **Entry Point**: [Where Claude Code should start implementation]
- **Key Files**: [List main files to create]
- **Testing Approach**: [How to verify implementation]
- **Quality Gates**: [Checkpoints for review]
```

#### Medium Projects
Include all Simple sections plus:
```markdown
## Technical Requirements
- **Technology Stack**: [Languages, frameworks, tools]
- **Performance**: [Response times, throughput requirements]
- **Security**: [Authentication, authorization, data protection]
- **Integration**: [External APIs, services, databases]
- **Data Requirements**: [Data models, storage, processing needs]

## Architecture Overview
- **System Components**: [High-level system architecture]
- **Integration Points**: [How components interact]
- **Data Flow**: [How data moves through the system]

## Implementation Phases
- **Phase 1**: [Core functionality - week 1]
- **Phase 2**: [Feature expansion - week 2-3]
- **Phase 3**: [Polish and optimization - week 4]
```

#### Complex Projects
Include all Medium sections plus:
```markdown
## Detailed Architecture
- **System Design**: [Comprehensive architecture documentation]
- **Database Design**: [Schema, relationships, scaling considerations]
- **API Design**: [Endpoint specifications, authentication, versioning]
- **Security Architecture**: [Comprehensive security measures]

## Deployment Strategy
- **Environment Setup**: [Development, staging, production]
- **CI/CD Pipeline**: [Automated testing and deployment]
- **Monitoring**: [Logging, metrics, alerting]
- **Scaling Strategy**: [How to handle growth]

## Risk Assessment
- **Technical Risks**: [Implementation challenges]
- **Business Risks**: [Market, timeline, resource risks]
- **Mitigation Strategies**: [How to address each risk]

## Team Coordination
- **Roles and Responsibilities**: [Who does what]
- **Communication Plan**: [How team stays aligned]
- **Review Process**: [Code review, design review procedures]
```

#### Agentic AI Systems
Include relevant sections above plus:
```markdown
## AI Agent Architecture
- **Agent Types**: [Different agents and their roles]
- **Coordination Patterns**: [How agents work together]
- **Tool Integration**: [External tools and APIs agents will use]
- **Memory Management**: [State persistence and sharing]

## Safety and Monitoring
- **Safety Measures**: [Guardrails and constraints]
- **Human Oversight**: [When and how humans intervene]
- **Monitoring Systems**: [Agent behavior tracking]
- **Failure Handling**: [What happens when agents fail]

## Ethical Considerations
- **Bias Prevention**: [How to avoid unfair outcomes]
- **Transparency**: [Explainability requirements]
- **Privacy Protection**: [Data handling and privacy]
- **Accountability**: [Who is responsible for agent actions]
```

### Step 4: Implementation Guidance

Include clear handoff instructions for Claude Code:

```markdown
## Claude Code Handoff Instructions

### Implementation Strategy
1. **Read Documentation**: Start by understanding this PRD completely
2. **Verify Requirements**: Confirm understanding of all functional requirements
3. **Plan Architecture**: Design system structure following architecture guidelines
4. **Implement Incrementally**: Build in phases with testing at each stage
5. **Verify Against PRD**: Ensure all requirements are met before completion

### Recommended Implementation Order
1. **Setup**: Project structure, dependencies, basic configuration
2. **Data Models**: Types, interfaces, database schema
3. **Core Logic**: Main business functionality
4. **Integration**: External services, APIs, authentication
5. **Testing**: Comprehensive test suite
6. **Documentation**: Code docs, API docs, user guides
7. **Polish**: Performance optimization, error handling, monitoring

### Quality Verification
Before marking complete, verify:
- [ ] All functional requirements implemented
- [ ] All user stories working as specified
- [ ] Performance requirements met
- [ ] Security requirements satisfied
- [ ] Test coverage >90%
- [ ] Documentation complete
```

## Best Practices

### During Requirements Gathering
- Ask follow-up questions to clarify ambiguous requirements
- Focus on the "what" and "why", not the "how"
- Consider edge cases and error scenarios
- Think about scalability and future evolution
- Document assumptions and constraints

### PRD Writing
- Use clear, specific language avoiding jargon
- Include concrete examples where helpful
- Make requirements testable and verifiable
- Prioritize requirements (must-have vs nice-to-have)
- Keep the target audience (Claude Code) in mind

### Handoff Preparation
- Ensure all sections are complete and clear
- Include specific implementation guidance
- Provide quality gates and verification criteria
- Consider the development environment and tooling
- Plan for iterative feedback and refinement

## Common Pitfalls to Avoid

- **Scope Creep**: Clearly define what's out of scope
- **Vague Requirements**: Make everything specific and testable
- **Missing Context**: Provide sufficient background and rationale
- **Ignoring Constraints**: Document technical and business constraints
- **Poor Success Metrics**: Ensure metrics are measurable and relevant

---

**Next Steps**: After completing the PRD, use `/docs/templates/generate-tasks.md` to create a detailed implementation plan for Claude Code execution.
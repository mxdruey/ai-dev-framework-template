# 🚀 AI Development Framework Template

A comprehensive template repository for AI-assisted development using **Claude Desktop (Opus 4)** for strategic planning and **Claude Code (Sonnet 4)** for systematic implementation.

## 🎯 Framework Philosophy

This framework optimizes the development workflow by:
- **Strategic Planning**: Use Claude Desktop (Opus 4) for comprehensive project planning and architecture
- **Systematic Implementation**: Use Claude Code (Sonnet 4) for efficient, guided code implementation
- **Structured Handoff**: Version-controlled `.md` artifacts ensure seamless context transfer
- **Quality Assurance**: Built-in quality gates and verification at every stage

## 📁 Repository Structure

```
ai-dev-framework-template/
├── .github/                        # GitHub automation and templates
├── docs/                          # Framework documentation and templates
│   ├── templates/                 # Planning and development templates
│   ├── examples/                  # Real-world project examples
│   └── guides/                    # Usage guides and best practices
├── config/                        # Configuration templates
├── scripts/                       # Automation scripts
├── src/templates/                 # Code templates and patterns
├── tests/templates/               # Testing templates and patterns
├── CLAUDE.md                      # Master Claude Code configuration
└── package.template.json          # Dependency management template
```

## 🔄 Development Workflow

### **Phase 1: Planning (Claude Desktop - Opus 4)**
```
1. Use planning templates to create comprehensive project documentation
2. Generate PRD, architecture, and task breakdown
3. Commit planning documents to repository
```

### **Phase 2: Implementation (Claude Code - Sonnet 4)**
```
1. Navigate to project directory
2. Run: claude
3. Execute: "Read planning documents and implement following task sequence"
4. Follow systematic implementation with built-in quality gates
```

## 🚀 Quick Start

### **1. Create New Project from Template**
```bash
# Use this repository as a template
gh repo create my-new-project --template mxdruey/ai-dev-framework-template

# Or clone and customize
git clone https://github.com/mxdruey/ai-dev-framework-template.git my-project
cd my-project
./scripts/setup-project.sh
```

### **2. Project Planning (Claude Desktop)**
```
I want to build [describe your project].

Use the templates in /docs/templates/ to help me create comprehensive planning documents:
1. PRD with requirements and user stories
2. Technical architecture (if needed)
3. Task breakdown for implementation
4. Claude Code configuration

Optimize everything for Claude Code implementation.
```

### **3. Implementation (Claude Code)**
```bash
claude "Read the planning documents in /docs/ and implement this project following the systematic approach in CLAUDE.md"
```

## 📚 Framework Components

### **🧠 Planning Templates**
- **`docs/templates/create-prd.md`** - Product Requirements Document creation
- **`docs/templates/generate-tasks.md`** - Task breakdown methodology  
- **`docs/templates/architecture-template.md`** - Technical architecture planning
- **`docs/templates/agentic-ai-template.md`** - AI agent system specific guidance

### **💻 Implementation Templates**
- **Code Templates** - Pre-built patterns for common functionality
- **Test Templates** - Comprehensive testing approaches
- **Configuration Templates** - Development environment setup
- **Quality Gates** - Automated verification and standards

### **🤖 AI Agent Support**
- **Multi-agent Architecture** - Coordination patterns for AI agents
- **Tool Integration** - External tool integration templates
- **Memory Management** - Agent state and memory patterns
- **Safety Guidelines** - AI safety and ethical considerations

## 🎯 Project Types Supported

### **Simple Features** (< 1 week)
- Single functionality addition
- Minimal dependencies
- Streamlined documentation
- Basic quality gates

### **Medium Projects** (1-4 weeks)
- Multiple integrated features
- External service integration
- Comprehensive architecture
- Full testing strategy

### **Complex Applications** (> 1 month)
- Full-stack applications
- Enterprise-grade requirements
- Detailed architecture documentation
- Complete deployment strategy

### **Agentic AI Systems**
- Multi-agent coordination
- Tool integration patterns
- Memory and state management
- Safety and monitoring systems

## 💡 Benefits

### **🎯 Consistency**
- Standardized structure across all projects
- Proven patterns and best practices
- Quality gates built into every project

### **⚡ Speed**
- Rapid project initialization
- Pre-configured development environment
- Immediate Claude Code integration

### **🧠 AI-Optimized**
- Templates designed for AI assistance
- Optimal context transfer between planning and implementation
- Built-in verification against requirements

### **👥 Collaboration**
- Shared standards and documentation
- Clear handoff procedures
- Team coordination patterns

## 📖 Documentation

- **[Framework Guide](docs/guides/framework-guide.md)** - Complete usage instructions
- **[Best Practices](docs/guides/best-practices.md)** - Proven development patterns
- **[Examples](docs/examples/)** - Real-world implementation examples
- **[Troubleshooting](docs/guides/troubleshooting.md)** - Common issues and solutions

## 🔧 Configuration

### **Development Environment**
- Pre-configured linting and formatting
- Standardized testing setup
- Container-based development environment
- Claude Code optimization

### **Quality Assurance**
- Automated code quality checks
- Test coverage requirements
- Security scanning
- Performance benchmarks

## 🤝 Contributing

This template is designed to evolve with your development practices:

1. **Fork** this repository for your organization
2. **Customize** templates to match your standards
3. **Share** improvements back to the community
4. **Iterate** based on project learnings

## 📄 License

MIT License - feel free to use this template for any purpose.

---

**Ready to revolutionize your development workflow with AI assistance?**

Start by exploring the [Framework Guide](docs/guides/framework-guide.md) or dive into the [Examples](docs/examples/) to see the framework in action.

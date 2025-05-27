# Contributing to AI Development Framework Template

Thank you for your interest in contributing to the AI Development Framework! This document provides guidelines for contributing to make the framework better for everyone.

## 🎯 How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **🐛 Bug Reports**: Found an issue? Let us know!
2. **✨ Feature Requests**: Have an idea for improvement?
3. **📝 Documentation**: Help improve our guides and examples
4. **🔧 Templates**: Enhance existing templates or create new ones
5. **📋 Examples**: Add real-world project examples
6. **🛠️ Tools**: Improve setup scripts and automation

### Before You Start

1. **Check existing issues** to avoid duplicates
2. **Read the documentation** to understand the framework
3. **Try the framework** on a real project to understand it better
4. **Join discussions** if you have questions about direction

## 🚀 Getting Started

### Setting Up Your Development Environment

1. **Fork the repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/YOUR_USERNAME/ai-dev-framework-template.git
   cd ai-dev-framework-template
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Test the current framework**
   ```bash
   # Test the setup script
   ./scripts/setup-project.sh
   
   # Try creating a test project
   cd test-project
   # Follow the framework workflow
   ```

### Development Workflow

1. **Make your changes**
   - Follow existing patterns and conventions
   - Test changes with real projects when possible
   - Update documentation as needed

2. **Test your changes**
   ```bash
   # Run validation checks
   bash -n scripts/setup-project.sh  # Syntax check
   
   # Test template creation
   ./scripts/setup-project.sh
   
   # Validate JSON files
   node -e "JSON.parse(require('fs').readFileSync('package.template.json', 'utf8'))"
   ```

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new template for XYZ"
   # or
   git commit -m "fix: resolve issue with setup script"
   ```

4. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   # Then create PR via GitHub UI
   ```

## 📋 Contribution Guidelines

### Code Style

**Markdown Files**:
- Use clear, descriptive headings
- Include code examples where helpful
- Keep lines under 100 characters when possible
- Use consistent formatting

**Shell Scripts**:
- Use `#!/bin/bash` shebang
- Include error handling (`set -e`)
- Add comments for complex logic
- Use descriptive variable names

**JSON Templates**:
- Use 2-space indentation
- Include helpful comments where JSON supports them
- Validate JSON syntax

### Documentation Standards

**Template Files**:
```markdown
# Template Title

## Goal
Clear statement of what this template accomplishes

## When to Use
Specific scenarios where this template applies

## Process
Step-by-step instructions

## Examples
Concrete examples showing usage
```

**Guide Files**:
```markdown
# Guide Title

## Overview
Brief summary of what this guide covers

## Prerequisites
What users need to know/have before reading

## Step-by-Step Instructions
Detailed walkthrough with examples

## Troubleshooting
Common issues and solutions
```

### Commit Message Format

Use conventional commits format:

```
type(scope): brief description

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature or enhancement
- `fix`: Bug fix
- `docs`: Documentation changes
- `template`: Template improvements
- `example`: Example project changes
- `script`: Setup or utility script changes
- `ci`: CI/CD changes

**Examples**:
```
feat(templates): add agentic AI safety checklist
fix(setup): resolve Node.js version detection issue
docs(guides): improve troubleshooting section
template(complex): enhance microservices architecture guidance
```

## 🧪 Testing Your Contributions

### Manual Testing

1. **Template Changes**:
   ```bash
   # Test with Claude Desktop planning phase
   # Create a real PRD using your template
   # Verify it produces useful, actionable documents
   ```

2. **Configuration Changes**:
   ```bash
   # Test with Claude Code implementation phase
   # Use your CLAUDE.md configuration
   # Verify Claude Code produces good results
   ```

3. **Setup Script Changes**:
   ```bash
   # Test all project types
   ./scripts/setup-project.sh  # Simple
   ./scripts/setup-project.sh  # Medium  
   ./scripts/setup-project.sh  # Complex
   ./scripts/setup-project.sh  # Agentic AI
   ```

### Integration Testing

1. **End-to-End Workflow**:
   - Use your changes to plan a real project with Claude Desktop
   - Implement the project using Claude Code
   - Document any issues or improvements needed

2. **Cross-Platform Testing**:
   - Test on macOS, Linux, and Windows (if possible)
   - Verify scripts work in different shell environments
   - Check that paths and commands are portable

## 📝 Specific Contribution Types

### Adding New Templates

1. **Identify the Need**:
   - What specific use case does this address?
   - How does it differ from existing templates?
   - Which project types would benefit?

2. **Follow Template Structure**:
   ```markdown
   # Template Name
   
   ## Goal
   [Clear objective]
   
   ## When to Use
   [Specific scenarios]
   
   ## Process
   [Step-by-step instructions]
   
   ## Examples
   [Concrete examples]
   
   ## Integration with Claude Code
   [How this works with implementation]
   ```

3. **Test with Real Projects**:
   - Use the template to plan an actual project
   - Implement the project using Claude Code
   - Refine based on results

### Improving Examples

1. **Real-World Relevance**:
   - Examples should solve actual problems
   - Include common challenges and solutions
   - Show both successes and lessons learned

2. **Complete Documentation**:
   - Include all generated planning documents
   - Show Claude Code commands used
   - Document quality metrics achieved
   - Include lessons learned and improvements

3. **Variety of Scenarios**:
   - Different technologies and domains
   - Various team sizes and contexts
   - Simple through complex project types

### Enhancing Documentation

1. **User-Focused**:
   - Write for your intended audience
   - Include prerequisites and assumptions
   - Provide concrete examples
   - Test instructions with new users

2. **Keep Current**:
   - Update based on framework changes
   - Incorporate user feedback
   - Add new best practices learned
   - Remove outdated information

## 🔍 Review Process

### What We Look For

1. **Quality**:
   - Does this improve the framework?
   - Is it well-documented and tested?
   - Does it follow established patterns?

2. **Usability**:
   - Will this help users succeed with AI-assisted development?
   - Is it clear and easy to follow?
   - Does it work with both Claude Desktop and Claude Code?

3. **Completeness**:
   - Are examples realistic and helpful?
   - Is documentation comprehensive?
   - Are edge cases considered?

### Review Timeline

- **Initial Response**: Within 1-2 days
- **Detailed Review**: Within 1 week
- **Feedback Incorporation**: As needed
- **Merge**: After approval and CI checks pass

### Addressing Feedback

1. **Be Responsive**: Address feedback promptly
2. **Ask Questions**: If feedback is unclear, ask for clarification
3. **Test Changes**: Ensure fixes don't break other functionality
4. **Update Documentation**: Keep docs current with changes

## 🌟 Recognition

Contributors are recognized in several ways:

1. **GitHub Contributors**: Automatic recognition in repository
2. **Release Notes**: Significant contributions mentioned in releases
3. **Documentation**: Contributors credited in relevant sections
4. **Community**: Recognition in discussions and community spaces

## 📞 Getting Help

### Questions or Issues?

1. **Check Documentation**: Review existing guides and examples
2. **Search Issues**: Look for similar questions or problems
3. **Create an Issue**: Use issue templates for bug reports or feature requests
4. **Start a Discussion**: For general questions or ideas

### Community Guidelines

- **Be Respectful**: Treat everyone with courtesy and respect
- **Be Constructive**: Provide helpful, actionable feedback
- **Be Patient**: Reviews and responses take time
- **Be Collaborative**: Work together to improve the framework

## 🚦 Common Contribution Scenarios

### "I Found a Bug"

1. **Reproduce the Issue**: Can you consistently reproduce it?
2. **Check Existing Issues**: Has someone else reported this?
3. **Create Bug Report**: Use the bug report template
4. **Provide Details**: Include environment, steps, expected vs actual behavior

### "I Have an Idea for Improvement"

1. **Check Existing Features**: Is this already covered?
2. **Validate with Use Case**: Do you have a real scenario where this helps?
3. **Create Feature Request**: Use the feature request template
4. **Be Specific**: Describe exactly what you'd like to see

### "I Want to Add an Example"

1. **Choose a Real Project**: Use something you've actually built
2. **Document the Process**: Show planning → implementation → results
3. **Include Lessons Learned**: What worked well? What didn't?
4. **Make it Reusable**: Abstract patterns others can apply

### "I Want to Improve Documentation"

1. **Identify Pain Points**: Where do users struggle?
2. **Focus on Clarity**: Make complex topics understandable
3. **Add Examples**: Concrete examples clarify abstract concepts
4. **Test with Others**: Have someone else try your instructions

---

**Thank you for contributing to the AI Development Framework! Your efforts help developers worldwide build better software with AI assistance.** 🚀
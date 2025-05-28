#!/bin/bash
# AI Development Framework - Project Setup Script
# This script sets up a new project with the framework structure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Main setup function
setup_project() {
    print_header "AI Development Framework Setup"
    
    # Get project information
    read -p "Project name: " project_name
    read -p "Project description: " project_description
    
    echo ""
    echo "Select project type:"
    echo "1) Simple Feature (1-2 weeks)"
    echo "2) Medium Project (2-8 weeks)"
    echo "3) Complex Application (2-6 months)"
    echo "4) AI Agent System"
    read -p "Enter choice (1-4): " project_type
    
    # Create project directory
    mkdir -p "$project_name"
    cd "$project_name"
    
    print_header "Creating Project Structure"
    
    # Create directory structure
    mkdir -p src tests docs config scripts
    mkdir -p docs/{templates,planning,architecture}
    
    # Copy templates based on project type
    print_info "Setting up templates..."
    
    # Create basic package.json
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "$project_description",
  "main": "index.js",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src/**/*.ts"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "nodemon": "^3.0.0",
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
    
    # Create CLAUDE.md based on project type
    case $project_type in
        1) template="CLAUDE-simple.md" ;;
        2) template="CLAUDE-medium.md" ;;
        3) template="CLAUDE-complex.md" ;;
        4) template="CLAUDE-complex.md" ;;
    esac
    
    print_info "Downloading configuration template..."
    curl -s "https://raw.githubusercontent.com/mxdruey/ai-dev-framework-template/main/config/claude-config-templates/$template" > CLAUDE.md
    
    # Download planning templates
    print_info "Downloading planning templates..."
    templates=(
        "create-prd.md"
        "generate-tasks.md"
        "architecture-template.md"
    )
    
    for tmpl in "${templates[@]}"; do
        curl -s "https://raw.githubusercontent.com/mxdruey/ai-dev-framework-template/main/docs/templates/$tmpl" > "docs/templates/$tmpl"
    done
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
*.log

# Build
dist/
build/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Testing
coverage/
.nyc_output/
EOF
    
    # Create README.md
    cat > README.md << EOF
# $project_name

$project_description

## Project Structure

This project uses the AI Development Framework.

### Planning Documents
- \`docs/prd-*.md\` - Product Requirements Documents
- \`docs/architecture-*.md\` - Technical Architecture
- \`docs/tasks-*.md\` - Implementation Tasks

### Configuration
- \`CLAUDE.md\` - AI Assistant Configuration

## Getting Started

1. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

2. Run development server:
   \`\`\`bash
   npm run dev
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`
EOF
    
    # Initialize git
    git init
    git add .
    git commit -m "Initial project setup with AI Development Framework"
    
    print_success "Project setup complete!"
    
    print_header "Next Steps"
    echo "1. cd $project_name"
    echo "2. Open Claude Desktop and start planning:"
    echo "   - Create PRD using docs/templates/create-prd.md"
    echo "   - Design architecture using docs/templates/architecture-template.md"
    echo "   - Generate tasks using docs/templates/generate-tasks.md"
    echo "3. Use ./scripts/claude-handoff.sh when ready to implement"
    echo ""
    print_info "Happy coding! 🚀"
}

# Run setup
setup_project
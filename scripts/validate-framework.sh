#!/bin/bash
# AI Development Framework - Validation Script
# This script validates that a project follows the framework structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
errors=0
warnings=0

# Helper functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((warnings++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((errors++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if file exists
check_file() {
    if [[ -f "$1" ]]; then
        print_success "$1 exists"
        return 0
    else
        print_error "$1 is missing"
        return 1
    fi
}

# Check if directory exists
check_directory() {
    if [[ -d "$1" ]]; then
        print_success "$1 directory exists"
        return 0
    else
        print_error "$1 directory is missing"
        return 1
    fi
}

# Check for planning documents
check_planning_docs() {
    print_header "Checking Planning Documents"
    
    local has_prd=false
    local has_tasks=false
    local has_architecture=false
    
    # Check for PRD
    if ls docs/prd-*.md 1> /dev/null 2>&1; then
        print_success "PRD document(s) found"
        has_prd=true
    else
        print_warning "No PRD documents found (docs/prd-*.md)"
    fi
    
    # Check for tasks
    if ls docs/tasks-*.md 1> /dev/null 2>&1; then
        print_success "Task document(s) found"
        has_tasks=true
    else
        print_warning "No task documents found (docs/tasks-*.md)"
    fi
    
    # Check for architecture
    if ls docs/architecture-*.md 1> /dev/null 2>&1; then
        print_success "Architecture document(s) found"
        has_architecture=true
    else
        print_warning "No architecture documents found (docs/architecture-*.md)"
    fi
    
    # Check templates
    check_file "docs/templates/create-prd.md"
    check_file "docs/templates/generate-tasks.md"
    check_file "docs/templates/architecture-template.md"
}

# Check cloud portability
check_cloud_portability() {
    print_header "Checking Cloud Portability"
    
    # Check Docker files
    if [[ -f "docker-compose.yml" ]]; then
        print_success "docker-compose.yml exists"
        
        # Check if it includes LocalStack
        if grep -q "localstack" docker-compose.yml; then
            print_success "LocalStack configured for local AWS services"
        else
            print_warning "LocalStack not configured in docker-compose.yml"
        fi
    else
        print_warning "docker-compose.yml not found"
    fi
    
    # Check infrastructure directory
    if [[ -d "infrastructure" ]]; then
        print_success "Infrastructure directory exists"
        
        # Check for Terraform or CloudFormation
        if [[ -d "infrastructure/terraform" ]] || [[ -d "infrastructure/cloudformation" ]]; then
            print_success "Infrastructure as Code configured"
        else
            print_warning "No Terraform or CloudFormation templates found"
        fi
        
        # Check for Dockerfile
        if ls infrastructure/docker/Dockerfile* 1> /dev/null 2>&1; then
            print_success "Dockerfile(s) found"
        else
            print_warning "No Dockerfile found in infrastructure/docker/"
        fi
    else
        print_info "No infrastructure directory (OK for simple projects)"
    fi
}

# Check configuration
check_configuration() {
    print_header "Checking Configuration"
    
    # Check CLAUDE.md
    check_file "CLAUDE.md"
    
    # Check environment template
    if [[ -f ".env.example" ]]; then
        print_success ".env.example exists"
    else
        print_warning ".env.example not found"
    fi
    
    # Check if .env is git-ignored
    if [[ -f ".gitignore" ]]; then
        if grep -q "^\.env$" .gitignore; then
            print_success ".env is git-ignored"
        else
            print_error ".env is NOT git-ignored (security risk!)"
        fi
    else
        print_error ".gitignore is missing"
    fi
}

# Check project structure
check_structure() {
    print_header "Checking Project Structure"
    
    # Check essential directories
    check_directory "src"
    check_directory "tests"
    check_directory "docs"
    check_directory "scripts"
    
    # Check for package.json or equivalent
    if [[ -f "package.json" ]]; then
        print_success "package.json exists (Node.js project)"
    elif [[ -f "requirements.txt" ]]; then
        print_success "requirements.txt exists (Python project)"
    elif [[ -f "go.mod" ]]; then
        print_success "go.mod exists (Go project)"
    else
        print_warning "No recognized project configuration file found"
    fi
}

# Check scripts
check_scripts() {
    print_header "Checking Scripts"
    
    # Check for handoff script
    if [[ -f "scripts/claude-handoff.sh" ]]; then
        print_success "claude-handoff.sh exists"
        if [[ -x "scripts/claude-handoff.sh" ]]; then
            print_success "claude-handoff.sh is executable"
        else
            print_warning "claude-handoff.sh is not executable (run: chmod +x scripts/claude-handoff.sh)"
        fi
    else
        print_info "claude-handoff.sh not found (download from framework repo)"
    fi
}

# Main validation
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          AI Development Framework Validation Tool              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if in a project directory
    if [[ ! -f "CLAUDE.md" ]] && [[ ! -f "package.json" ]] && [[ ! -f "requirements.txt" ]]; then
        print_error "This doesn't appear to be a project directory"
        print_info "Run this script from your project root"
        exit 1
    fi
    
    # Run all checks
    check_structure
    check_configuration
    check_planning_docs
    check_cloud_portability
    check_scripts
    
    # Summary
    echo ""
    print_header "Validation Summary"
    
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            print_success "Perfect! Your project follows the framework perfectly."
        else
            print_success "Good! Your project follows the framework with $warnings warning(s)."
        fi
    else
        print_error "Found $errors error(s) and $warnings warning(s)"
        print_info "Fix the errors to ensure framework compatibility"
    fi
    
    # Generate report
    cat > validation-report.md << EOF
# Framework Validation Report

Date: $(date)

## Summary
- Errors: $errors
- Warnings: $warnings

## Details
See console output above for detailed validation results.

## Recommendations
EOF
    
    if [[ $errors -gt 0 ]] || [[ $warnings -gt 0 ]]; then
        echo "1. Fix all errors before proceeding" >> validation-report.md
        echo "2. Consider addressing warnings for better framework compliance" >> validation-report.md
    else
        echo "Your project is framework-compliant! 🎉" >> validation-report.md
    fi
    
    print_info "Validation report saved to validation-report.md"
    
    # Exit with error code if errors found
    exit $errors
}

# Run validation
main "$@"
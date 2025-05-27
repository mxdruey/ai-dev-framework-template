#!/bin/bash

# AI Development Framework - Quality Check Script
# This script runs quality checks before committing code

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Quality check results
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNING_CHECKS++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED_CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run tests
run_tests() {
    print_header "Running Tests"
    
    if [[ -f "package.json" ]] && command_exists npm; then
        if grep -q '"test"' package.json; then
            print_info "Running npm tests..."
            if npm test; then
                print_success "All tests passed"
            else
                print_error "Tests failed"
            fi
        else
            print_warning "No test script found in package.json"
        fi
    elif [[ -f "requirements.txt" ]] && command_exists python; then
        if command_exists pytest; then
            print_info "Running pytest..."
            if pytest; then
                print_success "All tests passed"
            else
                print_error "Tests failed"
            fi
        else
            print_warning "pytest not installed"
        fi
    else
        print_warning "No test runner detected"
    fi
}

# Check code formatting
check_formatting() {
    print_header "Checking Code Formatting"
    
    # JavaScript/TypeScript formatting
    if [[ -f "package.json" ]] && command_exists npm; then
        if grep -q '"prettier"' package.json || [[ -f ".prettierrc" ]]; then
            print_info "Checking Prettier formatting..."
            if npx prettier --check "src/**/*.{js,jsx,ts,tsx}" 2>/dev/null; then
                print_success "Code formatting is correct"
            else
                print_error "Code formatting issues found"
                print_info "Run 'npm run format' to fix"
            fi
        fi
    fi
    
    # Python formatting
    if [[ -f "requirements.txt" ]] && command_exists black; then
        print_info "Checking Black formatting..."
        if black --check .; then
            print_success "Python formatting is correct"
        else
            print_error "Python formatting issues found"
            print_info "Run 'black .' to fix"
        fi
    fi
}

# Run linting
run_linting() {
    print_header "Running Linters"
    
    # JavaScript/TypeScript linting
    if [[ -f "package.json" ]] && command_exists npm; then
        if grep -q '"eslint"' package.json || [[ -f ".eslintrc.js" ]]; then
            print_info "Running ESLint..."
            if npx eslint "src/**/*.{js,jsx,ts,tsx}" 2>/dev/null; then
                print_success "No linting errors found"
            else
                print_error "Linting errors found"
            fi
        fi
    fi
    
    # Python linting
    if [[ -f "requirements.txt" ]] && command_exists pylint; then
        print_info "Running pylint..."
        if find . -name "*.py" -not -path "./venv/*" -exec pylint {} + ; then
            print_success "No Python linting errors"
        else
            print_warning "Python linting warnings found"
        fi
    fi
}

# Check test coverage
check_coverage() {
    print_header "Checking Test Coverage"
    
    if [[ -f "package.json" ]] && grep -q '"test:coverage"' package.json; then
        print_info "Running coverage check..."
        if npm run test:coverage; then
            print_success "Coverage check passed"
        else
            print_warning "Coverage below threshold"
        fi
    else
        print_warning "No coverage check configured"
    fi
}

# Security audit
security_audit() {
    print_header "Security Audit"
    
    # npm audit
    if [[ -f "package-lock.json" ]] && command_exists npm; then
        print_info "Running npm audit..."
        audit_result=$(npm audit --json 2>/dev/null || true)
        vulnerabilities=$(echo "$audit_result" | grep -o '"total":[0-9]*' | cut -d':' -f2 || echo "0")
        
        if [[ "$vulnerabilities" -eq 0 ]]; then
            print_success "No security vulnerabilities found"
        else
            print_error "Found $vulnerabilities security vulnerabilities"
            print_info "Run 'npm audit fix' to fix"
        fi
    fi
    
    # Python safety check
    if [[ -f "requirements.txt" ]] && command_exists safety; then
        print_info "Running safety check..."
        if safety check; then
            print_success "No known security vulnerabilities"
        else
            print_error "Security vulnerabilities found in dependencies"
        fi
    fi
}

# Check documentation
check_documentation() {
    print_header "Checking Documentation"
    
    # Check README exists
    if [[ -f "README.md" ]]; then
        print_success "README.md exists"
        
        # Check README content
        if grep -q "## Installation" README.md || grep -q "## Getting Started" README.md; then
            print_success "README has installation instructions"
        else
            print_warning "README missing installation instructions"
        fi
    else
        print_error "README.md not found"
    fi
    
    # Check CLAUDE.md exists
    if [[ -f "CLAUDE.md" ]]; then
        print_success "CLAUDE.md exists"
    else
        print_warning "CLAUDE.md not found"
    fi
    
    # Check for API documentation
    if [[ -d "docs" ]]; then
        doc_count=$(find docs -name "*.md" | wc -l)
        if [[ $doc_count -gt 0 ]]; then
            print_success "Found $doc_count documentation files"
        else
            print_warning "docs/ directory is empty"
        fi
    fi
}

# Check for uncommitted changes
check_git_status() {
    print_header "Git Status"
    
    if [[ -d ".git" ]]; then
        # Check for uncommitted changes
        if [[ -n $(git status --porcelain) ]]; then
            print_warning "Uncommitted changes found"
            print_info "Files with changes:"
            git status --short
        else
            print_success "Working directory clean"
        fi
        
        # Check if on feature branch
        current_branch=$(git branch --show-current)
        if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
            print_warning "On $current_branch branch - consider using feature branch"
        else
            print_success "On feature branch: $current_branch"
        fi
    else
        print_warning "Not a git repository"
    fi
}

# Type checking
run_type_check() {
    print_header "Type Checking"
    
    # TypeScript
    if [[ -f "tsconfig.json" ]] && command_exists npx; then
        print_info "Running TypeScript type check..."
        if npx tsc --noEmit; then
            print_success "No TypeScript errors found"
        else
            print_error "TypeScript errors found"
        fi
    fi
    
    # Python type checking
    if command_exists mypy && [[ -f "requirements.txt" ]]; then
        print_info "Running mypy type check..."
        if find . -name "*.py" -not -path "./venv/*" | xargs mypy 2>/dev/null; then
            print_success "No Python type errors found"
        else
            print_warning "Python type errors found"
        fi
    fi
}

# Check for TODOs and FIXMEs
check_todos() {
    print_header "Checking TODOs and FIXMEs"
    
    todo_count=$(grep -r "TODO\|FIXME" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" . 2>/dev/null | wc -l || echo "0")
    
    if [[ $todo_count -eq 0 ]]; then
        print_success "No TODOs or FIXMEs found"
    else
        print_warning "Found $todo_count TODOs/FIXMEs"
        print_info "Consider addressing these before committing:"
        grep -r "TODO\|FIXME" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" . 2>/dev/null | head -5 || true
        if [[ $todo_count -gt 5 ]]; then
            print_info "... and $(($todo_count - 5)) more"
        fi
    fi
}

# Generate quality report
generate_report() {
    print_header "Quality Check Summary"
    
    total_checks=$((PASSED_CHECKS + FAILED_CHECKS + WARNING_CHECKS))
    
    echo -e "\n${BLUE}Quality Check Report${NC}"
    echo "=============================="
    echo -e "Total Checks: ${total_checks}"
    echo -e "${GREEN}Passed: ${PASSED_CHECKS}${NC}"
    echo -e "${YELLOW}Warnings: ${WARNING_CHECKS}${NC}"
    echo -e "${RED}Failed: ${FAILED_CHECKS}${NC}"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        if [[ $WARNING_CHECKS -eq 0 ]]; then
            echo -e "${GREEN}✓ All quality checks passed! Ready to commit.${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Quality checks passed with warnings.${NC}"
            echo -e "${YELLOW}Consider addressing warnings before committing.${NC}"
            return 0
        fi
    else
        echo -e "${RED}✗ Quality checks failed!${NC}"
        echo -e "${RED}Please fix errors before committing.${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               AI Development Framework                         ║"
    echo "║                  Quality Check Script                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Run all checks
    run_tests
    check_formatting
    run_linting
    run_type_check
    check_coverage
    security_audit
    check_documentation
    check_todos
    check_git_status
    
    # Generate summary report
    generate_report
}

# Run main function
main "$@"
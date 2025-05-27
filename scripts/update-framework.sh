#!/bin/bash

# AI Development Framework - Update Script
# This script updates existing projects when the framework evolves

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

# Framework repository URL
FRAMEWORK_REPO="https://github.com/mxdruey/ai-dev-framework-template.git"
FRAMEWORK_DIR="/tmp/ai-dev-framework-latest"

# Check if in a project directory
check_project() {
    if [[ ! -f "CLAUDE.md" ]]; then
        print_error "CLAUDE.md not found. Are you in a project directory?"
        exit 1
    fi
    
    if [[ ! -f "package.json" ]] && [[ ! -f "requirements.txt" ]] && [[ ! -f "go.mod" ]]; then
        print_warning "No recognized project files found."
    fi
}

# Download latest framework
download_framework() {
    print_header "Downloading Latest Framework"
    
    # Clean up old download
    rm -rf "$FRAMEWORK_DIR"
    
    # Clone latest version
    if git clone --quiet "$FRAMEWORK_REPO" "$FRAMEWORK_DIR"; then
        print_success "Downloaded latest framework"
    else
        print_error "Failed to download framework"
        exit 1
    fi
}

# Compare framework versions
check_version() {
    print_header "Checking Framework Version"
    
    # Check if .framework-version exists
    if [[ -f ".framework-version" ]]; then
        current_version=$(cat .framework-version)
        print_info "Current framework version: $current_version"
    else
        print_warning "No framework version found. This might be an older project."
        current_version="unknown"
    fi
    
    # Get latest version from framework
    if [[ -f "$FRAMEWORK_DIR/VERSION" ]]; then
        latest_version=$(cat "$FRAMEWORK_DIR/VERSION")
        print_info "Latest framework version: $latest_version"
    else
        latest_version="1.0.0"
        print_warning "No version file in framework. Assuming 1.0.0"
    fi
    
    echo "$latest_version" > .framework-version-new
}

# Update templates
update_templates() {
    print_header "Updating Templates"
    
    templates_updated=0
    
    # Update planning templates if they exist
    if [[ -d "docs/templates" ]]; then
        print_info "Updating planning templates..."
        
        for template in "$FRAMEWORK_DIR"/docs/templates/*.md; do
            filename=$(basename "$template")
            if [[ -f "docs/templates/$filename" ]]; then
                if ! diff -q "$template" "docs/templates/$filename" > /dev/null; then
                    cp "$template" "docs/templates/$filename"
                    print_success "Updated $filename"
                    ((templates_updated++))
                fi
            fi
        done
    fi
    
    # Update code templates if they exist
    if [[ -d "src/templates" ]]; then
        print_info "Updating code templates..."
        
        if [[ -d "$FRAMEWORK_DIR/src/templates" ]]; then
            rsync -av --quiet "$FRAMEWORK_DIR/src/templates/" "src/templates/"
            print_success "Updated code templates"
            ((templates_updated++))
        fi
    fi
    
    if [[ $templates_updated -eq 0 ]]; then
        print_info "All templates are up to date"
    else
        print_success "Updated $templates_updated template(s)"
    fi
}

# Update scripts
update_scripts() {
    print_header "Updating Scripts"
    
    scripts_updated=0
    
    # Update validation script
    if [[ -f "$FRAMEWORK_DIR/scripts/validate-framework.sh" ]]; then
        if [[ ! -f "scripts/validate-framework.sh" ]] || ! diff -q "$FRAMEWORK_DIR/scripts/validate-framework.sh" "scripts/validate-framework.sh" > /dev/null; then
            cp "$FRAMEWORK_DIR/scripts/validate-framework.sh" "scripts/validate-framework.sh"
            chmod +x "scripts/validate-framework.sh"
            print_success "Updated validate-framework.sh"
            ((scripts_updated++))
        fi
    fi
    
    # Update quality check script
    if [[ -f "$FRAMEWORK_DIR/scripts/quality-check.sh" ]]; then
        if [[ ! -f "scripts/quality-check.sh" ]] || ! diff -q "$FRAMEWORK_DIR/scripts/quality-check.sh" "scripts/quality-check.sh" > /dev/null; then
            cp "$FRAMEWORK_DIR/scripts/quality-check.sh" "scripts/quality-check.sh"
            chmod +x "scripts/quality-check.sh"
            print_success "Updated quality-check.sh"
            ((scripts_updated++))
        fi
    fi
    
    # Update handoff script
    if [[ -f "$FRAMEWORK_DIR/scripts/claude-handoff.sh" ]]; then
        if [[ ! -f "scripts/claude-handoff.sh" ]] || ! diff -q "$FRAMEWORK_DIR/scripts/claude-handoff.sh" "scripts/claude-handoff.sh" > /dev/null; then
            cp "$FRAMEWORK_DIR/scripts/claude-handoff.sh" "scripts/claude-handoff.sh"
            chmod +x "scripts/claude-handoff.sh"
            print_success "Updated claude-handoff.sh"
            ((scripts_updated++))
        fi
    fi
    
    if [[ $scripts_updated -eq 0 ]]; then
        print_info "All scripts are up to date"
    else
        print_success "Updated $scripts_updated script(s)"
    fi
}

# Update GitHub templates
update_github_templates() {
    print_header "Updating GitHub Templates"
    
    if [[ ! -d ".github" ]]; then
        print_info "No .github directory found. Skipping GitHub templates."
        return
    fi
    
    templates_updated=0
    
    # Update issue templates
    if [[ -d "$FRAMEWORK_DIR/.github/ISSUE_TEMPLATE" ]]; then
        mkdir -p ".github/ISSUE_TEMPLATE"
        for template in "$FRAMEWORK_DIR"/.github/ISSUE_TEMPLATE/*.md; do
            filename=$(basename "$template")
            cp "$template" ".github/ISSUE_TEMPLATE/$filename"
            ((templates_updated++))
        done
    fi
    
    # Update PR template
    if [[ -f "$FRAMEWORK_DIR/.github/PULL_REQUEST_TEMPLATE.md" ]]; then
        cp "$FRAMEWORK_DIR/.github/PULL_REQUEST_TEMPLATE.md" ".github/"
        ((templates_updated++))
    fi
    
    # Update workflows
    if [[ -d "$FRAMEWORK_DIR/.github/workflows" ]]; then
        mkdir -p ".github/workflows"
        for workflow in "$FRAMEWORK_DIR"/.github/workflows/*.yml; do
            filename=$(basename "$workflow")
            if [[ "$filename" != "template-validation.yml" ]]; then  # Skip framework-specific workflow
                cp "$workflow" ".github/workflows/$filename"
                ((templates_updated++))
            fi
        done
    fi
    
    if [[ $templates_updated -gt 0 ]]; then
        print_success "Updated $templates_updated GitHub template(s)"
    fi
}

# Update configuration files
update_configs() {
    print_header "Updating Configuration Files"
    
    # Update .editorconfig if it exists in framework
    if [[ -f "$FRAMEWORK_DIR/.editorconfig" ]] && [[ ! -f ".editorconfig" ]]; then
        cp "$FRAMEWORK_DIR/.editorconfig" .
        print_success "Added .editorconfig"
    fi
    
    # Update .gitignore entries
    if [[ -f "$FRAMEWORK_DIR/.gitignore" ]] && [[ -f ".gitignore" ]]; then
        # Add framework-specific entries if not present
        framework_entries=$(grep -E "^(validation-report|\.framework-version)" "$FRAMEWORK_DIR/.gitignore" || true)
        if [[ -n "$framework_entries" ]]; then
            echo "" >> .gitignore
            echo "# Framework specific" >> .gitignore
            echo "$framework_entries" >> .gitignore
            print_success "Updated .gitignore with framework entries"
        fi
    fi
}

# Show changelog
show_changelog() {
    print_header "Framework Changes"
    
    if [[ -f "$FRAMEWORK_DIR/CHANGELOG.md" ]]; then
        # Show recent changes
        print_info "Recent framework updates:"
        head -n 30 "$FRAMEWORK_DIR/CHANGELOG.md" | grep -E "^(##|###|-)" || true
    fi
}

# Main update process
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║            AI Development Framework Update Script              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Check if in project directory
    check_project
    
    # Download latest framework
    download_framework
    
    # Check versions
    check_version
    
    # Show what will be updated
    print_header "Update Plan"
    echo "The following components will be checked for updates:"
    echo "  - Planning templates"
    echo "  - Code templates"
    echo "  - Utility scripts"
    echo "  - GitHub templates"
    echo "  - Configuration files"
    echo ""
    
    read -p "Do you want to proceed with the update? (y/N) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Update cancelled"
        exit 0
    fi
    
    # Perform updates
    update_templates
    update_scripts
    update_github_templates
    update_configs
    
    # Update version file
    if [[ -f ".framework-version-new" ]]; then
        mv .framework-version-new .framework-version
        print_success "Updated framework version"
    fi
    
    # Show changelog
    show_changelog
    
    # Clean up
    rm -rf "$FRAMEWORK_DIR"
    
    print_header "Update Complete"
    print_success "Framework update completed successfully!"
    print_info "Run './scripts/validate-framework.sh' to verify your project structure"
}

# Run main function
main "$@"
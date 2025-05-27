#!/bin/bash

# AI Development Framework - Claude Handoff Script
# This script automates the handoff from planning to implementation

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

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if Claude Code is installed
    if ! command -v claude &> /dev/null; then
        print_error "Claude Code is not installed or not in PATH"
        print_info "Please install Claude Code from: https://claude.ai/code"
        exit 1
    fi
    print_success "Claude Code is installed"
    
    # Check if we're in a project directory
    if [[ ! -f "CLAUDE.md" ]]; then
        print_error "CLAUDE.md not found. Are you in a project directory?"
        exit 1
    fi
    print_success "CLAUDE.md found"
    
    # Check for planning documents
    if [[ ! -d "docs" ]]; then
        print_error "docs/ directory not found"
        exit 1
    fi
    
    # Count planning documents
    prd_count=$(find docs -name "prd-*.md" | wc -l)
    task_count=$(find docs -name "tasks-*.md" | wc -l)
    
    if [[ $prd_count -eq 0 ]]; then
        print_warning "No PRD documents found (prd-*.md)"
    else
        print_success "Found $prd_count PRD document(s)"
    fi
    
    if [[ $task_count -eq 0 ]]; then
        print_warning "No task documents found (tasks-*.md)"
    else
        print_success "Found $task_count task document(s)"
    fi
}

# Prepare handoff summary
prepare_handoff() {
    print_header "Preparing Handoff Summary"
    
    # Create temporary handoff file
    handoff_file=".claude-handoff-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$handoff_file" << EOF
# Claude Code Implementation Handoff

## Project Context

This project has been planned using the AI Development Framework. Please review the following documents before implementation:

## Planning Documents

EOF

    # Add PRD documents
    if compgen -G "docs/prd-*.md" > /dev/null; then
        echo "### Product Requirements Documents" >> "$handoff_file"
        for prd in docs/prd-*.md; do
            echo "- [$prd]($prd)" >> "$handoff_file"
        done
        echo "" >> "$handoff_file"
    fi
    
    # Add task documents
    if compgen -G "docs/tasks-*.md" > /dev/null; then
        echo "### Task Breakdown Documents" >> "$handoff_file"
        for tasks in docs/tasks-*.md; do
            echo "- [$tasks]($tasks)" >> "$handoff_file"
        done
        echo "" >> "$handoff_file"
    fi
    
    # Add architecture documents
    if compgen -G "docs/architecture-*.md" > /dev/null; then
        echo "### Architecture Documents" >> "$handoff_file"
        for arch in docs/architecture-*.md; do
            echo "- [$arch]($arch)" >> "$handoff_file"
        done
        echo "" >> "$handoff_file"
    fi
    
    # Add implementation instructions
    cat >> "$handoff_file" << EOF
## Implementation Instructions

1. **Review all planning documents** listed above
2. **Follow the task sequence** in the task breakdown documents
3. **Adhere to the standards** defined in CLAUDE.md
4. **Use quality gates** to verify progress at each phase

## Recommended First Command

\`\`\`bash
claude "Read all planning documents in /docs/ and begin implementation following the task sequence. Start with the first task in the implementation plan."
\`\`\`

## Quality Reminders

- Write tests for all business logic
- Follow the coding standards in CLAUDE.md
- Update documentation as you implement
- Commit frequently with clear messages
- Verify against PRD requirements regularly

EOF

    print_success "Created handoff summary: $handoff_file"
    echo "$handoff_file"
}

# Display implementation commands
show_claude_commands() {
    print_header "Claude Code Commands"
    
    echo -e "\n${BLUE}Recommended implementation commands:${NC}\n"
    
    echo "1. Start implementation:"
    echo -e "   ${GREEN}claude \"Read all planning documents in /docs/ and begin implementation following the task sequence\"${NC}\n"
    
    echo "2. Continue implementation:"
    echo -e "   ${GREEN}claude --continue \"Proceed with the next task in the implementation plan\"${NC}\n"
    
    echo "3. Review progress:"
    echo -e "   ${GREEN}claude \"Review completed tasks against PRD requirements and summarize progress\"${NC}\n"
    
    echo "4. Run tests:"
    echo -e "   ${GREEN}claude \"Run all tests and fix any failing tests\"${NC}\n"
    
    echo "5. Final verification:"
    echo -e "   ${GREEN}claude \"Verify all PRD requirements are met and all quality gates have passed\"${NC}\n"
}

# Interactive mode
interactive_mode() {
    print_header "Interactive Handoff Mode"
    
    echo -e "\nWould you like to:\n"
    echo "1) Start Claude Code with automatic context loading"
    echo "2) Copy recommended commands to clipboard"
    echo "3) View handoff summary"
    echo "4) Exit"
    
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            print_info "Starting Claude Code..."
            claude
            ;;
        2)
            if command -v pbcopy &> /dev/null; then
                echo "claude \"Read all planning documents in /docs/ and begin implementation following the task sequence\"" | pbcopy
                print_success "Command copied to clipboard!"
            elif command -v xclip &> /dev/null; then
                echo "claude \"Read all planning documents in /docs/ and begin implementation following the task sequence\"" | xclip -selection clipboard
                print_success "Command copied to clipboard!"
            else
                print_warning "Clipboard not available. Here's the command:"
                echo "claude \"Read all planning documents in /docs/ and begin implementation following the task sequence\""
            fi
            ;;
        3)
            if [[ -f "$handoff_file" ]]; then
                cat "$handoff_file"
            else
                print_error "Handoff file not found"
            fi
            ;;
        4)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               AI Development Framework                         ║"
    echo "║                 Claude Handoff Script                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    check_prerequisites
    
    handoff_file=$(prepare_handoff)
    
    show_claude_commands
    
    # Check if running interactively
    if [[ -t 0 ]]; then
        interactive_mode
    fi
    
    print_success "Handoff preparation complete!"
    print_info "You can now start Claude Code and begin implementation."
}

# Run main function
main "$@"
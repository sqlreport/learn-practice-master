#!/bin/bash

# Git Secret Management Script
# This script helps manage encrypted environment variables using git-secret

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  reveal         Decrypt secret files from .secret versions"
    echo "  hide           Encrypt secret files (creates .secret versions)"
    echo "  edit           Edit encrypted files (decrypt, edit, encrypt)"
    echo "  load-dev       Load development environment"
    echo "  load-prod      Load production environment"
    echo "  status         Show git-secret status"
    echo "  help           Show this help message"
    echo ""
    echo "Options:"
    echo "  -f, --force    Force operation (use with hide)"
    echo ""
    echo "Examples:"
    echo "  $0 reveal      # Decrypt all secret files"
    echo "  $0 hide        # Encrypt all secret files"
    echo "  $0 load-dev    # Load development environment"
    echo "  $0 edit .env.production  # Edit production secrets"
}

# Function to check if git-secret is initialized
check_git_secret() {
    if [ ! -d ".gitsecret" ]; then
        print_error "Git-secret not initialized. Run 'git secret init' first."
        exit 1
    fi
}

# Function to reveal secrets
reveal_secrets() {
    print_status "Revealing encrypted secrets..."
    check_git_secret
    
    if git secret reveal; then
        print_status "Secrets revealed successfully!"
        print_warning "Remember: Do not commit the decrypted files!"
    else
        print_error "Failed to reveal secrets. Check your GPG key."
        exit 1
    fi
}

# Function to hide secrets
hide_secrets() {
    print_status "Encrypting secrets..."
    check_git_secret
    
    local force_flag=""
    if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
        force_flag="-f"
        print_warning "Force flag enabled - will overwrite existing encrypted files"
    fi
    
    if git secret hide $force_flag; then
        print_status "Secrets encrypted successfully!"
        print_info "Encrypted files (.secret) can be safely committed to git"
    else
        print_error "Failed to encrypt secrets"
        exit 1
    fi
}

# Function to edit secrets
edit_secrets() {
    local file="$1"
    if [ -z "$file" ]; then
        print_error "Please specify a file to edit"
        echo "Available secret files:"
        git secret list 2>/dev/null || echo "No secret files configured"
        exit 1
    fi
    
    print_status "Editing encrypted file: $file"
    check_git_secret
    
    # Reveal first
    git secret reveal
    
    # Edit the file
    ${EDITOR:-nano} "$file"
    
    # Ask if user wants to encrypt again
    echo ""
    read -p "Encrypt the changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git secret hide -f
        print_status "File encrypted successfully!"
    else
        print_warning "File left unencrypted. Remember to run 'hide' later!"
    fi
}

# Function to load development environment
load_dev_env() {
    print_status "Loading development environment..."
    check_git_secret
    
    # Reveal secrets first
    if [ ! -f ".env.development" ]; then
        print_info "Revealing secrets to access development environment..."
        git secret reveal
    fi
    
    if [ -f ".env.development" ]; then
        print_status "Development environment available"
        print_info "To start development environment:"
        echo "  docker-compose -f docker-compose.app.dev.yml --env-file .env.development up -d"
    else
        print_error "Development environment file not found"
        exit 1
    fi
}

# Function to load production environment
load_prod_env() {
    print_status "Loading production environment..."
    check_git_secret
    
    # Reveal secrets first
    if [ ! -f ".env.production" ]; then
        print_info "Revealing secrets to access production environment..."
        git secret reveal
    fi
    
    if [ -f ".env.production" ]; then
        print_status "Production environment available"
        print_warning "Make sure to review and update production secrets before deployment!"
        print_info "To start production environment:"
        echo "  docker-compose -f docker-compose.app.yml --env-file .env.production up -d"
    else
        print_error "Production environment file not found"
        exit 1
    fi
}

# Function to show git-secret status
show_status() {
    print_status "Git-secret status:"
    check_git_secret
    
    echo ""
    print_info "Secret files:"
    git secret list 2>/dev/null || echo "No secret files configured"
    
    echo ""
    print_info "Authorized users:"
    git secret whoknows 2>/dev/null || echo "No users configured"
    
    echo ""
    print_info "Encrypted files status:"
    for file in $(git secret list 2>/dev/null); do
        if [ -f "${file}.secret" ]; then
            echo "  ✓ ${file}.secret (encrypted)"
        else
            echo "  ✗ ${file}.secret (missing)"
        fi
        
        if [ -f "$file" ]; then
            echo "  ⚠ $file (decrypted - do not commit!)"
        fi
    done
}

# Main script logic
case "$1" in
    "reveal")
        reveal_secrets
        ;;
    "hide")
        hide_secrets "$2"
        ;;
    "edit")
        edit_secrets "$2"
        ;;
    "load-dev")
        load_dev_env
        ;;
    "load-prod")
        load_prod_env
        ;;
    "status")
        show_status
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    "")
        print_error "No command specified"
        echo ""
        show_usage
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
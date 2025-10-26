#!/bin/bash

# Development Workflow Script
# This script provides convenient commands for development with secret management

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

show_usage() {
    echo "Development Workflow Script"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup-dev       Set up development environment"
    echo "  start-dev       Start development services"
    echo "  stop-dev        Stop development services"
    echo "  setup-prod      Set up production environment"
    echo "  start-prod      Start production services"
    echo "  stop-prod       Stop production services"
    echo "  clean           Clean up decrypted files and containers"
    echo "  help            Show this help message"
}

setup_dev() {
    print_status "Setting up development environment..."
    
    # Reveal secrets
    ./scripts/secrets-manage.sh reveal
    
    # Build frontend
    print_info "Building frontend..."
    cd frontend
    npm install
    npm run build
    cd ..
    
    print_status "Development environment ready!"
    print_info "Next steps:"
    echo "  ./dev-workflow.sh start-dev"
}

start_dev() {
    print_status "Starting development services..."
    
    # Check if secrets are decrypted
    if [ ! -f ".env.development" ]; then
        print_info "Decrypting secrets first..."
        ./scripts/secrets-manage.sh reveal
    fi
    
    # Start development services
    docker-compose -f docker-compose.app.dev.yml --env-file .env.development up -d
    
    print_status "Development services started!"
    print_info "Services available at:"
    echo "  - Application: http://localhost"
    echo "  - API: http://localhost:5000"
    echo "  - Database: localhost:5432"
    echo "  - pgAdmin: http://localhost:8080"
}

stop_dev() {
    print_status "Stopping development services..."
    docker-compose -f docker-compose.app.dev.yml down
    print_status "Development services stopped!"
}

setup_prod() {
    print_status "Setting up production environment..."
    
    # Reveal secrets
    ./scripts/secrets-manage.sh reveal
    
    print_warning "IMPORTANT: Review and update production secrets!"
    print_info "Edit production secrets with:"
    echo "  ./scripts/secrets-manage.sh edit .env.production"
    
    read -p "Have you updated production secrets? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Please update production secrets before starting services"
        return 1
    fi
    
    # Build frontend for production
    print_info "Building frontend for production..."
    cd frontend
    npm install
    npm run build
    cd ..
    
    print_status "Production environment ready!"
}

start_prod() {
    print_status "Starting production services..."
    
    # Check if secrets are decrypted
    if [ ! -f ".env.production" ]; then
        print_info "Decrypting secrets first..."
        ./scripts/secrets-manage.sh reveal
    fi
    
    # Start production services
    docker-compose -f docker-compose.app.yml --env-file .env.production up -d
    
    print_status "Production services started!"
    print_info "Services available at:"
    echo "  - Application: http://localhost"
    echo "  - Database: localhost:5432"
    echo "  - pgAdmin: http://localhost:8080"
}

stop_prod() {
    print_status "Stopping production services..."
    docker-compose -f docker-compose.app.yml down
    print_status "Production services stopped!"
}

clean() {
    print_status "Cleaning up..."
    
    # Stop all services
    docker-compose -f docker-compose.app.yml down 2>/dev/null || true
    docker-compose -f docker-compose.app.dev.yml down 2>/dev/null || true
    
    # Remove decrypted files
    rm -f .env.development .env.production
    
    # Clean up docker
    docker system prune -f
    
    print_status "Cleanup complete!"
}

case "$1" in
    "setup-dev")
        setup_dev
        ;;
    "start-dev")
        start_dev
        ;;
    "stop-dev")
        stop_dev
        ;;
    "setup-prod")
        setup_prod
        ;;
    "start-prod")
        start_prod
        ;;
    "stop-prod")
        stop_prod
        ;;
    "clean")
        clean
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    "")
        show_usage
        ;;
    *)
        print_warning "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
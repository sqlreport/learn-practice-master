#!/bin/bash

# Learn Practice Master App Management Script
# Manages the combined frontend+backend application container with separate PostgreSQL

set -e

# Configuration
APP_CONTAINER_NAME="learn-practice-master-app"
POSTGRES_CONTAINER_NAME="app-postgres"
COMPOSE_FILE="docker-compose.app.yml"
DEV_COMPOSE_FILE="docker-compose.app.dev.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[APP]${NC} $1"
}

# Check if containers are running
check_containers() {
    local mode="${1:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
    fi
    
    if ! docker compose -f "$compose_file" ps | grep -q "Up"; then
        print_error "Application containers are not running"
        print_status "Start them with: $0 start [$mode]"
        exit 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for PostgreSQL to be ready..."
    timeout 60 bash -c "until docker exec $POSTGRES_CONTAINER_NAME pg_isready -U myapp_user -d myapp_db; do sleep 2; done"
    
    print_status "Waiting for application to be ready..."
    timeout 60 bash -c "until curl -f http://localhost/health >/dev/null 2>&1; do sleep 2; done"
    
    print_status "All services are ready!"
}

# Build and start services
start_services() {
    local mode="${1:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
        print_header "Starting development environment..."
    else
        print_header "Starting production environment..."
    fi
    
    # Build frontend first if in dev mode
    if [ "$mode" = "dev" ]; then
        print_status "Building frontend..."
        cd frontend && npm run build && cd ..
    fi
    
    print_status "Building and starting containers..."
    docker compose -f "$compose_file" up -d --build
    
    wait_for_services
    
    print_status "Application started successfully!"
    print_status "Frontend: http://localhost"
    print_status "Backend API: http://localhost:5000"
    print_status "pgAdmin: http://localhost:8080"
}

# Stop services
stop_services() {
    local mode="${1:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
    fi
    
    print_status "Stopping application services..."
    docker compose -f "$compose_file" down
}

# Show service status
show_status() {
    local mode="${1:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
    fi
    
    print_header "Application Status:"
    docker compose -f "$compose_file" ps
}

# Show logs
show_logs() {
    local service="${1:-app}"
    local mode="${2:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
    fi
    
    print_status "Showing logs for $service..."
    docker compose -f "$compose_file" logs -f "$service"
}

# Execute command in app container
exec_app() {
    local command="$1"
    
    if [ -z "$command" ]; then
        print_error "Please provide a command to execute"
        echo "Usage: $0 exec <command>"
        exit 1
    fi
    
    docker exec -it "$APP_CONTAINER_NAME" bash -c "$command"
}

# Access app shell
app_shell() {
    print_status "Starting shell in app container..."
    docker exec -it "$APP_CONTAINER_NAME" bash
}

# Database operations
db_shell() {
    print_status "Starting PostgreSQL shell..."
    docker exec -it "$POSTGRES_CONTAINER_NAME" psql -U myapp_user -d myapp_db
}

# Test application
test_app() {
    print_status "Testing application endpoints..."
    
    # Test health endpoint
    if curl -f http://localhost/health >/dev/null 2>&1; then
        print_status "✅ Health endpoint working"
    else
        print_error "❌ Health endpoint failed"
    fi
    
    # Test frontend
    if curl -f http://localhost >/dev/null 2>&1; then
        print_status "✅ Frontend accessible"
    else
        print_error "❌ Frontend not accessible"
    fi
    
    # Test API
    if curl -f http://localhost:5000/api/health >/dev/null 2>&1; then
        print_status "✅ Backend API working"
    else
        print_warning "⚠️  Backend API not responding (might need API routes)"
    fi
    
    # Test database connection
    if docker exec "$POSTGRES_CONTAINER_NAME" pg_isready -U myapp_user -d myapp_db >/dev/null 2>&1; then
        print_status "✅ Database connection working"
    else
        print_error "❌ Database connection failed"
    fi
}

# Rebuild application
rebuild_app() {
    local mode="${1:-prod}"
    local compose_file="$COMPOSE_FILE"
    
    if [ "$mode" = "dev" ]; then
        compose_file="$DEV_COMPOSE_FILE"
    fi
    
    print_status "Rebuilding application..."
    
    # Build frontend first
    print_status "Building frontend..."
    cd frontend && npm run build && cd ..
    
    # Rebuild and restart app container
    docker compose -f "$compose_file" up -d --build app
    
    wait_for_services
    print_status "Application rebuilt successfully!"
}

# Show help
show_help() {
    echo "Learn Practice Master App Management Script"
    echo "=========================================="
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Environment Commands:"
    echo "  start [dev|prod]       Start application (default: prod)"
    echo "  stop [dev|prod]        Stop application"
    echo "  restart [dev|prod]     Restart application"
    echo "  status [dev|prod]      Show container status"
    echo "  rebuild [dev|prod]     Rebuild and restart app"
    echo
    echo "Container Operations:"
    echo "  logs [app|postgres] [dev|prod]  Show service logs"
    echo "  shell                  Access app container shell"
    echo "  exec <command>         Execute command in app container"
    echo
    echo "Database Operations:"
    echo "  db-shell               PostgreSQL interactive shell"
    echo "  db-backup              Create database backup"
    echo "  db-restore <file>      Restore database from backup"
    echo
    echo "Testing & Monitoring:"
    echo "  test                   Test application endpoints"
    echo "  monitor                Monitor application (basic)"
    echo
    echo "Examples:"
    echo "  $0 start dev           # Start development environment"
    echo "  $0 logs app            # Show app logs"
    echo "  $0 exec 'ls -la'       # List files in app container"
    echo "  $0 rebuild dev         # Rebuild dev environment"
    echo
    echo "Access Points:"
    echo "  Frontend:  http://localhost"
    echo "  Backend:   http://localhost:5000"
    echo "  pgAdmin:   http://localhost:8080"
}

# Main script logic
case "${1:-help}" in
    start)
        start_services "$2"
        ;;
    stop)
        stop_services "$2"
        ;;
    restart)
        stop_services "$2"
        start_services "$2"
        ;;
    status)
        show_status "$2"
        ;;
    logs)
        show_logs "$2" "$3"
        ;;
    shell)
        check_containers
        app_shell
        ;;
    exec)
        check_containers
        exec_app "$2"
        ;;
    db-shell)
        check_containers
        db_shell
        ;;
    db-backup)
        check_containers
        ./scripts/postgres-manage.sh backup
        ;;
    db-restore)
        check_containers
        ./scripts/postgres-manage.sh restore "$2"
        ;;
    test)
        check_containers
        test_app
        ;;
    rebuild)
        rebuild_app "$2"
        ;;
    monitor)
        check_containers
        print_status "Basic monitoring (Press Ctrl+C to stop)"
        while true; do
            clear
            echo "=== Learn Practice Master App Monitor ==="
            echo "Time: $(date)"
            echo
            show_status
            echo
            echo "Recent logs:"
            docker logs "$APP_CONTAINER_NAME" --tail 5 2>/dev/null || echo "No recent logs"
            sleep 5
        done
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
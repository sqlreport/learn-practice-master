#!/bin/bash

# PostgreSQL Database Management Script
# Provides common database operations for the containerized PostgreSQL setup

set -e

# Configuration
CONTAINER_NAME="app-postgres"
DB_NAME="myapp_db"
DB_USER="myapp_user"
DB_PASSWORD="myapp_password"
BACKUP_DIR="./docker/postgresql/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if container is running
check_container() {
    if ! docker ps | grep -q $CONTAINER_NAME; then
        print_error "PostgreSQL container '$CONTAINER_NAME' is not running"
        print_status "Start it with: docker compose -f docker-compose.postgres.yml up -d"
        exit 1
    fi
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    print_status "Waiting for PostgreSQL to be ready..."
    timeout 60 bash -c "until docker exec $CONTAINER_NAME pg_isready -U $DB_USER -d $DB_NAME; do sleep 2; done"
    print_status "PostgreSQL is ready!"
}

# Execute SQL command
execute_sql() {
    local sql_command="$1"
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "$sql_command"
}

# Execute SQL file
execute_sql_file() {
    local sql_file="$1"
    if [ ! -f "$sql_file" ]; then
        print_error "SQL file '$sql_file' not found"
        exit 1
    fi
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < "$sql_file"
}

# Create backup
create_backup() {
    local backup_name="${1:-backup_$(date +%Y%m%d_%H%M%S)}"
    local backup_file="$BACKUP_DIR/${backup_name}.sql"
    
    print_status "Creating backup: $backup_file"
    mkdir -p $BACKUP_DIR
    
    docker exec $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME > "$backup_file"
    
    if [ $? -eq 0 ]; then
        print_status "Backup created successfully: $backup_file"
        # Also create compressed version
        gzip -c "$backup_file" > "${backup_file}.gz"
        print_status "Compressed backup: ${backup_file}.gz"
    else
        print_error "Backup failed"
        exit 1
    fi
}

# Restore from backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "Please specify backup file"
        echo "Usage: $0 restore <backup_file>"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file '$backup_file' not found"
        exit 1
    fi
    
    print_warning "This will restore the database from backup. All current data will be lost!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring from backup: $backup_file"
        
        # Drop and recreate database
        docker exec $CONTAINER_NAME psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
        docker exec $CONTAINER_NAME psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        
        # Restore from backup
        if [[ "$backup_file" == *.gz ]]; then
            gunzip -c "$backup_file" | docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME
        else
            docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME < "$backup_file"
        fi
        
        print_status "Database restored successfully"
    else
        print_status "Restore cancelled"
    fi
}

# Show database stats
show_stats() {
    print_status "Database Statistics:"
    echo "===================="
    
    execute_sql "
    SELECT 
        'Database Size' as metric,
        pg_size_pretty(pg_database_size('$DB_NAME')) as value
    UNION ALL
    SELECT 
        'Tables Count',
        COUNT(*)::text
    FROM information_schema.tables 
    WHERE table_schema = 'public'
    UNION ALL
    SELECT 
        'Functions Count',
        COUNT(*)::text
    FROM information_schema.routines 
    WHERE routine_schema = 'public';
    "
    
    echo
    print_status "Table Sizes:"
    execute_sql "
    SELECT 
        tablename,
        pg_size_pretty(pg_total_relation_size(tablename::regclass)) as size
    FROM pg_tables 
    WHERE schemaname = 'public'
    ORDER BY pg_total_relation_size(tablename::regclass) DESC;
    "
}

# Test database functions
test_functions() {
    print_status "Testing database functions..."
    
    # Test user stats
    print_status "Testing get_user_stats function:"
    execute_sql "SELECT * FROM get_user_stats(1);"
    
    echo
    print_status "Testing get_popular_categories function:"
    execute_sql "SELECT * FROM get_popular_categories(3);"
    
    echo
    print_status "Testing search_posts function:"
    execute_sql "SELECT id, title, username FROM search_posts('React') LIMIT 3;"
    
    echo
    print_status "Testing cleanup_expired_sessions function:"
    execute_sql "SELECT cleanup_expired_sessions() as cleaned_sessions;"
}

# Monitor database
monitor() {
    print_status "Database Monitoring (Press Ctrl+C to stop)"
    
    while true; do
        clear
        echo "=== PostgreSQL Database Monitor ==="
        echo "Time: $(date)"
        echo
        
        # Active connections
        echo "Active Connections:"
        execute_sql "
        SELECT 
            datname,
            usename,
            application_name,
            client_addr,
            state,
            query_start
        FROM pg_stat_activity 
        WHERE state = 'active' AND datname = '$DB_NAME';
        "
        
        echo
        echo "Database Activity:"
        execute_sql "
        SELECT 
            tup_returned as rows_read,
            tup_fetched as rows_fetched,
            tup_inserted as rows_inserted,
            tup_updated as rows_updated,
            tup_deleted as rows_deleted
        FROM pg_stat_database 
        WHERE datname = '$DB_NAME';
        "
        
        sleep 5
    done
}

# Reset database to initial state
reset_database() {
    print_warning "This will reset the database to its initial state with sample data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Resetting database..."
        
        # Re-run initialization scripts
        for script in ./docker/postgresql/init-scripts/*.sql; do
            if [ -f "$script" ]; then
                print_status "Running: $(basename $script)"
                execute_sql_file "$script"
            fi
        done
        
        print_status "Database reset completed"
    else
        print_status "Reset cancelled"
    fi
}

# Interactive SQL shell
shell() {
    print_status "Starting interactive PostgreSQL shell..."
    print_status "Type \\q to exit"
    docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME
}

# Show help
show_help() {
    echo "PostgreSQL Database Management Script"
    echo "====================================="
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Commands:"
    echo "  start              Start PostgreSQL container"
    echo "  stop               Stop PostgreSQL container"
    echo "  restart            Restart PostgreSQL container"
    echo "  status             Show container status"
    echo "  logs               Show container logs"
    echo "  shell              Interactive PostgreSQL shell"
    echo "  backup [name]      Create database backup"
    echo "  restore <file>     Restore from backup file"
    echo "  stats              Show database statistics"
    echo "  test               Test database functions"
    echo "  monitor            Monitor database activity"
    echo "  reset              Reset database to initial state"
    echo "  sql <command>      Execute SQL command"
    echo "  help               Show this help message"
    echo
    echo "Examples:"
    echo "  $0 backup my_backup"
    echo "  $0 restore backups/my_backup.sql"
    echo "  $0 sql \"SELECT COUNT(*) FROM users;\""
}

# Main script logic
case "${1:-help}" in
    start)
        print_status "Starting PostgreSQL container..."
        docker compose -f docker-compose.postgres.yml up -d
        wait_for_postgres
        ;;
    stop)
        print_status "Stopping PostgreSQL container..."
        docker compose -f docker-compose.postgres.yml down
        ;;
    restart)
        print_status "Restarting PostgreSQL container..."
        docker compose -f docker-compose.postgres.yml restart
        wait_for_postgres
        ;;
    status)
        docker compose -f docker-compose.postgres.yml ps
        ;;
    logs)
        docker compose -f docker-compose.postgres.yml logs -f postgres
        ;;
    shell)
        check_container
        shell
        ;;
    backup)
        check_container
        create_backup "$2"
        ;;
    restore)
        check_container
        restore_backup "$2"
        ;;
    stats)
        check_container
        show_stats
        ;;
    test)
        check_container
        test_functions
        ;;
    monitor)
        check_container
        monitor
        ;;
    reset)
        check_container
        reset_database
        ;;
    sql)
        check_container
        if [ -z "$2" ]; then
            print_error "Please provide SQL command"
            echo "Usage: $0 sql \"<SQL_COMMAND>\""
            exit 1
        fi
        execute_sql "$2"
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
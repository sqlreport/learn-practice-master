#!/bin/bash
# docker/entrypoint.app.sh

set -e

echo "Starting learn-practice-master-app container..."

# Wait for PostgreSQL to be ready (external container)
if [ -n "$DATABASE_URL" ]; then
    echo "Waiting for PostgreSQL to be ready..."
    until pg_isready -h postgres -p 5432 -U myapp_user; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 2
    done
    echo "PostgreSQL is ready!"
    
    # Run database migrations
    cd /app/backend
    export FLASK_APP=run.py
    echo "Running database migrations..."
    flask db upgrade || echo "Migrations completed or not needed"
fi

# Create log directories
mkdir -p /var/log/supervisor /var/log/nginx

# Set permissions
chown -R appuser:appgroup /var/log/supervisor
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/log/nginx

echo "Starting application services..."

# Execute the main command
exec "$@"
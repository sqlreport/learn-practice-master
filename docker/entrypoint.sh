#!/bin/sh
# docker/entrypoint.sh

# Start PostgreSQL
su - postgres -c "pg_ctl start -D /var/lib/postgresql/data -l /var/log/postgresql/postgresql.log"

# Wait for PostgreSQL to start
until pg_isready -U postgres; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# Create database if it doesn't exist
su - postgres -c "createdb myapp_db" 2>/dev/null || true
su - postgres -c "psql -c \"CREATE USER myapp_user WITH ENCRYPTED PASSWORD 'myapp_password';\"" 2>/dev/null || true
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE myapp_db TO myapp_user;\"" 2>/dev/null || true

# Run database migrations
cd /app/backend
export FLASK_APP=run.py
export DATABASE_URL="postgresql://myapp_user:myapp_password@localhost:5432/myapp_db"
flask db upgrade

# Execute the main command
exec "$@"
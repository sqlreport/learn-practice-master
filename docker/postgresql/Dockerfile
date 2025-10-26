# PostgreSQL Docker Image with Application Schema
FROM postgres:15-alpine

# Set environment variables (will be overridden by docker-compose)
ENV POSTGRES_DB=myapp_db
ENV POSTGRES_USER=myapp_user
# POSTGRES_PASSWORD will be set by docker-compose environment

# Install additional PostgreSQL extensions
RUN apk add --no-cache postgresql-contrib

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy database initialization scripts
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Copy configuration files
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Set proper permissions
RUN chmod 755 /docker-entrypoint-initdb.d/*.sql

# Expose PostgreSQL port
EXPOSE 5432

# Use the default postgres entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
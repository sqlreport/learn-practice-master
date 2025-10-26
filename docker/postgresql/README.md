# PostgreSQL Docker Setup

This directory contains a complete PostgreSQL Docker setup with pre-configured schema, functions, and sample data for the React TypeScript + Flask application.

## Quick Start

### 1. Start PostgreSQL Container

```bash
# Start PostgreSQL with pgAdmin
docker compose -f docker-compose.postgres.yml up -d

# Or use the management script
./scripts/postgres-manage.sh start
```

### 2. Verify Setup

```bash
# Check container status
./scripts/postgres-manage.sh status

# Test database functions
./scripts/postgres-manage.sh test

# View database statistics
./scripts/postgres-manage.sh stats
```

### 3. Access Database

```bash
# Interactive SQL shell
./scripts/postgres-manage.sh shell

# Or connect via standard psql
psql -h localhost -U myapp_user -d myapp_db
# Password: myapp_password
```

### 4. Access pgAdmin (Web Interface)

- URL: http://localhost:8080
- Email: admin@example.com
- Password: admin123

## Database Schema

The PostgreSQL container is pre-configured with:

### Tables
- **users** - User accounts with authentication
- **posts** - Blog posts with content
- **categories** - Post categories
- **post_categories** - Many-to-many relationship between posts and categories
- **user_sessions** - User session management

### Functions & Procedures
- `get_user_stats(user_id)` - Get user statistics
- `get_popular_categories(limit)` - Get popular categories by post count
- `search_posts(search_term)` - Full-text search across posts
- `get_monthly_post_stats(year)` - Monthly post statistics
- `cleanup_expired_sessions()` - Clean up expired user sessions
- `update_updated_at_column()` - Trigger function for timestamp updates

### Sample Data
- 5 sample users (password: `password123` for all)
- 8 sample categories
- 10 sample posts with various content
- Post-category relationships
- Sample user sessions for testing

## Management Script

The `postgres-manage.sh` script provides comprehensive database management:

```bash
# Container management
./scripts/postgres-manage.sh start     # Start container
./scripts/postgres-manage.sh stop      # Stop container
./scripts/postgres-manage.sh restart   # Restart container
./scripts/postgres-manage.sh status    # Show status
./scripts/postgres-manage.sh logs      # Show logs

# Database operations
./scripts/postgres-manage.sh shell     # Interactive SQL shell
./scripts/postgres-manage.sh stats     # Database statistics
./scripts/postgres-manage.sh test      # Test functions
./scripts/postgres-manage.sh monitor   # Real-time monitoring

# Backup and restore
./scripts/postgres-manage.sh backup [name]        # Create backup
./scripts/postgres-manage.sh restore <file>       # Restore from backup

# Utilities
./scripts/postgres-manage.sh reset     # Reset to initial state
./scripts/postgres-manage.sh sql "SELECT * FROM users;"  # Execute SQL
```

## Connection Details

- **Host**: localhost
- **Port**: 5432
- **Database**: myapp_db
- **Username**: myapp_user
- **Password**: myapp_password

## File Structure

```
docker/postgresql/
├── Dockerfile                    # PostgreSQL container image
├── postgresql.conf              # PostgreSQL configuration
├── pg_hba.conf                 # Authentication configuration
├── init-scripts/               # Database initialization
│   ├── 01-create-extensions.sql
│   ├── 02-create-tables.sql
│   ├── 03-create-functions.sql
│   ├── 04-insert-sample-data.sql
│   └── 05-test-functions.sql
└── backups/                    # Backup storage directory
```

## Environment Variables

The following environment variables are used:

- `POSTGRES_DB=myapp_db` - Database name
- `POSTGRES_USER=myapp_user` - Database user
- `POSTGRES_PASSWORD=myapp_password` - Database password
- `PGDATA=/var/lib/postgresql/data/pgdata` - Data directory

## Volumes

- `postgres_data` - Database data persistence
- `postgres_logs` - PostgreSQL logs
- `pgadmin_data` - pgAdmin configuration
- `./docker/postgresql/backups` - Backup files

## Networks

- `app-network` - Bridge network for application communication

## Health Checks

The container includes health checks to ensure PostgreSQL is ready:
- Test: `pg_isready -U myapp_user -d myapp_db`
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 5
- Start period: 60 seconds

## Performance Configuration

The PostgreSQL configuration is optimized for development and moderate production use:

- **Memory**: 256MB shared_buffers, 1GB effective_cache_size
- **Connections**: Up to 100 concurrent connections
- **Logging**: Queries taking more than 1 second are logged
- **Checkpoints**: Optimized for write performance
- **Full-text search**: English configuration enabled

## Backup Strategy

### Automatic Backups
The management script supports both plain SQL and compressed backups:

```bash
# Create named backup
./scripts/postgres-manage.sh backup production_backup

# Creates:
# - backups/production_backup.sql (plain SQL)
# - backups/production_backup.sql.gz (compressed)
```

### Manual Backups
```bash
# Using docker directly
docker exec app-postgres pg_dump -U myapp_user -d myapp_db > backup.sql

# Custom format (recommended for large databases)
docker exec app-postgres pg_dump -U myapp_user -d myapp_db -Fc > backup.dump
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker compose -f docker-compose.postgres.yml logs postgres

# Common issues:
# 1. Port 5432 already in use
# 2. Permission issues with data volume
# 3. Insufficient disk space
```

### Connection Issues
```bash
# Test connection
./scripts/postgres-manage.sh sql "SELECT 1;"

# Check authentication
docker exec app-postgres cat /etc/postgresql/pg_hba.conf
```

### Performance Issues
```bash
# Monitor active queries
./scripts/postgres-manage.sh monitor

# Check slow query log
docker exec app-postgres tail -f /var/log/postgresql/postgresql-*.log
```

### Reset Database
```bash
# Reset to initial state with sample data
./scripts/postgres-manage.sh reset

# Or rebuild container
docker compose -f docker-compose.postgres.yml down -v
docker compose -f docker-compose.postgres.yml up -d --build
```

## Integration with Application

### Flask Configuration
```python
# In your Flask app configuration
SQLALCHEMY_DATABASE_URI = 'postgresql://myapp_user:myapp_password@localhost:5432/myapp_db'
```

### Environment Variables
```bash
# .env file
DATABASE_URL=postgresql://myapp_user:myapp_password@localhost:5432/myapp_db
```

### Docker Compose Integration
```yaml
# In your main docker-compose.yml
services:
  backend:
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://myapp_user:myapp_password@postgres:5432/myapp_db
  
  postgres:
    extends:
      file: docker-compose.postgres.yml
      service: postgres
```

## Security Considerations

1. **Change default passwords** in production
2. **Restrict network access** using firewall rules
3. **Enable SSL/TLS** for encrypted connections
4. **Regular security updates** of PostgreSQL image
5. **Backup encryption** for sensitive data
6. **Access logging** and monitoring

## Extensions Included

- **uuid-ossp** - UUID generation
- **pgcrypto** - Cryptographic functions
- **pg_trgm** - Trigram matching for fuzzy search
- **unaccent** - Text search without accents

## Monitoring and Alerting

The setup includes basic monitoring capabilities:

```bash
# Real-time monitoring
./scripts/postgres-manage.sh monitor

# Check database size growth
./scripts/postgres-manage.sh stats

# Monitor slow queries in logs
docker logs app-postgres --follow | grep "duration:"
```

For production, consider integrating with:
- **Prometheus** + **Grafana** for metrics visualization
- **ELK Stack** for log aggregation
- **pg_stat_statements** for query performance analysis
#!/bin/bash
set -e

echo "🔄 Post-start setup..."

# Ensure database is ready
echo "🗄️  Checking database connection..."
timeout 30 bash -c 'until pg_isready -h db -p 5432 -U myapp_user; do sleep 1; done'

echo "✅ Post-start setup complete!"
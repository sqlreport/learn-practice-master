#!/bin/bash
# deploy.sh

set -e

echo "Starting deployment..."

# Pull latest code
git pull origin main

# Build and deploy
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Health check
if curl -f http://localhost/health; then
    echo "Deployment successful!"
else
    echo "Deployment failed - rolling back"
    docker-compose down
    docker-compose up -d
    exit 1
fi

# Cleanup old images
docker system prune -f

echo "Deployment completed successfully!"
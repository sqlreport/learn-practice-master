#!/bin/bash
# test-integration.sh

# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Wait for services
sleep 30

# Run tests
npm run test:e2e --prefix frontend
python -m pytest backend/tests/

# Cleanup
docker-compose -f docker-compose.test.yml down
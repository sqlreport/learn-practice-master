# Multi-stage Dockerfile for learn-practice-master-app
# Combines frontend (React TypeScript + Vite) and backend (Flask) in a single image

# Stage 1: Build frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package files
COPY frontend/package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy frontend source code
COPY frontend/ ./

# Build frontend for production
RUN npm run build

# Stage 2: Backend setup
FROM python:3.11-slim AS backend-base

WORKDIR /app/backend

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    gcc \
    curl \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source code
COPY backend/ .

# Stage 3: Final app image
FROM backend-base

# Copy built frontend from frontend-builder stage
COPY --from=frontend-builder /app/frontend/dist /var/www/html

# Copy nginx configuration
COPY nginx/nginx.app.conf /etc/nginx/nginx.conf

# Copy supervisor configuration
COPY docker/supervisord.app.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint script
COPY docker/entrypoint.app.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create app user
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m appuser

# Set proper permissions
RUN chown -R appuser:appgroup /app/backend
RUN chown -R www-data:www-data /var/www/html

# Create required directories
RUN mkdir -p /var/log/supervisor /var/log/nginx
RUN chown -R appuser:appgroup /var/log/supervisor

# Expose ports
EXPOSE 80 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Start supervisor to manage both nginx and flask
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
# docker/Dockerfile
FROM node:18-alpine AS frontend-builder

# Build frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production

COPY frontend/ ./
RUN npm run build

# Python backend stage
FROM python:3.11-slim AS backend-builder

WORKDIR /app/backend
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./

# Final stage with nginx
FROM nginx:alpine

# Install Python, PostgreSQL client, and supervisor
RUN apk add --no-cache python3 py3-pip postgresql-client supervisor

# Copy Python dependencies
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend-builder /usr/local/bin /usr/local/bin

# Copy application files
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html
COPY --from=backend-builder /app/backend /app/backend
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh

# Create app user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Install PostgreSQL in the container
RUN apk add --no-cache postgresql postgresql-contrib

# Initialize PostgreSQL
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data && \
    chmod 700 /var/lib/postgresql/data

USER postgres
RUN initdb -D /var/lib/postgresql/data

USER root

WORKDIR /app/backend

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
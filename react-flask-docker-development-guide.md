# React TypeScript + Flask + PostgreSQL Development Guide

A comprehensive guide for developing a full-stack application using React TypeScript frontend, Flask backend, PostgreSQL database, all containerized in a single Docker image with nginx.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Prerequisite Setup](#prerequisite-setup)
4. [Project Structure](#project-structure)
5. [Frontend Development (React TypeScript + Vite)](#frontend-development)
6. [Backend Development (Flask)](#backend-development)
7. [Database Setup (PostgreSQL)](#database-setup)
8. [Docker Configuration](#docker-configuration)
9. [Nginx Configuration](#nginx-configuration)
10. [Development Workflow](#development-workflow)
11. [Production Deployment](#production-deployment)
12. [Testing Strategy](#testing-strategy)
13. [Troubleshooting](#troubleshooting)

## Project Overview

This application architecture consists of:
- **Frontend**: React TypeScript application built with Vite
- **Backend**: Flask REST API with SQLAlchemy ORM
- **Database**: PostgreSQL in dedicated container with full schema and sample data
- **Web Server**: Nginx for serving static files and reverse proxy
- **Containerization**: Separate PostgreSQL container and combined application container

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Environment                           │
│                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐ │
│  │  PostgreSQL         │    │  learn-practice-master-app      │ │
│  │  Container          │    │                                 │ │
│  │                     │    │  ┌─────────┐  ┌─────────────┐   │ │
│  │  - Full schema      │◄──►│  │  Nginx  │  │   Flask     │   │ │
│  │  - Sample data      │    │  │ (Port 80)│  │ (Port 5000) │   │ │
│  │  - Functions        │    │  │         │  │             │   │ │
│  │  - pgAdmin          │    │  │ Static  │  │    API      │   │ │
│  │                     │    │  │ Files   │  │   Server    │   │ │
│  └─────────────────────┘    │  └─────────┘  └─────────────┘   │ │
│                             │                                 │ │
│                             │  Frontend: React TypeScript    │ │
│                             │  Backend:  Flask + SQLAlchemy  │ │
│                             └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

Before starting development, ensure you have the following installed:

- **Node.js** (v18 or higher) - for frontend development
- **Docker** and **Docker Compose** - for containerized services
- **Git** - for version control
- **Code Editor** (VS Code recommended)

### Quick Installation

#### Node.js
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18

# Windows
choco install nodejs
```

#### Docker
```bash
# Ubuntu - install Docker Engine and Compose
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# macOS/Windows - Download Docker Desktop
# https://www.docker.com/products/docker-desktop/
```

**Note**: With the containerized setup, you don't need to install PostgreSQL or Python locally. The Docker containers handle all dependencies.

### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "ms-python.python",
    "bradlc.vscode-tailwindcss", 
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode-remote.remote-containers"
  ]
}
```

## Project Structure

```
project-root/
├── frontend/                   # React TypeScript frontend
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types/
│   │   ├── utils/
│   │   ├── tests/
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── postcss.config.js
├── backend/                    # Flask backend
│   ├── app/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── utils/
│   │   ├── __init__.py
│   │   └── config.py
│   ├── migrations/
│   ├── tests/
│   ├── requirements.txt
│   └── run.py
├── nginx/                      # Nginx configuration
│   ├── nginx.conf
│   └── nginx.app.conf
├── docker/                     # Docker configurations
│   ├── Dockerfile.app
│   ├── Dockerfile.dev
│   ├── entrypoint.app.sh
│   ├── entrypoint.sh
│   ├── supervisord.app.conf
│   ├── supervisord.conf
│   └── postgresql/
│       ├── Dockerfile
│       ├── README.md
│       ├── postgresql.conf
│       ├── pg_hba.conf
│       ├── init-scripts/
│       └── backups/
├── scripts/                    # Management scripts
│   ├── app-manage.sh
│   └── postgres-manage.sh
├── docker-compose.postgres.yml # PostgreSQL container
├── docker-compose.app.yml      # Combined app container
├── docker-compose.app.dev.yml  # Development setup
├── docker-compose.dev.yml      # Legacy development setup
├── docker-compose.test.yml     # Testing setup
├── docker-compose.yml          # Main production setup
├── .env.example
├── .gitignore
├── README.md
├── POSTGRESQL_SETUP_COMPLETE.md
├── COMBINED_APP_SETUP.md
└── react-flask-docker-development-guide.md
```

## Frontend Development

### 1. Initialize React TypeScript Project with Vite

```bash
# Create frontend directory
mkdir frontend && cd frontend

# Initialize Vite project with React TypeScript template
npm create vite@latest . -- --template react-ts

# Install additional dependencies
npm install axios react-router-dom @types/node
npm install -D tailwindcss postcss autoprefixer @types/react-router-dom

# Initialize Tailwind CSS
npx tailwindcss init -p
```

### 2. Vite Configuration

```typescript
// frontend/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    host: true,
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
})
```

### 3. TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 4. API Service Layer

```typescript
// frontend/src/services/api.ts
import axios, { AxiosResponse } from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for auth tokens
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

### 5. Type Definitions

```typescript
// frontend/src/types/index.ts
export interface User {
  id: number;
  email: string;
  username: string;
  createdAt: string;
  updatedAt: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}
```

## Backend Development

### 1. Flask Application Structure

```python
# backend/app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from app.config import Config

db = SQLAlchemy()
migrate = Migrate()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    CORS(app)
    
    # Register blueprints
    from app.routes.auth import bp as auth_bp
    from app.routes.users import bp as users_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(users_bp, url_prefix='/api/users')
    
    return app
```

### 2. Configuration Management

```python
# backend/app/config.py
import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    
    # Database configuration
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'postgresql://user:password@localhost:5432/dbname'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT configuration
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-string'
    JWT_ACCESS_TOKEN_EXPIRES = 3600  # 1 hour
    
    # Pagination
    POSTS_PER_PAGE = 10

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or \
        'postgresql://postgres:postgres@localhost:5432/devdb'

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
```

### 3. Database Models

```python
# backend/app/models/user.py
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from app import db

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'is_active': self.is_active
        }
    
    def __repr__(self):
        return f'<User {self.username}>'
```

### 4. API Routes

```python
# backend/app/routes/users.py
from flask import Blueprint, request, jsonify
from app import db
from app.models.user import User
from app.utils.decorators import jwt_required
from app.utils.validators import validate_user_data

bp = Blueprint('users', __name__)

@bp.route('/', methods=['GET'])
@jwt_required
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    users = User.query.paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'success': True,
        'data': {
            'users': [user.to_dict() for user in users.items],
            'total': users.total,
            'page': page,
            'per_page': per_page,
            'total_pages': users.pages
        }
    })

@bp.route('/', methods=['POST'])
@jwt_required
def create_user():
    data = request.get_json()
    
    # Validate input data
    errors = validate_user_data(data)
    if errors:
        return jsonify({'success': False, 'errors': errors}), 400
    
    # Check if user already exists
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'success': False, 'message': 'Email already exists'}), 409
    
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'success': False, 'message': 'Username already exists'}), 409
    
    # Create new user
    user = User(
        username=data['username'],
        email=data['email']
    )
    user.set_password(data['password'])
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'success': True,
        'data': user.to_dict(),
        'message': 'User created successfully'
    }), 201
```

### 5. Requirements

```txt
# backend/requirements.txt
Flask==2.3.3
Flask-SQLAlchemy==3.0.5
Flask-Migrate==4.0.5
Flask-CORS==4.0.0
psycopg2-binary==2.9.7
python-dotenv==1.0.0
PyJWT==2.8.0
Werkzeug==2.3.7
gunicorn==21.2.0
redis==4.6.0
celery==5.3.1
```

## Database Setup (PostgreSQL)

This project includes a complete PostgreSQL Docker setup with pre-configured schema, functions, and sample data. The easiest way to get started is using the containerized PostgreSQL setup which is fully automated.

### Quick Start with Containerized PostgreSQL (Recommended)

The project includes a dedicated PostgreSQL container with everything pre-configured:

#### Start PostgreSQL Container
```bash
# Start PostgreSQL with pgAdmin web interface
docker compose -f docker-compose.postgres.yml up -d

# Or use the management script
./scripts/postgres-manage.sh start
```

#### Verify Setup
```bash
# Check container status
./scripts/postgres-manage.sh status

# Test database functions
./scripts/postgres-manage.sh test

# View database statistics
./scripts/postgres-manage.sh stats
```

#### Access Database
```bash
# Interactive SQL shell
./scripts/postgres-manage.sh shell

# Or connect via standard psql
psql -h localhost -U myapp_user -d myapp_db
# Password: myapp_password
```

#### Access pgAdmin Web Interface
- **URL**: http://localhost:8080
- **Email**: admin@example.com
- **Password**: admin123

### Features Included
- **Complete schema** with users, posts, categories, and sessions tables
- **Advanced functions** for statistics, search, and data management
- **Sample data** for immediate testing and development
- **pgAdmin web interface** for database administration
- **Management script** for common database operations
- **Automated backups** and restore functionality

### Connection Details
- **Host**: localhost
- **Port**: 5432
- **Database**: myapp_db
- **Username**: myapp_user
- **Password**: myapp_password

For complete PostgreSQL setup documentation, see [PostgreSQL Docker Setup](./docker/postgresql/README.md).

### Integration with Flask

Configure your Flask application to connect to the database:

```python
# backend/app/config.py
class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'postgresql://myapp_user:myapp_password@localhost:5432/myapp_db'
```

```bash
# .env file
DATABASE_URL=postgresql://myapp_user:myapp_password@localhost:5432/myapp_db
```

### Alternative: Local PostgreSQL Installation

If you prefer to install PostgreSQL locally instead of using Docker, follow the detailed instructions in the [Prerequisite Setup](#prerequisite-setup) section.

## Docker Configuration

### 1. Application Dockerfile

The project uses a multi-stage Dockerfile that combines the React TypeScript frontend and Flask backend:

```dockerfile
# docker/Dockerfile.app
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
COPY --from=frontend-builder /app/frontend/dist /var/www/html
COPY --from=backend-builder /app/backend /app/backend
COPY nginx/nginx.app.conf /etc/nginx/nginx.conf
COPY docker/supervisord.app.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.app.sh /entrypoint.sh

# Set permissions and create app user
RUN chmod +x /entrypoint.sh && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app/backend
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

### 2. Supervisor Configuration

```ini
# docker/supervisord.app.conf
[supervisord]
nodaemon=true
user=root

[program:flask]
command=gunicorn --bind 0.0.0.0:5000 --workers 4 run:app
directory=/app/backend
user=appuser
autostart=true
autorestart=true
stderr_logfile=/var/log/flask.err.log
stdout_logfile=/var/log/flask.out.log

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log
```

### 3. Entry Point Script

```bash
#!/bin/sh
# docker/entrypoint.app.sh

# Wait for PostgreSQL to be ready (external container)
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h postgres -U myapp_user -d myapp_db; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is up - executing command"

# Run database migrations
cd /app/backend
export FLASK_APP=run.py
export DATABASE_URL="postgresql://myapp_user:myapp_password@postgres:5432/myapp_db"
flask db upgrade || echo "Migration failed or no migrations to run"

# Execute the main command
exec "$@"
```

## Nginx Configuration

```nginx
# nginx/nginx.app.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    server {
        listen 80;
        server_name localhost;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";

        # Serve static files
        location / {
            root /var/www/html;
            index index.html;
            try_files $uri $uri/ /index.html;
            
            # Cache static assets
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # Proxy API requests to Flask
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://localhost:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeout settings
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

## Development Workflow

This project includes comprehensive management scripts that simplify development and deployment workflows.

### Management Scripts

#### PostgreSQL Management
```bash
# Start/stop PostgreSQL container
./scripts/postgres-manage.sh start
./scripts/postgres-manage.sh stop
./scripts/postgres-manage.sh restart

# Database operations
./scripts/postgres-manage.sh shell        # Interactive SQL shell
./scripts/postgres-manage.sh stats        # Database statistics
./scripts/postgres-manage.sh test         # Test database functions
./scripts/postgres-manage.sh backup       # Create backup
./scripts/postgres-manage.sh restore file # Restore from backup

# Utilities
./scripts/postgres-manage.sh status       # Show container status
./scripts/postgres-manage.sh logs         # View logs
./scripts/postgres-manage.sh monitor      # Real-time monitoring
```

#### Application Management
```bash
# Container operations
./scripts/app-manage.sh start [dev]       # Start application (dev mode optional)
./scripts/app-manage.sh stop              # Stop all containers
./scripts/app-manage.sh restart           # Restart application
./scripts/app-manage.sh status            # Show container status

# Development operations
./scripts/app-manage.sh rebuild [dev]     # Rebuild application image
./scripts/app-manage.sh logs [service]    # View logs (app/postgres)
./scripts/app-manage.sh shell             # Access app container shell

# Database integration
./scripts/app-manage.sh db-shell          # PostgreSQL shell
./scripts/app-manage.sh db-backup         # Create database backup
./scripts/app-manage.sh test              # Test all endpoints
```

### 1. Local Development Setup

```bash
# Clone the repository
git clone <repository-url>
cd project-root

# Copy environment variables
cp .env.example .env

# Option 1: Using management scripts (recommended)
# Start PostgreSQL
./scripts/postgres-manage.sh start

# Start the combined application
./scripts/app-manage.sh start dev

# Option 2: Run components separately for development
# Terminal 1: Start PostgreSQL
docker compose -f docker-compose.postgres.yml up -d

# Terminal 2: Frontend development server
cd frontend && npm run dev

# Terminal 3: Backend development server
cd backend && python run.py
```

### 2. Development Docker Compose

```yaml
# docker-compose.app.dev.yml
version: '3.8'

services:
  postgres:
    extends:
      file: docker-compose.postgres.yml
      service: postgres
    
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile.app
    image: learn-practice-master-app:dev
    ports:
      - "80:80"
      - "5000:5000"
    volumes:
      - ./backend:/app/backend
      - ./frontend/dist:/var/www/html
    environment:
      - FLASK_ENV=development
      - DATABASE_URL=postgresql://myapp_user:myapp_password@postgres:5432/myapp_db
      - SECRET_KEY=dev-secret-key
      - JWT_SECRET_KEY=dev-jwt-secret
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### 3. Production Build Commands

```bash
# Build frontend first
cd frontend && npm run build && cd ..

# Build application image
docker build -f docker/Dockerfile.app -t learn-practice-master-app:latest .

# Run production containers using management script
./scripts/app-manage.sh start

# Or with docker-compose
docker compose -f docker-compose.app.yml up -d --build
```

## Production Deployment

### 1. Production Docker Compose

```yaml
# docker-compose.app.yml
version: '3.8'

services:
  postgres:
    extends:
      file: docker-compose.postgres.yml
      service: postgres
    
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile.app
    image: learn-practice-master-app:latest
    ports:
      - "80:80"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://myapp_user:myapp_password@postgres:5432/myapp_db
      - SECRET_KEY=${SECRET_KEY}
      - JWT_SECRET_KEY=${JWT_SECRET_KEY}
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  app-network:
    driver: bridge
```

### 2. Environment Variables

```bash
# .env.example
# Database
DATABASE_URL=postgresql://myapp_user:myapp_password@localhost:5432/myapp_db

# Flask
SECRET_KEY=your-secret-key-here
FLASK_ENV=production
JWT_SECRET_KEY=your-jwt-secret-here

# Frontend
VITE_API_URL=http://localhost/api

# SSL (for production)
SSL_CERT_PATH=/etc/ssl/certs/cert.pem
SSL_KEY_PATH=/etc/ssl/certs/key.pem
```

### 3. Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Starting deployment..."

# Pull latest code
git pull origin main

# Build frontend
cd frontend && npm run build && cd ..

# Build and deploy
./scripts/app-manage.sh stop
./scripts/app-manage.sh rebuild
./scripts/app-manage.sh start

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Health check
if curl -f http://localhost/health; then
    echo "Deployment successful!"
else
    echo "Deployment failed - rolling back"
    ./scripts/app-manage.sh stop
    ./scripts/app-manage.sh start
    exit 1
fi

# Cleanup old images
docker system prune -f

echo "Deployment completed successfully!"
```

## Testing Strategy

### 1. Frontend Testing

```typescript
// frontend/src/tests/components/App.test.tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import App from '../App';

describe('App', () => {
  it('renders the app', () => {
    render(<App />);
    expect(screen.getByRole('main')).toBeInTheDocument();
  });
});
```

```json
// frontend/package.json (test scripts)
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  },
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "vitest": "^0.34.0",
    "@vitest/ui": "^0.34.0"
  }
}
```

### 2. Backend Testing

```python
# backend/tests/test_users.py
import pytest
from app import create_app, db
from app.models.user import User
from app.config import TestingConfig

@pytest.fixture
def app():
    app = create_app(TestingConfig)
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

def test_create_user(client):
    response = client.post('/api/users/', json={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'password123'
    })
    
    assert response.status_code == 201
    data = response.get_json()
    assert data['success'] is True
    assert data['data']['username'] == 'testuser'
```

### 3. Integration Testing

```bash
# test-integration.sh
#!/bin/bash

# Start test environment
./scripts/postgres-manage.sh start
./scripts/app-manage.sh start

# Wait for services
sleep 30

# Run tests
npm run test:e2e --prefix frontend
python -m pytest backend/tests/

# Cleanup
./scripts/app-manage.sh stop
./scripts/postgres-manage.sh stop
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Database Connection Issues

```bash
# Check PostgreSQL container status
./scripts/postgres-manage.sh status

# View PostgreSQL logs
./scripts/postgres-manage.sh logs

# Test database connection
./scripts/postgres-manage.sh test

# Reset database if needed
./scripts/postgres-manage.sh reset
```

#### 2. Frontend Build Issues

```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Check for TypeScript errors
npm run type-check

# Debug Vite build
npm run build -- --debug
```

#### 3. Backend API Issues

```python
# Enable Flask debug mode
export FLASK_ENV=development
export FLASK_DEBUG=1

# Check application logs
./scripts/app-manage.sh logs app

# Test API endpoints
curl -X GET http://localhost/api/health
curl -X GET http://localhost:5000/api/health
```

#### 4. Docker Build Issues

```bash
# Build with no cache
docker build --no-cache -f docker/Dockerfile.app .

# Check disk space
docker system df
docker system prune

# View build logs
docker build --progress=plain -f docker/Dockerfile.app .

# Use management script for rebuilding
./scripts/app-manage.sh rebuild
```

#### 5. Nginx Configuration Issues

```bash
# Test nginx configuration
nginx -t

# Reload nginx
nginx -s reload

# Check nginx logs
tail -f /var/log/nginx/error.log
```

### Performance Optimization

#### Frontend Optimizations

```typescript
// Lazy loading components
const LazyComponent = lazy(() => import('./LazyComponent'));

// Bundle splitting
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
        },
      },
    },
  },
});
```

#### Backend Optimizations

```python
# Database query optimization
from sqlalchemy.orm import joinedload

users = User.query.options(joinedload(User.posts)).all()

# Caching with Redis
from flask_caching import Cache

cache = Cache(app, config={'CACHE_TYPE': 'redis'})

@cache.memoize(timeout=300)
def get_user_data(user_id):
    return User.query.get(user_id).to_dict()
```

#### Database Optimizations

```sql
-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
```

### Monitoring and Logging

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  app:
    extends:
      file: docker-compose.app.yml
      service: app
    volumes:
      - ./logs:/app/logs

  postgres:
    extends:
      file: docker-compose.postgres.yml
      service: postgres

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - app-network

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Security Considerations

1. **Environment Variables**: Never commit sensitive data to version control
2. **HTTPS**: Always use SSL/TLS in production
3. **Input Validation**: Validate all user inputs on both frontend and backend
4. **Authentication**: Implement proper JWT token handling and refresh mechanisms
5. **CORS**: Configure CORS properly for your domain
6. **Rate Limiting**: Implement rate limiting to prevent abuse
7. **SQL Injection**: Use parameterized queries and ORM
8. **XSS Protection**: Sanitize user inputs and use Content Security Policy

### Conclusion

This comprehensive guide provides a solid foundation for developing a modern full-stack application using React TypeScript, Flask, PostgreSQL, with separate containerized services. The architecture is scalable, maintainable, and production-ready.

Key benefits of this setup:
- **Separated Services**: Database and application in separate containers for better scaling
- **Modern Stack**: Latest versions of React, TypeScript, and Flask
- **Type Safety**: Full TypeScript support for better development experience
- **Performance**: Optimized builds with Vite and proper caching strategies
- **Security**: Built-in security best practices
- **Monitoring**: Easy to add monitoring and logging solutions
- **Scalability**: Architecture supports independent scaling of database and application
- **Management**: Comprehensive management scripts for easy operations

The project includes:
- **Containerized PostgreSQL** with complete schema, functions, and sample data
- **Combined application container** with React frontend and Flask backend
- **Management scripts** for easy development and deployment
- **Development and production configurations** for different environments

Remember to customize the configuration based on your specific requirements and always follow security best practices for production deployments.
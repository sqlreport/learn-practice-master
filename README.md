# React TypeScript + Flask + PostgreSQL Full Stack Application

A modern full-stack application built with React TypeScript frontend, Flask backend, PostgreSQL database, all containerized in a single Docker image with nginx.

## Features

- **Frontend**: React 18 with TypeScript, Vite build tool, Tailwind CSS
- **Backend**: Flask REST API with SQLAlchemy ORM, JWT authentication
- **Database**: PostgreSQL with migrations
- **Containerization**: Single Docker image containing all components
- **Web Server**: Nginx for serving static files and reverse proxy
- **Development**: Hot reloading, separate development containers

## Quick Start

### Production Deployment

1. Clone the repository:
```bash
git clone <repository-url>
cd react-flask-docker-app
```

2. Copy environment variables:
```bash
cp .env.example .env
# Edit .env with your values
```

3. Build and run with Docker Compose:
```bash
docker-compose up -d --build
```

4. Access the application:
   - Frontend: http://localhost
   - API: http://localhost/api
   - Health check: http://localhost/health

### Development Setup

1. Start development environment:
```bash
docker-compose -f docker-compose.dev.yml up
```

2. Access development servers:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:5000
   - Database: localhost:5432

### Manual Development Setup

#### Prerequisites
- Node.js 18+
- Python 3.9+
- PostgreSQL
- Docker (optional)

#### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

#### Backend Setup
```bash
cd backend
pip install -r requirements.txt
export FLASK_APP=run.py
export DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
flask db upgrade
python run.py
```

## Architecture

```
┌─────────────────────────────────────────────┐
│                Docker Container             │
│                                             │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │  Nginx  │    │  Flask  │    │PostgreSQL│ │
│  │ (Port 80)│   │(Port 5000)│   │(Port 5432)│ │
│  │         │    │         │    │         │  │
│  │ Static  │◄──►│   API   │◄──►│Database │  │
│  │ Files   │    │ Server  │    │         │  │
│  └─────────┘    └─────────┘    └─────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/verify` - Verify JWT token

### Users
- `GET /api/users/` - Get all users (paginated)
- `POST /api/users/` - Create new user (authenticated)
- `GET /api/users/{id}` - Get user by ID (authenticated)
- `PUT /api/users/{id}` - Update user (authenticated, own profile)
- `DELETE /api/users/{id}` - Delete user (authenticated, own profile)

### System
- `GET /api/health` - Health check endpoint

## Environment Variables

See `.env.example` for all available environment variables:

- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY` - Flask secret key
- `JWT_SECRET_KEY` - JWT signing key
- `FLASK_ENV` - Flask environment (development/production)
- `VITE_API_URL` - Frontend API URL

## Development Commands

### Frontend
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run test         # Run tests
npm run lint         # Lint code
```

### Backend
```bash
python run.py        # Start development server
flask db init        # Initialize database migrations
flask db migrate     # Create migration
flask db upgrade     # Apply migrations
```

### Docker
```bash
# Production
docker-compose up -d --build
docker-compose down

# Development
docker-compose -f docker-compose.dev.yml up
docker-compose -f docker-compose.dev.yml down

# Build only
docker build -f docker/Dockerfile -t myapp:latest .
```

## Testing

### Frontend Tests
```bash
cd frontend
npm test                 # Run tests
npm run test:coverage    # Run with coverage
npm run test:ui          # Run with UI
```

### Backend Tests
```bash
cd backend
python -m pytest tests/
```

## Deployment

### Using Docker Compose (Recommended)
```bash
# Production deployment
docker-compose up -d --build

# Check status
docker-compose ps
docker-compose logs app
```

### Using Docker
```bash
# Build image
docker build -f docker/Dockerfile -t myapp:latest .

# Run container
docker run -d -p 80:80 --name myapp-prod myapp:latest

# Check logs
docker logs myapp-prod
```

## Security Features

- JWT-based authentication
- Password hashing with Werkzeug
- CORS configuration
- Rate limiting on API endpoints
- Input validation and sanitization
- Security headers in nginx
- SQL injection prevention with SQLAlchemy ORM

## Performance Optimizations

- Gzip compression in nginx
- Static file caching
- Database query optimization
- Frontend code splitting
- Docker multi-stage builds
- Lazy loading of React components

## Monitoring and Logging

- nginx access and error logs
- Flask application logs
- PostgreSQL logs
- Docker container health checks
- Supervisor process management

## Troubleshooting

### Common Issues

1. **Database connection failed**
   ```bash
   # Check PostgreSQL status
   docker exec -it container_name pg_isready -U postgres
   ```

2. **Frontend build errors**
   ```bash
   # Clear cache and reinstall
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **API not accessible**
   ```bash
   # Check nginx configuration
   nginx -t
   # Check Flask logs
   docker logs container_name | grep flask
   ```

### Debug Mode

Enable debug mode for development:
```bash
export FLASK_ENV=development
export FLASK_DEBUG=1
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the comprehensive development guide in `react-flask-docker-development-guide.md`
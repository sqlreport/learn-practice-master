# 🚀 GitHub Codespaces Setup Guide

This project is fully configured to work with GitHub Codespaces, providing a complete development environment in the cloud.

## Quick Start with Codespaces

### 1. Create a Codespace

1. Go to the repository on GitHub
2. Click the green "Code" button
3. Select "Codespaces" tab
4. Click "Create codespace on main"

### 2. Wait for Setup

The Codespace will automatically:
- Install all dependencies (Node.js, Python, PostgreSQL)
- Set up the database with sample data
- Configure environment variables
- Install VS Code extensions

### 3. Start Development

Once the setup is complete, you can start the development servers:

```bash
# Start both frontend and backend in development mode
./start-dev.sh

# Or start them individually:
# Backend (Flask)
cd backend && python run.py

# Frontend (React) - in a new terminal
cd frontend && npm run dev
```

### 4. Access Your Application

The Codespace will automatically forward ports and provide URLs:

- **Frontend (React)**: `https://{codespace-name}-3000.{domain}`
- **Backend (Flask)**: `https://{codespace-name}-5000.{domain}`
- **Database**: `localhost:5432` (internal)

## Codespace Features

### Pre-configured Development Environment

- ✅ **Node.js 18** with npm
- ✅ **Python 3.11** with pip and virtual environment
- ✅ **PostgreSQL 15** with sample data
- ✅ **Docker** for containerized development
- ✅ **Git** with GitHub CLI

### VS Code Extensions

Automatically installed extensions:
- Python support with Black formatter
- TypeScript/JavaScript support
- Tailwind CSS IntelliSense
- Prettier code formatter
- Docker support
- PostgreSQL support

### Port Forwarding

Automatically configured port forwarding:
- `3000` - React development server
- `5000` - Flask API server
- `5432` - PostgreSQL database
- `80` - Production application

### Environment Variables

Pre-configured for Codespace development:
```bash
DATABASE_URL=postgresql://myapp_user:myapp_password@db:5432/myapp_db
FLASK_ENV=development
VITE_API_URL=https://{codespace}-5000.{domain}/api
```

## Development Workflows

### Frontend Development

```bash
cd frontend

# Install dependencies (already done in setup)
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run tests
npm run test

# Lint code
npm run lint
```

### Backend Development

```bash
cd backend

# Install dependencies (already done in setup)
pip install -r requirements.txt

# Start development server
python run.py

# Run database migrations
flask db upgrade

# Run tests
python -m pytest tests/
```

### Full Stack Development

```bash
# Start both servers with one command
./start-dev.sh

# Or start production environment
./start-prod.sh
```

### Database Management

```bash
# Connect to PostgreSQL
psql postgresql://myapp_user:myapp_password@db:5432/myapp_db

# Or use the built-in PostgreSQL extension in VS Code
# 1. Open Command Palette (Ctrl/Cmd + Shift + P)
# 2. Type "PostgreSQL: New Connection"
# 3. Use connection string: postgresql://myapp_user:myapp_password@db:5432/myapp_db
```

## Customization

### Adding Dependencies

**Frontend:**
```bash
cd frontend
npm install <package-name>
```

**Backend:**
```bash
cd backend
pip install <package-name>
# Don't forget to update requirements.txt
pip freeze > requirements.txt
```

### Environment Variables

Modify `.env` file in the project root:
```bash
# Add your custom environment variables
CUSTOM_API_KEY=your-key-here
CUSTOM_CONFIG=your-config
```

### VS Code Settings

Customize `.devcontainer/devcontainer.json`:
```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "your.custom.extension"
      ],
      "settings": {
        "your.custom.setting": "value"
      }
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check if database is running
   docker-compose ps
   
   # Restart database
   docker-compose restart db
   ```

2. **Port Already in Use**
   ```bash
   # Kill processes using the port
   lsof -ti:3000 | xargs kill -9
   lsof -ti:5000 | xargs kill -9
   ```

3. **Frontend Build Errors**
   ```bash
   cd frontend
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **Backend Import Errors**
   ```bash
   cd backend
   pip install -r requirements.txt
   # Check Python path
   export PYTHONPATH=/workspace/backend:$PYTHONPATH
   ```

### Debugging

**Enable Debug Mode:**
```bash
export FLASK_DEBUG=1
export FLASK_ENV=development
```

**View Logs:**
```bash
# Application logs
docker-compose logs -f

# Database logs
docker-compose logs db

# Specific service logs
docker-compose logs backend
```

### Performance

**Optimize for Codespaces:**
- Use `.devcontainer/devcontainer.json` to preinstall extensions
- Leverage Docker layer caching
- Use volume mounts for faster file operations

## Security Notes

⚠️ **Development Environment Only**

The Codespace environment uses development-only credentials:
- Database password: `myapp_password`
- JWT secret: `dev-jwt-secret-key-for-codespace`
- Flask secret: `dev-secret-key-for-codespace`

**Never use these in production!**

## Production Deployment

To deploy from Codespace:

1. **Build Production Assets:**
   ```bash
   cd frontend
   npm run build
   ```

2. **Test Production Build:**
   ```bash
   ./start-prod.sh
   ```

3. **Deploy to Cloud Provider:**
   ```bash
   # Example: Deploy to Heroku
   git push heroku main
   
   # Example: Deploy to AWS, Azure, etc.
   # Follow your cloud provider's deployment guide
   ```

## Support

If you encounter issues with the Codespace setup:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review the setup logs in the terminal
3. Open an issue in the repository
4. Contact the development team

---

**Happy coding in the cloud! ☁️✨**
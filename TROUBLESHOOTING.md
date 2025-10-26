# 🔧 Troubleshooting Guide

This guide helps you resolve common issues when working with the application in GitHub Codespaces or local development.

## 🚨 Common Issues

### 1. Codespace Creation Fails

**Problem**: Codespace fails to start or setup fails

**Solutions**:
```bash
# Check if Docker is running
docker ps

# Check available space
df -h

# Restart the setup
./.devcontainer/setup.sh

# If completely broken, recreate the Codespace
```

### 2. Database Connection Issues

**Problem**: `Connection refused` or `database does not exist`

**Solutions**:
```bash
# Check database status
docker compose -f docker-compose.codespace.yml ps

# Restart database
docker compose -f docker-compose.codespace.yml restart db

# Check database logs
docker compose -f docker-compose.codespace.yml logs db

# Reset database completely
docker compose -f docker-compose.codespace.yml down -v
docker compose -f docker-compose.codespace.yml up -d db

# Wait for database to be ready
timeout 30 bash -c 'until pg_isready -h localhost -p 5432 -U myapp_user; do sleep 1; done'
```

### 3. Frontend Won't Start

**Problem**: `npm run dev` fails or frontend doesn't load

**Solutions**:
```bash
cd frontend

# Clear cache and reinstall
rm -rf node_modules package-lock.json .vite
npm install

# Check for port conflicts
lsof -ti:3000 | xargs kill -9

# Start with debug info
npm run dev --verbose

# Check environment variables
echo $VITE_API_URL
```

### 4. Backend Import Errors

**Problem**: `ModuleNotFoundError` or import issues

**Solutions**:
```bash
cd backend

# Check Python path
echo $PYTHONPATH
export PYTHONPATH=/workspace/backend:$PYTHONPATH

# Reinstall dependencies
pip install -r requirements.txt

# Check virtual environment
which python
python --version

# Test imports manually
python -c "from app import create_app; print('Success')"
```

### 5. Port Forwarding Issues in Codespace

**Problem**: URLs not accessible or showing wrong content

**Solutions**:
```bash
# Check what's running on ports
netstat -tulpn | grep :3000
netstat -tulpn | grep :5000

# Kill processes on ports
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:5000 | xargs kill -9

# Check Codespace port forwarding
echo "Frontend: https://${CODESPACE_NAME}-3000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "Backend: https://${CODESPACE_NAME}-5000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

# Restart services
./start-dev.sh
```

### 6. VS Code Extensions Not Working

**Problem**: Python, TypeScript, or other extensions not functioning

**Solutions**:
```bash
# Reload VS Code window
# Ctrl/Cmd + Shift + P -> "Developer: Reload Window"

# Check extension status
# Ctrl/Cmd + Shift + P -> "Extensions: Show Installed Extensions"

# Check Python interpreter
# Ctrl/Cmd + Shift + P -> "Python: Select Interpreter"
# Choose: /opt/venv/bin/python

# Check TypeScript version
# Ctrl/Cmd + Shift + P -> "TypeScript: Select TypeScript Version"
```

### 7. Database Tables Don't Exist

**Problem**: `relation does not exist` errors

**Solutions**:
```bash
cd backend

# Create tables manually
python -c "
from app import create_app, db
app = create_app()
with app.app_context():
    db.create_all()
    print('Tables created')
"

# Check tables exist
psql postgresql://myapp_user:myapp_password@localhost:5432/myapp_db -c "\dt"

# Run migrations if available
flask db upgrade
```

### 8. CORS Errors

**Problem**: `CORS policy` errors in browser console

**Solutions**:
```bash
# Check backend CORS configuration
cd backend
grep -r "CORS" app/

# Ensure backend is running on correct port
ps aux | grep python

# Check API URL configuration
cd frontend
grep -r "VITE_API_URL" .

# Update environment variable
export VITE_API_URL=https://${CODESPACE_NAME}-5000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/api
```

### 9. Docker Issues

**Problem**: Docker commands fail or containers won't start

**Solutions**:
```bash
# Check Docker daemon
sudo systemctl status docker

# Restart Docker (if permissions allow)
sudo systemctl restart docker

# Clean up Docker
docker system prune -a

# Check disk space
df -h

# Remove old containers
docker container prune

# Check Docker logs
docker logs <container_name>
```

### 10. Environment Variables Not Loading

**Problem**: App can't find environment variables

**Solutions**:
```bash
# Check .env file exists
ls -la .env

# Check environment variables
printenv | grep -E "(DATABASE_URL|SECRET_KEY|VITE_)"

# Load environment manually
set -a && source .env && set +a

# Check if .env is being loaded by app
cd backend
python -c "
import os
from dotenv import load_dotenv
load_dotenv('../.env')
print('DATABASE_URL:', os.getenv('DATABASE_URL'))
"
```

## 🔍 Debugging Commands

### General Health Check
```bash
# Run comprehensive test
./test-setup.sh

# Check all services
docker compose -f docker-compose.codespace.yml ps

# Check logs for all services
docker compose -f docker-compose.codespace.yml logs --tail=50
```

### Database Debugging
```bash
# Connect to database
psql postgresql://myapp_user:myapp_password@localhost:5432/myapp_db

# Check database connection
pg_isready -h localhost -p 5432 -U myapp_user

# View database logs
docker compose -f docker-compose.codespace.yml logs db
```

### Frontend Debugging
```bash
cd frontend

# Check build output
npm run build 2>&1 | tee build.log

# Check dev server output
npm run dev 2>&1 | tee dev.log

# Check network requests
# Open browser dev tools -> Network tab
```

### Backend Debugging
```bash
cd backend

# Run with debug output
FLASK_DEBUG=1 python run.py

# Check Python imports
python -c "
import sys
print('Python path:', sys.path)
try:
    from app import create_app
    print('App import: OK')
except Exception as e:
    print('App import error:', e)
"

# Test API endpoints
curl -X GET http://localhost:5000/api/health
```

## 📞 Getting Help

### 1. Check the Logs
Always start by checking logs for error messages:
```bash
# Application logs
docker compose -f docker-compose.codespace.yml logs

# System logs (if available)
journalctl --user --since "1 hour ago"

# VS Code logs
# Help -> Toggle Developer Tools -> Console
```

### 2. Environment Information
Collect environment information:
```bash
# System info
uname -a
cat /etc/os-release

# Software versions
docker --version
docker compose version
node --version
python3 --version
pip --version

# Codespace info (if applicable)
echo "Codespace: $CODESPACE_NAME"
echo "Domain: $GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
```

### 3. Create a Support Issue

When creating an issue, include:

1. **Error message** (exact text)
2. **Steps to reproduce** the problem
3. **Environment info** (from commands above)
4. **Logs** (relevant sections)
5. **What you expected** to happen
6. **What actually happened**

### 4. Emergency Reset

If everything is broken:
```bash
# Nuclear option: recreate everything
docker compose -f docker-compose.codespace.yml down -v
docker system prune -a -f
rm -rf frontend/node_modules frontend/package-lock.json
rm -rf backend/__pycache__

# Re-run setup
./.devcontainer/setup.sh
```

## 🛠️ Performance Tips

### Codespace Performance
- Use prebuilds for faster startup
- Keep only necessary extensions installed
- Close unused tabs and terminals
- Monitor resource usage

### Development Performance
- Use `npm run dev` for frontend hot reloading
- Use `FLASK_DEBUG=1` for backend auto-reload
- Keep database containers running between sessions
- Use volume mounts for faster file sync

## 🔐 Security Notes

### Development Secrets
- Never commit real secrets to git
- Use development-only secrets in Codespaces
- Rotate production secrets regularly
- Use environment-specific configurations

### Codespace Security
- Codespaces automatically expire
- Use private repositories for sensitive code
- Review code before committing from Codespaces
- Understand Codespace access permissions

---

**Still having issues?** 
- Check the [main README](README.md)
- Review the [Codespace Guide](CODESPACE_GUIDE.md)
- Create an issue in the repository
- Contact the development team
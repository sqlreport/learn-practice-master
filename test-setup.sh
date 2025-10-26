#!/bin/bash
set -e

echo "🧪 Testing Codespace Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test 1: Check if we're in a Codespace
print_status "Checking Codespace environment..."
if [[ -n "$CODESPACE_NAME" ]]; then
    print_success "Running in GitHub Codespace: $CODESPACE_NAME"
else
    print_warning "Not running in a Codespace (local development)"
fi

# Test 2: Check Docker
print_status "Checking Docker..."
if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    docker --version
else
    print_error "Docker is not installed"
    exit 1
fi

# Test 3: Check Docker Compose
print_status "Checking Docker Compose..."
if docker compose version &> /dev/null; then
    print_success "Docker Compose is available"
    docker compose version
else
    print_error "Docker Compose is not available"
    exit 1
fi

# Test 4: Check Node.js
print_status "Checking Node.js..."
if command -v node &> /dev/null; then
    print_success "Node.js is installed: $(node --version)"
else
    print_error "Node.js is not installed"
    exit 1
fi

# Test 5: Check Python
print_status "Checking Python..."
if command -v python3 &> /dev/null; then
    print_success "Python is installed: $(python3 --version)"
else
    print_error "Python is not installed"
    exit 1
fi

# Test 6: Check environment file
print_status "Checking environment configuration..."
if [[ -f ".env" ]]; then
    print_success "Environment file exists"
else
    print_warning "No .env file found, using defaults"
fi

# Test 7: Test database connection
print_status "Testing database connection..."
if docker compose -f docker-compose.codespace.yml ps db | grep -q "running"; then
    print_success "Database container is running"
    
    # Test connection
    if timeout 10 bash -c 'until pg_isready -h localhost -p 5432 -U myapp_user; do sleep 1; done' 2>/dev/null; then
        print_success "Database is accepting connections"
    else
        print_error "Database is not accepting connections"
    fi
else
    print_warning "Database container is not running"
fi

# Test 8: Check frontend dependencies
print_status "Checking frontend dependencies..."
if [[ -d "frontend/node_modules" ]]; then
    print_success "Frontend dependencies are installed"
else
    print_warning "Frontend dependencies not installed"
    print_status "Installing frontend dependencies..."
    cd frontend && npm install && cd ..
    print_success "Frontend dependencies installed"
fi

# Test 9: Check backend dependencies
print_status "Checking backend dependencies..."
cd backend
if python3 -c "import flask" 2>/dev/null; then
    print_success "Backend dependencies are available"
else
    print_warning "Backend dependencies not installed"
    print_status "Installing backend dependencies..."
    pip install -r requirements.txt
    print_success "Backend dependencies installed"
fi
cd ..

# Test 10: Test frontend build
print_status "Testing frontend build..."
cd frontend
if npm run build > /dev/null 2>&1; then
    print_success "Frontend builds successfully"
else
    print_error "Frontend build failed"
fi
cd ..

# Test 11: Test backend import
print_status "Testing backend imports..."
cd backend
if python3 -c "from app import create_app; app = create_app(); print('Backend imports successful')" 2>/dev/null; then
    print_success "Backend imports work correctly"
else
    print_error "Backend imports failed"
fi
cd ..

# Test 12: Check VS Code extensions (if in Codespace)
if [[ -n "$CODESPACE_NAME" ]]; then
    print_status "Checking VS Code extensions..."
    if command -v code &> /dev/null; then
        print_success "VS Code CLI is available"
    else
        print_warning "VS Code CLI not available"
    fi
fi

# Test 13: Check port forwarding (if in Codespace)
if [[ -n "$CODESPACE_NAME" ]]; then
    print_status "Codespace URLs:"
    echo "  Frontend: https://${CODESPACE_NAME}-3000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo "  Backend:  https://${CODESPACE_NAME}-5000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo "  Production: https://${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

print_success "✅ Setup test completed!"
echo ""
echo "🚀 Ready to start development!"
echo "   Run: ./start-dev.sh"
echo ""
echo "📖 For more information, see:"
echo "   - CODESPACE_GUIDE.md"
echo "   - README.md"
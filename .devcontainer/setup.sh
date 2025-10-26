#!/bin/bash
set -e

echo "🚀 Setting up development environment in Codespace..."

# Create .env file for Codespace
cat > .env << EOF
# Codespace Environment Variables
DATABASE_URL=postgresql://myapp_user:myapp_password@db:5432/myapp_db
SECRET_KEY=dev-secret-key-for-codespace-$(openssl rand -hex 16)
JWT_SECRET_KEY=dev-jwt-secret-key-for-codespace-$(openssl rand -hex 16)
FLASK_ENV=development
VITE_API_URL=https://\${CODESPACE_NAME}-5000.\${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/api
POSTGRES_PASSWORD=myapp_password
PGADMIN_DEFAULT_EMAIL=admin@codespace.dev
PGADMIN_DEFAULT_PASSWORD=admin123
EOF

echo "📦 Installing Python dependencies..."
cd backend
echo "Attempting to install dependencies..."
if ! pip install -r requirements.txt; then
    echo "⚠️  Primary requirements failed, trying alternative..."
    if ! pip install -r requirements-alternative.txt; then
        echo "⚠️  Alternative requirements failed, installing individually..."
        pip install Flask==2.3.3 Flask-SQLAlchemy==3.0.5 Flask-Migrate==4.0.5 Flask-CORS==4.0.0
        pip install python-dotenv==1.0.0 PyJWT==2.8.0 Werkzeug==2.3.7 gunicorn==21.2.0
        # Try to install PostgreSQL driver
        if ! pip install psycopg2-binary; then
            echo "Installing psycopg3 as fallback..."
            pip install psycopg[binary]
        fi
    fi
fi
cd ..

echo "📦 Installing Node.js dependencies..."
cd frontend
npm install
cd ..

echo "🗄️  Waiting for database to be ready..."
sleep 10

echo "🗄️  Setting up database..."
cd backend
python -c "
from app import create_app, db
app = create_app()
with app.app_context():
    try:
        db.create_all()
        print('✅ Database tables created successfully')
    except Exception as e:
        print(f'❌ Error creating database tables: {e}')
"
cd ..

echo "📝 Creating development scripts..."
cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting development environment..."

# Start backend in background
echo "🐍 Starting Flask backend..."
cd backend
python run.py &
FLASK_PID=$!
cd ..

# Start frontend in background  
echo "⚛️  Starting React frontend..."
cd frontend
npm run dev &
REACT_PID=$!
cd ..

echo "✅ Development servers started!"
echo "📱 Frontend: https://${CODESPACE_NAME}-3000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "🔧 Backend: https://${CODESPACE_NAME}-5000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "🗄️  Database: localhost:5432"

# Wait for Ctrl+C
trap 'echo "🛑 Stopping servers..."; kill $FLASK_PID $REACT_PID 2>/dev/null; exit' INT
wait
EOF

chmod +x start-dev.sh

cat > start-prod.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting production environment..."

# Build frontend
echo "🏗️  Building frontend..."
cd frontend
npm run build
cd ..

# Start production with Docker Compose
echo "🐳 Starting production containers..."
docker-compose up -d --build

echo "✅ Production environment started!"
echo "🌐 Application: https://${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
EOF

chmod +x start-prod.sh

echo "✅ Setup complete! 🎉"
echo ""
echo "📚 Quick start commands:"
echo "  ./start-dev.sh    - Start development servers"
echo "  ./start-prod.sh   - Start production environment"
echo ""
echo "🔗 Useful URLs (will be available after starting):"
echo "  Frontend (dev):  https://\${CODESPACE_NAME}-3000.\${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "  Backend (dev):   https://\${CODESPACE_NAME}-5000.\${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo "  Production app:  https://\${CODESPACE_NAME}-80.\${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
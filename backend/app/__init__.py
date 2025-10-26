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
    
    # Health check endpoint
    @app.route('/api/health')
    def health():
        return {'success': True, 'message': 'API is running'}
    
    return app
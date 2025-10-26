from app import create_app, db
import os

# Create Flask app instance
app = create_app()

# Import models to ensure they are registered with SQLAlchemy
from app.models import User

if __name__ == '__main__':
    with app.app_context():
        # Create database tables
        db.create_all()
    
    # Run the application
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
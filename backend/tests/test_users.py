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

def test_login_user(client):
    # First create a user
    client.post('/api/auth/register', json={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'password123'
    })
    
    # Then login
    response = client.post('/api/auth/login', json={
        'email': 'test@example.com',
        'password': 'password123'
    })
    
    assert response.status_code == 200
    data = response.get_json()
    assert data['success'] is True
    assert 'token' in data['data']

def test_health_endpoint(client):
    response = client.get('/api/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['success'] is True
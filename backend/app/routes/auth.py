from flask import Blueprint, request, jsonify
import jwt
import os
from datetime import datetime, timedelta
from app import db
from app.models.user import User
from app.utils.validators import validate_user_data

bp = Blueprint('auth', __name__)

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'success': False, 'message': 'Email and password are required'}), 400
    
    user = User.query.filter_by(email=data['email']).first()
    
    if user and user.check_password(data['password']):
        # Generate JWT token
        payload = {
            'user_id': user.id,
            'exp': datetime.utcnow() + timedelta(hours=24)
        }
        token = jwt.encode(payload, os.environ.get('JWT_SECRET_KEY', 'jwt-secret-string'), algorithm='HS256')
        
        return jsonify({
            'success': True,
            'data': {
                'token': token,
                'user': user.to_dict()
            },
            'message': 'Login successful'
        })
    
    return jsonify({'success': False, 'message': 'Invalid credentials'}), 401

@bp.route('/register', methods=['POST'])
def register():
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
    
    # Generate JWT token
    payload = {
        'user_id': user.id,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    token = jwt.encode(payload, os.environ.get('JWT_SECRET_KEY', 'jwt-secret-string'), algorithm='HS256')
    
    return jsonify({
        'success': True,
        'data': {
            'token': token,
            'user': user.to_dict()
        },
        'message': 'User created successfully'
    }), 201

@bp.route('/verify', methods=['GET'])
def verify_token():
    token = None
    
    if 'Authorization' in request.headers:
        auth_header = request.headers['Authorization']
        try:
            token = auth_header.split(" ")[1]
        except IndexError:
            return jsonify({'success': False, 'message': 'Token format invalid'}), 401
    
    if not token:
        return jsonify({'success': False, 'message': 'Token is missing'}), 401
    
    try:
        data = jwt.decode(token, os.environ.get('JWT_SECRET_KEY', 'jwt-secret-string'), algorithms=['HS256'])
        user = User.query.get(data['user_id'])
        if user:
            return jsonify({
                'success': True,
                'data': {'user': user.to_dict()},
                'message': 'Token is valid'
            })
        else:
            return jsonify({'success': False, 'message': 'User not found'}), 404
    except jwt.ExpiredSignatureError:
        return jsonify({'success': False, 'message': 'Token has expired'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'success': False, 'message': 'Token is invalid'}), 401
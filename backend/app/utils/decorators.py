from functools import wraps
from flask import request, jsonify
import jwt
import os

def jwt_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # JWT is passed in the request header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer <token>
            except IndexError:
                return jsonify({'success': False, 'message': 'Token format invalid'}), 401
        
        # Return 401 if token is not passed
        if not token:
            return jsonify({'success': False, 'message': 'Token is missing'}), 401
        
        try:
            # Decoding the payload to fetch the stored details
            data = jwt.decode(token, os.environ.get('JWT_SECRET_KEY', 'jwt-secret-string'), algorithms=['HS256'])
            current_user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'success': False, 'message': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'success': False, 'message': 'Token is invalid'}), 401
        
        # Pass the current user id to the routes
        return f(current_user_id, *args, **kwargs)
    
    return decorated
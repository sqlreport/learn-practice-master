from flask import Blueprint, request, jsonify
from app import db
from app.models.user import User
from app.utils.decorators import jwt_required
from app.utils.validators import validate_user_data

bp = Blueprint('users', __name__)

@bp.route('/', methods=['GET'])
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    # Limit per_page to prevent abuse
    per_page = min(per_page, 100)
    
    users = User.query.paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'success': True,
        'data': {
            'items': [user.to_dict() for user in users.items],
            'total': users.total,
            'page': page,
            'perPage': per_page,
            'totalPages': users.pages
        }
    })

@bp.route('/', methods=['POST'])
@jwt_required
def create_user(current_user_id):
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
    
    return jsonify({
        'success': True,
        'data': user.to_dict(),
        'message': 'User created successfully'
    }), 201

@bp.route('/<int:user_id>', methods=['GET'])
@jwt_required
def get_user(current_user_id, user_id):
    user = User.query.get_or_404(user_id)
    return jsonify({
        'success': True,
        'data': user.to_dict()
    })

@bp.route('/<int:user_id>', methods=['PUT'])
@jwt_required
def update_user(current_user_id, user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # Users can only update their own profile
    if current_user_id != user_id:
        return jsonify({'success': False, 'message': 'Permission denied'}), 403
    
    # Update fields if provided
    if 'username' in data:
        # Check if username is already taken by another user
        existing_user = User.query.filter_by(username=data['username']).first()
        if existing_user and existing_user.id != user_id:
            return jsonify({'success': False, 'message': 'Username already exists'}), 409
        user.username = data['username']
    
    if 'email' in data:
        # Check if email is already taken by another user
        existing_user = User.query.filter_by(email=data['email']).first()
        if existing_user and existing_user.id != user_id:
            return jsonify({'success': False, 'message': 'Email already exists'}), 409
        user.email = data['email']
    
    if 'password' in data:
        user.set_password(data['password'])
    
    db.session.commit()
    
    return jsonify({
        'success': True,
        'data': user.to_dict(),
        'message': 'User updated successfully'
    })

@bp.route('/<int:user_id>', methods=['DELETE'])
@jwt_required
def delete_user(current_user_id, user_id):
    user = User.query.get_or_404(user_id)
    
    # Users can only delete their own profile
    if current_user_id != user_id:
        return jsonify({'success': False, 'message': 'Permission denied'}), 403
    
    db.session.delete(user)
    db.session.commit()
    
    return jsonify({
        'success': True,
        'message': 'User deleted successfully'
    })
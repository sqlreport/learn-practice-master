import re

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password):
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    if not re.search(r'[A-Za-z]', password):
        return False, "Password must contain at least one letter"
    if not re.search(r'\d', password):
        return False, "Password must contain at least one digit"
    return True, "Password is valid"

def validate_username(username):
    if len(username) < 3:
        return False, "Username must be at least 3 characters long"
    if len(username) > 80:
        return False, "Username must be less than 80 characters"
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        return False, "Username can only contain letters, numbers, and underscores"
    return True, "Username is valid"

def validate_user_data(data):
    errors = []
    
    # Check required fields
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if field not in data or not data[field]:
            errors.append(f"{field} is required")
    
    if errors:
        return errors
    
    # Validate email
    if not validate_email(data['email']):
        errors.append("Invalid email format")
    
    # Validate username
    is_valid, message = validate_username(data['username'])
    if not is_valid:
        errors.append(message)
    
    # Validate password
    is_valid, message = validate_password(data['password'])
    if not is_valid:
        errors.append(message)
    
    return errors
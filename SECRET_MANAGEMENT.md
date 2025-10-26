# 🔐 Secret Management with Git-Secret

This project uses [git-secret](https://git-secret.io/) to securely manage sensitive configuration data like database passwords, API keys, and other secrets.

## 🚀 Quick Start

### Prerequisites
- Git-secret installed (`sudo apt install git-secret` on Ubuntu/Debian)
- GPG key configured in your system

### Using the Secrets Management Script

We provide a convenient script to manage secrets:

```bash
# Show all available commands
./scripts/secrets-manage.sh help

# Decrypt secret files (for development/deployment)
./scripts/secrets-manage.sh reveal

# Encrypt secret files (before committing)
./scripts/secrets-manage.sh hide

# Load development environment
./scripts/secrets-manage.sh load-dev

# Load production environment  
./scripts/secrets-manage.sh load-prod

# Edit encrypted files safely
./scripts/secrets-manage.sh edit .env.production

# Check git-secret status
./scripts/secrets-manage.sh status
```

## 🔧 Manual Git-Secret Commands

If you prefer using git-secret directly:

```bash
# Initialize git-secret (already done)
git secret init

# Add your GPG key (replace with your email)
git secret tell your-email@example.com

# Add files to be encrypted
git secret add .env.production .env.development

# Encrypt files
git secret hide

# Decrypt files
git secret reveal

# List encrypted files
git secret list

# Show who can decrypt
git secret whoknows
```

## 📁 Secret Files

The following files contain sensitive data and are encrypted:

- `.env.production` - Production environment variables
- `.env.development` - Development environment variables

Their encrypted versions (`.env.production.secret`, `.env.development.secret`) are committed to git.

## 🛡️ Security Best Practices

1. **Never commit decrypted `.env.*` files** - they're in `.gitignore`
2. **Always encrypt before committing**: `./scripts/secrets-manage.sh hide`
3. **Use strong, unique passwords for production**
4. **Rotate secrets regularly**
5. **Keep your GPG key secure and backed up**

## 🚀 Deployment Workflow

### Development
```bash
# 1. Decrypt secrets
./scripts/secrets-manage.sh reveal

# 2. Start development environment
docker-compose -f docker-compose.app.dev.yml --env-file .env.development up -d
```

### Production
```bash
# 1. Decrypt secrets
./scripts/secrets-manage.sh reveal

# 2. Update production secrets (IMPORTANT!)
./scripts/secrets-manage.sh edit .env.production

# 3. Deploy
docker-compose -f docker-compose.app.yml --env-file .env.production up -d

# 4. Clean up (remove decrypted files on server)
rm .env.production .env.development
```

## 🔑 Initial Setup (for new team members)

1. **Get access to the project**:
   ```bash
   git clone <repository>
   cd <project>
   ```

2. **Install git-secret**:
   ```bash
   sudo apt install git-secret  # Ubuntu/Debian
   # or
   brew install git-secret      # macOS
   ```

3. **Generate GPG key** (if you don't have one):
   ```bash
   gpg --full-generate-key
   ```

4. **Send your public key to admin**:
   ```bash
   gpg --armor --export your-email@example.com
   ```

5. **Admin adds you**:
   ```bash
   git secret tell your-email@example.com
   git secret hide
   git add .gitsecret/keys/pubring.kbx
   git commit -m "Add new team member to secrets"
   ```

6. **You can now decrypt secrets**:
   ```bash
   ./scripts/secrets-manage.sh reveal
   ```

## ⚠️ Important Notes

- **Production secrets**: Change all default passwords in `.env.production` before deploying
- **Backup your GPG key**: Store it securely - you'll need it to decrypt secrets
- **Team coordination**: When secrets change, all team members need to pull and re-decrypt
- **Emergency access**: Keep encrypted backups of production secrets outside git

## 🔧 Environment Variables Reference

### Database
- `DATABASE_URL` - PostgreSQL connection string
- `POSTGRES_PASSWORD` - Database password

### Flask Security
- `SECRET_KEY` - Flask session encryption key
- `JWT_SECRET_KEY` - JWT token signing key

### Admin Tools
- `PGADMIN_DEFAULT_EMAIL` - pgAdmin login email
- `PGADMIN_DEFAULT_PASSWORD` - pgAdmin login password

### Frontend
- `VITE_API_URL` - API endpoint for frontend

## 🆘 Troubleshooting

### Cannot decrypt secrets
```bash
# Check if your GPG key is in the keyring
git secret whoknows

# Check GPG keys
gpg --list-secret-keys

# Re-add your key if needed
git secret tell your-email@example.com
```

### Missing encrypted files
```bash
# Check which files should be encrypted
git secret list

# Re-encrypt if needed
git secret hide
```

### Wrong permissions
```bash
# Fix script permissions
chmod +x scripts/secrets-manage.sh
```
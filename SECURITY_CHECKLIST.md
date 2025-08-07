# 🔒 Surge Security Checklist

## Pre-Deployment Security Validation

Run this checklist before every deployment to ensure security compliance:

### 🚨 Critical Checks (Must Pass)

- [ ] **No SSH Private Keys**: `ls data/id_ed25519* 2>/dev/null` should return empty
- [ ] **Environment File Exists**: `.env` file is present and configured
- [ ] **No Default Passwords**: No instances of `tegbzn6789`, `admin`, or `password123`
- [ ] **API Keys Configured**: Required API tokens are set in `.env`

**Quick Validation:**
```bash
./scripts/security-validate.sh
```

### 🔍 Configuration Security

#### Required Environment Variables
```bash
# Media & Downloads
DATA_ROOT=/your/secure/path
STORAGE_PATH=/your/secure/path

# Service Authentication  
RD_API_TOKEN=your_real_debrid_token
PLEX_TOKEN=your_plex_token
TMDB_API_KEY=your_tmdb_key

# Secure Passwords (Generate unique passwords)
NZBGET_PASS=<16+ character random password>
ADMIN_PASSWORD=<strong unique password>
CINESYNC_PASSWORD=<strong unique password>
```

#### Security-First Defaults
All services use secure defaults:
- ✅ Environment variable injection
- ✅ No hardcoded credentials  
- ✅ API key auto-discovery
- ✅ Secure password generation fallbacks

### 🛡️ Infrastructure Security

#### Docker Security
- [ ] **Non-root User**: Services run as PUID/PGID (not root)
- [ ] **Network Isolation**: Services use internal Docker networks
- [ ] **Volume Mounts**: Only necessary paths are mounted
- [ ] **Port Exposure**: Only required ports are exposed

#### File Permissions
```bash
# Verify secure file permissions
find . -name "*.sh" -exec chmod 755 {} \;
find . -name "*.py" -exec chmod 755 {} \;
chmod 600 .env  # Environment file should be private
```

### 🔄 Ongoing Security Maintenance

#### Weekly Checks
- [ ] Run `./scripts/security-validate.sh`
- [ ] Check for service updates
- [ ] Review access logs
- [ ] Validate API key rotation needs

#### Monthly Reviews  
- [ ] Update service containers
- [ ] Review environment variables
- [ ] Check for new security recommendations
- [ ] Test backup/restore procedures

#### Security Incident Response
1. **Suspected Compromise**:
   ```bash
   # Stop all services immediately
   ./surge stop
   
   # Check logs for suspicious activity
   docker-compose logs --since=24h | grep -i "error\|fail\|unauthorized"
   
   # Rotate all API keys and passwords
   # Update .env with new credentials
   ```

2. **API Key Rotation**:
   ```bash
   # Generate new API keys from service web interfaces
   # Update .env file
   # Restart affected services
   ./surge restart
   ```

### 🚀 Production Deployment Security

#### Before First Deployment
- [ ] Change ALL default passwords
- [ ] Configure proper firewall rules
- [ ] Set up SSL/TLS certificates (if exposing externally)
- [ ] Configure backup encryption
- [ ] Document recovery procedures

#### Network Security
```bash
# Internal network only (recommended)
INTERNAL_NETWORK=surge-internal

# If external access needed, use reverse proxy with:
# - SSL termination
# - Rate limiting  
# - Authentication
# - Access logging
```

### 📋 Security Tools Integration

#### Git Hooks (Recommended)
```bash
# Pre-commit hook to prevent secrets
#!/bin/bash
# .git/hooks/pre-commit

# Check for potential secrets
if git diff --cached --name-only | xargs grep -l "BEGIN.*PRIVATE KEY\|api_key.*=.*[a-zA-Z0-9]{20}\|password.*=.*[a-zA-Z]"; then
    echo "❌ Potential secrets detected in commit"
    echo "Review changes and use environment variables instead"
    exit 1
fi
```

#### Automated Security Scanning
```bash
# Add to CI/CD pipeline
./scripts/security-validate.sh
if [ $? -ne 0 ]; then
    echo "❌ Security validation failed"
    exit 1
fi
```

### 🎯 Security Score Targets

**Production Ready**: 95/100+
- No critical vulnerabilities
- All passwords are unique and strong
- All API keys use environment variables
- Regular security updates applied

**Current Status**: Run `./scripts/security-validate.sh` for real-time status

### 📞 Security Contacts

- **Security Issues**: Create GitHub issue with `security` label
- **Emergency Response**: Follow incident response plan
- **Updates**: Monitor GitHub releases for security patches

---

## ✅ Quick Security Commands

```bash
# Daily security check
./scripts/security-validate.sh

# Generate new secure passwords
python3 -c "import secrets, string; print(''.join(secrets.choice(string.ascii_letters + string.digits + '!@#$%^&*') for _ in range(16)))"

# Check for exposed secrets
grep -r "api_key\|password\|secret\|token" --exclude-dir=.git --exclude="*.md" .

# Verify file permissions
find . -name ".env*" -exec ls -la {} \;

# Test service connectivity (should require authentication)
curl -s http://localhost:7878/api/v3/system/status || echo "✅ Service requires authentication"
```

**Remember**: Security is not a one-time setup - it requires ongoing attention and regular updates.

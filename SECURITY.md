# 🔒 Security Guidelines

This document outlines security best practices and guidelines for the Surge project.

## 🛡️ Security Features

### Environment Variable Protection
- **All sensitive data** (API keys, tokens, passwords) is stored in `.env` files
- **No hardcoded credentials** in any configuration or code files
- **Template-based configuration** with variable substitution

### Access Control
- **Service isolation** through Docker networking
- **Configurable authentication** for web interfaces
- **Optional password protection** for sensitive services

### Data Protection
- **Encrypted storage** support for media servers
- **Secure volume mounting** with proper permissions
- **Backup encryption** options available

## 🔧 Security Configuration

### Required Environment Variables

```bash
# API Keys (Required for respective services)
RD_API_TOKEN=your_real_debrid_token
TMDB_API_KEY=your_tmdb_key
PLEX_TOKEN=your_plex_token

# Strong Passwords (Change defaults!)
ADMIN_PASSWORD=YourSecurePassword123!
CINESYNC_PASSWORD=YourCineSyncPassword123!
NZBGET_PASSWORD=YourNZBGetPassword123!

# Security Settings
CINESYNC_AUTH_ENABLED=true
```

### Network Security
- All services run on internal Docker network
- Only essential ports are published to host
- Services communicate internally using service names

## ⚠️ Security Warnings

### Do NOT:
- **Commit `.env` files** to version control
- **Share API keys or tokens** publicly
- **Use default passwords** in production
- **Expose all ports** to external networks
- **Run with root privileges** unnecessarily

### Do:
- **Use strong, unique passwords**
- **Regularly rotate API keys**
- **Monitor access logs**
- **Keep containers updated**
- **Use HTTPS when available**

## 🔍 Security Audit

### Regular Security Checks:

```bash
# Check for exposed secrets
grep -r "token\|key\|password" . --exclude-dir=.git --exclude="*.md"

# Verify no sensitive files in git
git status --ignored

# Check container vulnerabilities
docker scan surge-plex

# Review running processes
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

### File Permissions
```bash
# Set proper permissions for config directories
chmod 750 ${STORAGE_PATH}/*/config
chmod 600 ${STORAGE_PATH}/*/.env

# SSH keys (if used)
chmod 600 data/id_*
```

## 📝 Incident Response

If you suspect a security breach:

1. **Immediately rotate all API keys and tokens**
2. **Check access logs** for suspicious activity
3. **Update all passwords**
4. **Review container configurations**
5. **Scan for malware** on host system

## 🔄 Updates and Patches

- **Monitor security advisories** for all used containers
- **Update containers regularly** using `./surge update`
- **Review changelog** for security-related changes
- **Test updates** in staging environment first

## 📞 Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** create a public issue
2. **Contact maintainers** directly via email
3. **Provide detailed information** about the vulnerability
4. **Allow reasonable time** for response and fix

---

**Remember**: Security is a shared responsibility. Follow these guidelines to keep your Surge deployment secure.

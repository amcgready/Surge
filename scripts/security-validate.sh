#!/bin/bash

# Surge Security Validation Script
# Run this before deployment to check for security issues

echo "🔒 Surge Security Validation"
echo "=============================="

# Check for exposed SSH keys
if ls data/id_ed25519* >/dev/null 2>&1; then
    echo "❌ CRITICAL: SSH private keys found in data/ directory"
    echo "   Run: rm -f data/id_ed25519*"
    exit 1
else
    echo "✅ No SSH keys found in repository"
fi

# Check .env file exists
if [ ! -f .env ]; then
    echo "⚠️  WARNING: No .env file found"
    echo "   Copy .env.example to .env and configure your secrets"
else
    echo "✅ Environment file exists"
    
    # Check for default passwords
    if grep -q "NZBGET_PASS=tegbzn6789" .env; then
        echo "⚠️  WARNING: Default NZBGet password detected"
    fi
    
    if grep -q "ADMIN_PASSWORD=GenerateYourOwnSecurePassword123!" .env; then
        echo "⚠️  WARNING: Example admin password detected"
    fi
fi

# Check for hardcoded secrets in code
echo "🔍 Scanning for potential hardcoded secrets..."
if grep -r "sk-[A-Za-z0-9-]\{20,\}" scripts/ >/dev/null 2>&1; then
    echo "❌ Potential API keys found in scripts"
else
    echo "✅ No obvious API keys found"
fi

echo ""
echo "🎯 Security validation complete"

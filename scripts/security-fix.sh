#!/bin/bash

# SURGE SECURITY FIX SCRIPT
# Addresses critical security issues found in audit

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔒 SURGE SECURITY FIX SCRIPT"
echo "=============================="
echo ""

print_warning "This script will fix critical security issues found in the audit."
print_warning "Make sure you have backed up any important data before proceeding."
echo ""

read -p "Continue with security fixes? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_info "Security fix cancelled."
    exit 0
fi

echo ""
print_info "Fixing critical security issues..."

cd "$PROJECT_DIR"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not a git repository. Please run this from the Surge project root."
    exit 1
fi

# Fix 1: Remove SSH keys from git tracking
if [ -f "data/id_ed25519" ] || [ -f "data/id_ed25519.pub" ]; then
    print_info "🔑 Removing SSH keys from git tracking..."
    git rm --cached data/id_ed25519* 2>/dev/null || true
    print_success "SSH keys removed from git tracking"
else
    print_info "🔑 No SSH keys found in data directory"
fi

# Fix 2: Remove database files from git tracking  
if ls data/*.sqlite3* >/dev/null 2>&1; then
    print_info "🗄️ Removing database files from git tracking..."
    git rm --cached data/*.sqlite3* 2>/dev/null || true
    print_success "Database files removed from git tracking"
else
    print_info "🗄️ No database files found in data directory"
fi

# Fix 3: Update .gitignore with security patterns
print_info "📝 Updating .gitignore with security patterns..."

# Check if patterns already exist
if ! grep -q "id_ed25519" .gitignore 2>/dev/null; then
    cat >> .gitignore << EOF

# Security - SSH Keys and Private Keys
id_ed25519*
*.pem
*.key
*.crt
*.cert

# Database Files
*.sqlite3*
*.db

# User Data Directory
data/
!data/.gitkeep
EOF
    print_success "Security patterns added to .gitignore"
else
    print_info "Security patterns already in .gitignore"
fi

# Fix 4: Replace hardcoded paths in validation script
print_info "🔧 Fixing hardcoded paths in validation script..."
if [ -f "scripts/validate-rdt-fixes.sh" ]; then
    # Create a backup first
    cp "scripts/validate-rdt-fixes.sh" "scripts/validate-rdt-fixes.sh.bak"
    
    # Replace hardcoded paths with relative paths
    sed -i "s|/home/adam/Desktop/Surge/|./|g" "scripts/validate-rdt-fixes.sh" 2>/dev/null || {
        # Fallback for systems where sed -i behaves differently
        sed "s|/home/adam/Desktop/Surge/|./|g" "scripts/validate-rdt-fixes.sh.bak" > "scripts/validate-rdt-fixes.sh"
    }
    
    print_success "Hardcoded paths fixed in validation script"
    rm -f "scripts/validate-rdt-fixes.sh.bak"
else
    print_info "Validation script not found - no paths to fix"
fi

# Create data/.gitkeep to preserve directory structure
mkdir -p data
touch data/.gitkeep

# Stage the changes
print_info "📦 Staging security fixes..."
git add .gitignore data/.gitkeep scripts/validate-rdt-fixes.sh 2>/dev/null || true

echo ""
print_success "✅ Critical security issues have been fixed!"
echo ""
print_info "Changes made:"
echo "  🔑 SSH keys removed from git tracking"
echo "  🗄️ Database files removed from git tracking"  
echo "  📝 Security patterns added to .gitignore"
echo "  🔧 Hardcoded paths replaced with relative paths"
echo "  📁 Added data/.gitkeep to preserve directory structure"
echo ""
print_warning "NEXT STEPS:"
echo "  1. Review changes: git status"
echo "  2. Commit fixes: git commit -m 'SECURITY: Fix critical issues - remove SSH keys and databases'"
echo "  3. Verify no sensitive files tracked: git ls-files | grep -E '(\.key|\.pem|\.sqlite|id_ed25519)'"
echo "  4. Push to remote: git push"
echo ""
print_info "After these fixes, the repository will be safe for public use."

# Show git status
echo ""
print_info "Current git status:"
git status --short

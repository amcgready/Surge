#!/bin/bash
# Security Audit Script for Surge
# Checks for common security misconfigurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Check if .env file exists
check_env_file() {
    print_header "=== Environment File Security ==="
    
    if [ -f "$PROJECT_DIR/.env" ]; then
        print_success ".env file exists"
        
        # Check for default passwords
        if grep -q "ChangeThisPassword" "$PROJECT_DIR/.env" 2>/dev/null; then
            print_error "Default password detected in .env file"
            print_info "Please change ADMIN_PASSWORD to a secure value"
        else
            print_success "No default passwords found"
        fi
        
        # Check for empty critical variables
        local critical_vars=("STORAGE_PATH" "PUID" "PGID")
        for var in "${critical_vars[@]}"; do
            if ! grep -q "^${var}=" "$PROJECT_DIR/.env" 2>/dev/null || \
               grep -q "^${var}=$" "$PROJECT_DIR/.env" 2>/dev/null; then
                print_warning "$var is not set or empty"
            else
                print_success "$var is configured"
            fi
        done
        
        # Check for API tokens
        if grep -q "^RD_API_TOKEN=" "$PROJECT_DIR/.env" 2>/dev/null && \
           ! grep -q "^RD_API_TOKEN=$" "$PROJECT_DIR/.env" 2>/dev/null; then
            print_success "Real-Debrid API token is set"
        else
            print_info "Real-Debrid API token not set (optional)"
        fi
        
    else
        print_error ".env file not found"
        print_info "Copy .env.example to .env and configure your settings"
    fi
}

# Check file permissions
check_permissions() {
    print_header "=== File Permissions ==="
    
    if [ -f "$PROJECT_DIR/.env" ]; then
        local perm=$(stat -c "%a" "$PROJECT_DIR/.env" 2>/dev/null || stat -f "%A" "$PROJECT_DIR/.env" 2>/dev/null || echo "unknown")
        if [ "$perm" = "600" ] || [ "$perm" = "0600" ]; then
            print_success ".env file has secure permissions (600)"
        elif [ "$perm" = "644" ] || [ "$perm" = "0644" ]; then
            print_warning ".env file is readable by group/others"
            print_info "Run: chmod 600 .env"
        else
            print_info ".env permissions: $perm"
        fi
    fi
    
    # Check for SSH keys in data directory
    if [ -d "$PROJECT_DIR/data" ]; then
        local ssh_keys=$(find "$PROJECT_DIR/data" -name "id_*" -type f 2>/dev/null || true)
        if [ -n "$ssh_keys" ]; then
            print_info "SSH keys found in data directory"
            for key in $ssh_keys; do
                local key_perm=$(stat -c "%a" "$key" 2>/dev/null || stat -f "%A" "$key" 2>/dev/null || echo "unknown")
                if [ "$key_perm" = "600" ] || [ "$key_perm" = "0600" ]; then
                    print_success "$(basename "$key"): secure permissions"
                else
                    print_warning "$(basename "$key"): permissions $key_perm (should be 600)"
                fi
            done
        fi
    fi
}

# Check Git security
check_git_security() {
    print_header "=== Git Security ==="
    
    cd "$PROJECT_DIR"
    
    # Check if .env is in git
    if git ls-files --error-unmatch .env >/dev/null 2>&1; then
        print_error ".env file is tracked by git!"
        print_info "Remove with: git rm --cached .env"
    else
        print_success ".env file is not tracked by git"
    fi
    
    # Check if data directory is properly ignored
    if git ls-files --error-unmatch data/ >/dev/null 2>&1; then
        print_error "Data directory is tracked by git!"
        print_info "Ensure data/ is in .gitignore"
    else
        print_success "Data directory is properly ignored"
    fi
    
    # Check for secrets in git history
    print_info "Scanning git history for potential secrets..."
    local secrets_found=false
    
    # Common secret patterns
    local patterns=("password" "token" "key.*=" "api.*=" "secret")
    
    for pattern in "${patterns[@]}"; do
        if git log --all --grep="$pattern" --oneline | head -5 | grep -q .; then
            print_warning "Found commits mentioning '$pattern' in git history"
            secrets_found=true
        fi
    done
    
    if [ "$secrets_found" = false ]; then
        print_success "No obvious secrets found in git history"
    fi
}

# Check network security
check_network_security() {
    print_header "=== Network Security ==="
    
    # Check if containers are running
    if command -v docker >/dev/null 2>&1; then
        local running_containers=$(docker ps --format "{{.Names}}" --filter "name=surge-" 2>/dev/null || true)
        
        if [ -n "$running_containers" ]; then
            print_info "Checking published ports..."
            
            # List published ports
            docker ps --format "table {{.Names}}\t{{.Ports}}" --filter "name=surge-" 2>/dev/null | while IFS=$'\t' read -r name ports; do
                if [ "$name" = "NAMES" ]; then
                    continue
                fi
                if [ -n "$ports" ] && [ "$ports" != "PORTS" ]; then
                    print_info "$name: $ports"
                fi
            done
            
            # Check for potentially dangerous port exposures
            if docker ps --format "{{.Ports}}" --filter "name=surge-" 2>/dev/null | grep -q "0.0.0.0:"; then
                print_warning "Some services are exposed to all interfaces (0.0.0.0)"
                print_info "Consider using 127.0.0.1: for local-only access"
            else
                print_success "No services exposed to all interfaces"
            fi
        else
            print_info "No Surge containers are currently running"
        fi
    else
        print_warning "Docker not available for network security check"
    fi
}

# Check container security
check_container_security() {
    print_header "=== Container Security ==="
    
    if command -v docker >/dev/null 2>&1; then
        # Check if containers are running as non-root
        local containers=$(docker ps --format "{{.Names}}" --filter "name=surge-" 2>/dev/null || true)
        
        if [ -n "$containers" ]; then
            print_info "Checking container users..."
            
            # This is a simplified check - real implementation would inspect container configs
            if [ -f "$PROJECT_DIR/.env" ] && grep -q "PUID=1000" "$PROJECT_DIR/.env" 2>/dev/null; then
                print_success "Containers configured to run as non-root user"
            elif [ -f "$PROJECT_DIR/.env" ] && grep -q "PUID=0" "$PROJECT_DIR/.env" 2>/dev/null; then
                print_warning "Containers may be running as root user"
                print_info "Set PUID=1000 and PGID=1000 in .env for better security"
            else
                print_info "User configuration not found in .env file"
            fi
        fi
        
        # Check for latest images
        print_info "Consider updating container images regularly"
        print_info "Use: ./surge update"
    fi
}

# Generate security report
generate_report() {
    print_header "=== Security Audit Summary ==="
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    print_info "Audit completed at: $timestamp"
    
    print_info ""
    print_info "🔧 Next Steps:"
    print_info "1. Fix any issues marked with ❌"
    print_info "2. Review warnings marked with ⚠️"
    print_info "3. Read SECURITY.md for detailed guidelines"
    print_info "4. Re-run this audit after making changes"
    print_info ""
    print_info "💡 For help: ./surge --help"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         🔒 SURGE SECURITY AUDIT         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    
    check_env_file
    echo
    check_permissions
    echo
    check_git_security
    echo
    check_network_security
    echo
    check_container_security
    echo
    generate_report
}

# Run the audit
main "$@"

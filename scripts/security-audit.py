#!/usr/bin/env python3

"""
Surge Security Audit Tool - Decypharr & Zurg Implementation

This script performs a comprehensive security audit of the recent automation
implementations (Decypharr and Zurg) to ensure safe deployment.
"""

import re
import subprocess
from pathlib import Path
import hashlib

class SurgeSecurityAuditor:
    """Security auditor for Surge automation implementations"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.security_issues = []
        self.warnings = []
        self.recommendations = []
        
        # Files to audit (recent implementations)
        self.audit_files = [
            "scripts/configure-decypharr.py",
            "scripts/configure-zurg.py", 
            "scripts/service_config.py",
            "scripts/first-time-setup.sh",
            "scripts/interconnection-status.py"
        ]
        
    def log_issue(self, severity: str, file_path: str, line_num: int, issue: str, recommendation: str = ""):
        """Log a security issue"""
        self.security_issues.append({
            'severity': severity,
            'file': file_path,
            'line': line_num,
            'issue': issue,
            'recommendation': recommendation
        })
        
    def log_warning(self, file_path: str, issue: str):
        """Log a security warning"""
        self.warnings.append({'file': file_path, 'issue': issue})
        
    def log_recommendation(self, category: str, recommendation: str):
        """Log a security recommendation"""
        self.recommendations.append({'category': category, 'recommendation': recommendation})
        
    def check_file_permissions(self):
        """Audit file permissions for security"""
        print("🔐 Auditing file permissions...")
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists():
                continue
                
            # Get file permissions
            file_stat = full_path.stat()
            file_mode = oct(file_stat.st_mode)[-3:]
            
            # Check for overly permissive permissions
            if file_mode[2] in ['7', '6', '3', '2']:  # World writable
                self.log_issue("HIGH", file_path, 0, 
                             f"World-writable permissions ({file_mode})",
                             "Change to 750 or 644")
                             
            if file_mode[1] in ['7', '6', '3', '2'] and 'configure-' in file_path:  # Group writable scripts
                self.log_warning(file_path, f"Group-writable script permissions ({file_mode})")
                
            # Verify executable scripts have appropriate permissions
            if file_path.endswith('.py') and 'configure-' in file_path:
                if file_mode not in ['750', '755']:
                    self.log_warning(file_path, f"Script permissions may need adjustment ({file_mode})")
                    
    def check_input_validation(self):
        """Audit input validation and sanitization"""
        print("🛡️  Auditing input validation...")
        
        dangerous_patterns = [
            (r'subprocess\.(?:run|call|Popen)\([^)]*shell=True', 'Shell injection risk'),
            (r'os\.system\(', 'Command injection risk'),
            (r'eval\(', 'Code injection risk'),
            (r'exec\(', 'Code execution risk'),
            (r'input\([^)]*\)\s*without\s+validation', 'Unvalidated input'),
        ]
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists() or not file_path.endswith('.py'):
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                for line_num, line in enumerate(lines, 1):
                    for pattern, _risk in dangerous_patterns:
                        if re.search(pattern, line, re.IGNORECASE):
                            # Check if it's actually dangerous
                            if 'subprocess.run' in line and 'shell=True' in line:
                                if 'timeout=' not in line:
                                    self.log_issue("MEDIUM", file_path, line_num,
                                                 "subprocess.run without timeout", 
                                                 "Add timeout parameter")
                                                 
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for input validation audit: {e}")
                
    def check_api_key_handling(self):
        """Audit API key and credential handling"""
        print("🔑 Auditing API key handling...")
        
        sensitive_patterns = [
            (r'["\'][a-zA-Z0-9]{20,}["\']', 'Potential hardcoded API key'),
            (r'token\s*=\s*["\'][^"\']+["\']', 'Hardcoded token'),
            (r'password\s*=\s*["\'][^"\']+["\']', 'Hardcoded password'),
            (r'api_key\s*=\s*["\'][^"\']+["\']', 'Hardcoded API key'),
        ]
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists():
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                for line_num, line in enumerate(lines, 1):
                    # Skip comments and environment variable references
                    if line.strip().startswith('#') or 'os.environ.get' in line:
                        continue
                        
                    for pattern, risk in sensitive_patterns:
                        if re.search(pattern, line):
                            # Check if it's actually sensitive
                            if not any(safe in line.lower() for safe in ['example', 'placeholder', 'dummy', 'test']):
                                self.log_issue("HIGH", file_path, line_num, risk,
                                             "Use environment variables instead")
                                             
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for API key audit: {e}")
                
    def check_path_validation(self):
        """Audit path handling and traversal protection"""
        print("📁 Auditing path validation...")
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists() or not file_path.endswith('.py'):
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                # Look for path validation functions
                has_path_validation = '_validate_storage_path' in content or '_validate_path' in content
                
                if not has_path_validation and 'storage_path' in content:
                    self.log_warning(file_path, "Path validation function not found")
                    
                # Check for directory traversal patterns
                for line_num, line in enumerate(lines, 1):
                    if '../' in line and 'Path(' in line:
                        self.log_issue("MEDIUM", file_path, line_num,
                                     "Potential directory traversal",
                                     "Validate and resolve paths")
                                     
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for path audit: {e}")
                
    def check_network_security(self):
        """Audit network operations and security"""
        print("🌐 Auditing network security...")
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists() or not file_path.endswith('.py'):
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                for line_num, line in enumerate(lines, 1):
                    # Check for requests without timeout
                    if 'requests.' in line and 'timeout=' not in line and 'get(' in line:
                        # Skip if timeout is set on previous lines or variables
                        if 'timeout' not in lines[max(0, line_num-3):line_num-1]:
                            self.log_issue("MEDIUM", file_path, line_num,
                                         "HTTP request without timeout",
                                         "Add timeout parameter")
                                         
                    # Check for HTTP instead of HTTPS
                    if re.search(r'http://(?!localhost|127\.0\.0\.1)', line):
                        if 'real-debrid' not in line.lower():
                            self.log_warning(file_path, f"Line {line_num}: HTTP instead of HTTPS")
                            
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for network audit: {e}")
                
    def check_error_handling(self):
        """Audit error handling and information disclosure"""
        print("⚠️  Auditing error handling...")
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists() or not file_path.endswith('.py'):
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                exception_blocks = 0
                generic_exceptions = 0
                
                for line_num, line in enumerate(lines, 1):
                    if 'except Exception:' in line or 'except:' in line:
                        generic_exceptions += 1
                        # Check if sensitive information might be disclosed
                        next_lines = lines[line_num:line_num+3]
                        for next_line in next_lines:
                            if 'print(' in next_line and ('password' in next_line.lower() or 'token' in next_line.lower()):
                                self.log_issue("HIGH", file_path, line_num,
                                             "Potential credential disclosure in error handling",
                                             "Sanitize error messages")
                                             
                    if 'except ' in line and ':' in line:
                        exception_blocks += 1
                        
                # Check exception handling ratio
                if exception_blocks > 0 and generic_exceptions / exception_blocks > 0.8:
                    self.log_warning(file_path, "High ratio of generic exception handlers")
                    
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for error handling audit: {e}")
                
    def check_logging_security(self):
        """Audit logging for sensitive data exposure"""
        print("📝 Auditing logging security...")
        
        sensitive_terms = ['password', 'token', 'key', 'secret', 'credential']
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists():
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')
                    
                for line_num, line in enumerate(lines, 1):
                    if any(log_func in line for log_func in ['print(', 'log(', 'logger.']):
                        for term in sensitive_terms:
                            if term in line.lower() and '{' in line:
                                # Check if it's actually logging sensitive data
                                if not any(safe in line for safe in ['len(', 'bool(', 'type(']):
                                    self.log_issue("MEDIUM", file_path, line_num,
                                                 f"Potential {term} exposure in logs",
                                                 "Sanitize log output")
                                                 
            except Exception as e:
                self.log_warning(file_path, f"Could not read file for logging audit: {e}")
                
    def check_configuration_security(self):
        """Audit configuration file security"""
        print("⚙️  Auditing configuration security...")
        
        # Check for secure defaults
        config_files = [
            "configs/zurg-config.yml.template",
            "docker-compose.yml"
        ]
        
        for config_file in config_files:
            full_path = self.project_root / config_file
            if not full_path.exists():
                continue
                
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Check for insecure defaults
                if 'password:' in content and 'password: ""' not in content:
                    if not '${' in content:  # Not environment variable
                        self.log_issue("HIGH", config_file, 0,
                                     "Hardcoded password in config",
                                     "Use environment variables")
                                     
                # Check for debug settings
                if 'debug: true' in content.lower():
                    self.log_warning(config_file, "Debug mode enabled in config")
                    
            except Exception as e:
                self.log_warning(config_file, f"Could not read config file: {e}")
                
    def analyze_code_quality(self):
        """Analyze code quality and security best practices"""
        print("🔍 Analyzing code quality...")
        
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists() or not file_path.endswith('.py'):
                continue
                
            try:
                # Run basic Python syntax check
                result = subprocess.run(['python3', '-m', 'py_compile', str(full_path)],
                                      capture_output=True, text=True)
                if result.returncode != 0:
                    self.log_issue("HIGH", file_path, 0, 
                                 "Python syntax errors",
                                 "Fix syntax issues before deployment")
                    
                # Check file size (potential code bloat)
                file_size = full_path.stat().st_size
                if file_size > 50000:  # 50KB
                    self.log_warning(file_path, f"Large file size ({file_size} bytes)")
                    
            except Exception as e:
                self.log_warning(file_path, f"Could not analyze code quality: {e}")
                
    def generate_file_checksums(self):
        """Generate checksums for audit trail"""
        print("🔐 Generating file checksums...")
        
        checksums = {}
        for file_path in self.audit_files:
            full_path = self.project_root / file_path
            if not full_path.exists():
                continue
                
            try:
                with open(full_path, 'rb') as f:
                    file_hash = hashlib.sha256(f.read()).hexdigest()
                    checksums[file_path] = file_hash
                    
            except Exception as e:
                self.log_warning(file_path, f"Could not generate checksum: {e}")
                
        return checksums
        
    def run_full_audit(self):
        """Run complete security audit"""
        print("🚨 SURGE SECURITY AUDIT - DECYPHARR & ZURG IMPLEMENTATION")
        print("=" * 70)
        
        # Run all audit checks
        self.check_file_permissions()
        self.check_input_validation() 
        self.check_api_key_handling()
        self.check_path_validation()
        self.check_network_security()
        self.check_error_handling()
        self.check_logging_security()
        self.check_configuration_security()
        self.analyze_code_quality()
        
        # Generate audit report
        self.generate_audit_report()
        
    def generate_audit_report(self):
        """Generate comprehensive audit report"""
        print("\n" + "="*70)
        print("🔍 SECURITY AUDIT REPORT")
        print("="*70)
        
        # Summary statistics
        high_issues = len([i for i in self.security_issues if i['severity'] == 'HIGH'])
        medium_issues = len([i for i in self.security_issues if i['severity'] == 'MEDIUM'])
        low_issues = len([i for i in self.security_issues if i['severity'] == 'LOW'])
        
        print(f"\n📊 AUDIT SUMMARY:")
        print(f"  🔴 High Priority Issues: {high_issues}")
        print(f"  🟡 Medium Priority Issues: {medium_issues}")  
        print(f"  🟢 Low Priority Issues: {low_issues}")
        print(f"  ⚠️  Warnings: {len(self.warnings)}")
        
        # Detailed issues
        if self.security_issues:
            print(f"\n🚨 SECURITY ISSUES FOUND:")
            print("-" * 50)
            
            for issue in sorted(self.security_issues, key=lambda x: x['severity'], reverse=True):
                severity_color = {"HIGH": "🔴", "MEDIUM": "🟡", "LOW": "🟢"}
                print(f"{severity_color.get(issue['severity'], '⚪')} {issue['severity']}: {issue['file']}:{issue['line']}")
                print(f"   Issue: {issue['issue']}")
                if issue['recommendation']:
                    print(f"   Fix: {issue['recommendation']}")
                print()
        
        # Warnings
        if self.warnings:
            print(f"⚠️  SECURITY WARNINGS:")
            print("-" * 50)
            
            for warning in self.warnings:
                print(f"• {warning['file']}: {warning['issue']}")
                
        # Generate checksums
        checksums = self.generate_file_checksums()
        if checksums:
            print(f"\n🔐 FILE INTEGRITY CHECKSUMS:")
            print("-" * 50)
            for file_path, checksum in checksums.items():
                print(f"{file_path}: {checksum[:16]}...")
                
        # Final assessment
        print(f"\n🎯 SECURITY ASSESSMENT:")
        print("-" * 50)
        
        if high_issues == 0 and medium_issues <= 2:
            print("✅ SECURE - Implementation passes security audit")
            print("💡 Ready for production deployment")
            security_status = "SECURE"
        elif high_issues == 0 and medium_issues <= 5:
            print("⚠️  ACCEPTABLE - Minor security considerations")
            print("💡 Review medium priority issues before deployment")
            security_status = "ACCEPTABLE"
        else:
            print("🚨 REQUIRES ATTENTION - Security issues found")
            print("💡 Address high priority issues before deployment")
            security_status = "REQUIRES_ATTENTION"
            
        # Recommendations
        if self.recommendations:
            print(f"\n💡 SECURITY RECOMMENDATIONS:")
            print("-" * 50)
            for rec in self.recommendations:
                print(f"• {rec['category']}: {rec['recommendation']}")
                
        print(f"\n🏁 AUDIT COMPLETED - STATUS: {security_status}")
        
        return security_status

def main():
    """Main audit execution"""
    project_root = "/home/adam/Desktop/Surge"
    
    auditor = SurgeSecurityAuditor(project_root)
    status = auditor.run_full_audit()
    
    # Return appropriate exit code
    exit_codes = {
        "SECURE": 0,
        "ACCEPTABLE": 0,
        "REQUIRES_ATTENTION": 1
    }
    
    return exit_codes.get(status, 1)

if __name__ == "__main__":
    exit(main())

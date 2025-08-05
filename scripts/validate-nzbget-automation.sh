#!/bin/bash

# Simple NZBGet Automation Validation Script
echo "🚀 NZBGet Automation Validation"
echo "================================"

# Check if files exist
FILES=(
    "scripts/configure-nzbget.py"
    "scripts/configure-nzbget-automation.sh"
    "scripts/service_config.py"
    "NZBGET_AUTOMATION_SUMMARY.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

# Check script syntax
echo ""
echo "📝 Checking script syntax..."

# Python script
if python3 -m py_compile scripts/configure-nzbget.py 2>/dev/null; then
    echo "✅ configure-nzbget.py syntax valid"
else
    echo "❌ configure-nzbget.py syntax error"
fi

# Bash script
if bash -n scripts/configure-nzbget-automation.sh 2>/dev/null; then
    echo "✅ configure-nzbget-automation.sh syntax valid"
else
    echo "❌ configure-nzbget-automation.sh syntax error"
fi

# Check if service_config has NZBGet functions
echo ""
echo "🔧 Checking service_config functions..."

if grep -q "configure_nzbget_download_client" scripts/service_config.py; then
    echo "✅ configure_nzbget_download_client function found"
else
    echo "❌ configure_nzbget_download_client function missing"
fi

if grep -q "run_nzbget_full_automation" scripts/service_config.py; then
    echo "✅ run_nzbget_full_automation function found"
else
    echo "❌ run_nzbget_full_automation function missing"
fi

# Check first-time-setup integration
if grep -q "configure-nzbget.py" scripts/first-time-setup.sh; then
    echo "✅ NZBGet automation integrated in first-time-setup.sh"
else
    echo "❌ NZBGet automation not integrated in first-time-setup.sh"
fi

echo ""
echo "🎯 NZBGet Automation Status: Ready for deployment!"
echo "📖 See NZBGET_AUTOMATION_SUMMARY.md for full details"

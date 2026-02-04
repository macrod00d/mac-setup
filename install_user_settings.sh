#!/bin/bash
# Install macOS user settings from user_settings_full.conf
# Usage: ./install_user_settings.sh [config_file]

set -e

CONFIG="${1:-user_settings_full.conf}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "  macOS User Settings Installer"
echo "============================================"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG" ]; then
    echo -e "${RED}Error: Config file not found: $CONFIG${NC}"
    echo "Run ./export_user_settings.sh first to create it."
    exit 1
fi

# Count settings
total=$(grep -c '^defaults write' "$CONFIG" 2>/dev/null || echo 0)
echo "Found $total settings in $CONFIG"
echo ""

# Confirm
read -p "Apply all settings? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Applying settings..."
echo ""

# Apply each setting
count=0
failed=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Only process defaults write commands
    if [[ "$line" =~ ^defaults\ write ]]; then
        # Extract domain and key for display
        domain=$(echo "$line" | awk '{print $3}')
        key=$(echo "$line" | awk '{print $4}')

        # Execute the command
        if eval "$line" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $domain $key"
            ((count++))
        else
            echo -e "${RED}✗${NC} $domain $key"
            ((failed++))
        fi
    fi
done < "$CONFIG"

echo ""
echo "============================================"
echo -e "Applied: ${GREEN}$count${NC} settings"
if [ $failed -gt 0 ]; then
    echo -e "Failed:  ${RED}$failed${NC} settings"
fi
echo "============================================"
echo ""

# Restart services
echo "Restarting services to apply changes..."
echo ""

# Dock
if killall Dock 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Restarted Dock"
else
    echo -e "${YELLOW}!${NC} Dock not running"
fi

# Finder
if killall Finder 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Restarted Finder"
else
    echo -e "${YELLOW}!${NC} Finder not running"
fi

# SystemUIServer (menu bar)
if killall SystemUIServer 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Restarted SystemUIServer (menu bar)"
else
    echo -e "${YELLOW}!${NC} SystemUIServer not running"
fi

# cfprefsd (preferences daemon)
if killall cfprefsd 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Restarted cfprefsd (preferences cache)"
else
    echo -e "${YELLOW}!${NC} cfprefsd not running"
fi

echo ""
echo "============================================"
echo -e "${GREEN}Done!${NC}"
echo ""
echo "Note: Some settings may require logging out"
echo "and back in to take full effect."
echo "============================================"

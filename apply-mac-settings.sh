#!/bin/bash

usage() {
    echo "Usage: $0 <config.txt> [-n]"
    echo ""
    echo "Applies mac settings from a config file"
    echo "  -n  Dry run (show commands without executing)"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

config_file="$1"
dry_run=false

if [[ "$2" == "-n" ]]; then
    dry_run=true
fi

if [[ ! -f "$config_file" ]]; then
    echo "Error: $config_file not found"
    exit 1
fi

count=0
errors=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    # Parse domain:key = value
    domain=$(echo "$line" | sed 's/:\([^:]*\) = .*//')
    key=$(echo "$line" | sed 's/.*:\([^:]*\) = .*/\1/')
    value=$(echo "$line" | sed 's/.* = //')

    # Determine value type and build command
    if [[ "$value" == "true" ]]; then
        cmd="defaults write \"$domain\" \"$key\" -bool true"
    elif [[ "$value" == "false" ]]; then
        cmd="defaults write \"$domain\" \"$key\" -bool false"
    elif [[ "$value" =~ ^-?[0-9]+$ ]]; then
        cmd="defaults write \"$domain\" \"$key\" -int $value"
    elif [[ "$value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
        cmd="defaults write \"$domain\" \"$key\" -float $value"
    else
        # Escape quotes in string values
        escaped_value=$(echo "$value" | sed 's/"/\\"/g')
        cmd="defaults write \"$domain\" \"$key\" -string \"$escaped_value\""
    fi

    if [[ "$dry_run" == true ]]; then
        echo "$cmd"
    else
        if eval "$cmd" 2>/dev/null; then
            ((count++))
        else
            echo "Failed: $cmd"
            ((errors++))
        fi
    fi
done < "$config_file"

if [[ "$dry_run" == true ]]; then
    echo ""
    echo "# Dry run complete. Run without -n to apply."
else
    echo ""
    echo "Applied $count settings ($errors errors)"
    echo ""
    echo "Restarting affected services..."
    killall Dock 2>/dev/null
    killall Finder 2>/dev/null
    killall SystemUIServer 2>/dev/null
    echo "Done!"
fi

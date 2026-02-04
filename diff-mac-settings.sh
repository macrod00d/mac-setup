#!/bin/bash

usage() {
    echo "Usage: $0 <vanilla.txt> <current.txt> [-o config.txt]"
    echo ""
    echo "Compares two mac settings files and outputs a config file"
    echo "  -o filename  Output config file (default: mac_settings.conf)"
    echo ""
    echo "Then run: ./apply-mac-settings.sh mac_settings.conf"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

vanilla="$1"
current="$2"
shift 2

output_file="mac_settings.conf"

while getopts "o:" opt; do
    case $opt in
        o) output_file="$OPTARG" ;;
        *) usage ;;
    esac
done

if [[ ! -f "$vanilla" ]]; then
    echo "Error: $vanilla not found"
    exit 1
fi

if [[ ! -f "$current" ]]; then
    echo "Error: $current not found"
    exit 1
fi

{
    echo "# Mac Settings Configuration"
    echo "# Generated: $(date)"
    echo "#"
    echo "# Review these settings and comment out any you don't want to apply"
    echo "# Format: domain:key = value"
    echo "# Lines starting with # are ignored"
    echo ""

    current_domain=""

    # Find lines only in current (added/changed)
    comm -13 <(sort "$vanilla") <(sort "$current") | while IFS= read -r line; do
        domain=$(echo "$line" | cut -d: -f1)

        # Add section header when domain changes
        if [[ "$domain" != "$current_domain" ]]; then
            echo ""
            echo "# ----------------------------------------"
            echo "# $domain"
            echo "# ----------------------------------------"
            current_domain="$domain"
        fi

        echo "$line"
    done
} > "$output_file"

count=$(grep -v '^#' "$output_file" | grep -v '^$' | wc -l | tr -d ' ')
echo "Generated $output_file with $count settings"
echo "Review the file, then run: ./apply-mac-settings.sh $output_file"

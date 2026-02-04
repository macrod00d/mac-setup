#!/bin/bash

output_file=""
save_to_file=false

usage() {
    echo "Usage: $0 [-o [filename]]"
    echo "  -o [filename]  Save output to file (default: mac_defaults.txt)"
    echo ""
    echo "Outputs flat key=value format for easy diffing"
    exit 1
}

while getopts "oh" opt; do
    case $opt in
        o) save_to_file=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))
if [[ "$save_to_file" == true ]]; then
    output_file="${1:-mac_defaults.txt}"
fi

collect_defaults() {
    # Get ALL domains
    defaults domains 2>/dev/null | tr ',' '\n' | sed 's/^ *//' | while IFS= read -r domain; do
        [[ -z "$domain" ]] && continue

        # Get all keys for this domain
        keys=$(defaults read "$domain" 2>/dev/null | grep -E '^ {4}[a-zA-Z0-9"_-]' | sed 's/^ *//; s/ =.*//' | tr -d '"')

        if [[ -n "$keys" ]]; then
            while IFS= read -r key; do
                [[ -z "$key" ]] && continue
                value=$(defaults read "$domain" "$key" 2>/dev/null)
                # Flatten multiline values to single line
                value=$(echo "$value" | tr '\n' ' ' | sed 's/  */ /g; s/^ //; s/ $//')
                echo "${domain}:${key} = ${value}"
            done <<< "$keys"
        fi
    done | sort
}

if [[ "$save_to_file" == true ]]; then
    collect_defaults > "$output_file"
    echo "Saved to $output_file"
else
    collect_defaults
fi

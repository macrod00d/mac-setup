#!/bin/bash

# Homebrew Installation Script
# Usage: ./brew.sh [-m|--mishcas-stuff]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/packages.conf"
LOG_FILE="$SCRIPT_DIR/brew_install_log.txt"

# Parse arguments
INCLUDE_MISHCA=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--mishcas-stuff)
      INCLUDE_MISHCA=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./brew.sh [-m|--mishcas-stuff]"
      echo ""
      echo "Options:"
      echo "  -m, --mishcas-stuff  Include packages marked with @mishca"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Edit packages.conf to customize which packages to install."
      echo "Comment out lines with # to skip them."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information."
      exit 1
      ;;
  esac
done

# Check config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Clear previous log file
> "$LOG_FILE"

echo "Starting Homebrew installation script..." | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Include @mishca packages: $INCLUDE_MISHCA" | tee -a "$LOG_FILE"

# Parse config file and extract packages for a given section
parse_section() {
  local section="$1"
  local in_section=false
  local packages=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim whitespace
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Skip comments
    [[ "$line" =~ ^# ]] && continue

    # Check for section headers
    if [[ "$line" =~ ^\[.*\]$ ]]; then
      if [[ "$line" == "[$section]" ]]; then
        in_section=true
      else
        in_section=false
      fi
      continue
    fi

    # Process lines in our section
    if $in_section; then
      # Check if line has @mishca flag
      local has_mishca=false
      if [[ "$line" =~ @mishca ]]; then
        has_mishca=true
        # Remove @mishca and any trailing comment
        line=$(echo "$line" | sed 's/@mishca.*//' | sed 's/[[:space:]]*$//')
      else
        # Remove any trailing comment
        line=$(echo "$line" | sed 's/#.*//' | sed 's/[[:space:]]*$//')
      fi

      # Skip empty after processing
      [[ -z "$line" ]] && continue

      # Include package based on mishca flag
      if $has_mishca; then
        if $INCLUDE_MISHCA; then
          packages+=("$line")
        fi
      else
        packages+=("$line")
      fi
    fi
  done < "$CONFIG_FILE"

  echo "${packages[@]}"
}

# Install formulae
install_formulae() {
  local formulae
  read -ra formulae <<< "$(parse_section "formulae")"

  if [[ ${#formulae[@]} -eq 0 ]]; then
    echo "No formulae to install." | tee -a "$LOG_FILE"
    return
  fi

  echo -e "\n--- Installing Homebrew Formulae (${#formulae[@]} packages) ---" | tee -a "$LOG_FILE"
  for formula in "${formulae[@]}"; do
    echo "Installing formula: $formula" | tee -a "$LOG_FILE"
    if brew install "$formula" >> "$LOG_FILE" 2>&1; then
      echo "  Successfully installed: $formula" | tee -a "$LOG_FILE"
    else
      echo "  Failed to install: $formula (See log for details)" | tee -a "$LOG_FILE"
    fi
  done
}

# Install casks
install_casks() {
  local casks
  read -ra casks <<< "$(parse_section "casks")"

  if [[ ${#casks[@]} -eq 0 ]]; then
    echo "No casks to install." | tee -a "$LOG_FILE"
    return
  fi

  echo -e "\n--- Installing Homebrew Casks (${#casks[@]} packages) ---" | tee -a "$LOG_FILE"
  for cask in "${casks[@]}"; do
    echo "Installing cask: $cask" | tee -a "$LOG_FILE"
    if brew install --cask "$cask" >> "$LOG_FILE" 2>&1; then
      echo "  Successfully installed: $cask" | tee -a "$LOG_FILE"
    else
      echo "  Failed to install: $cask (See log for details)" | tee -a "$LOG_FILE"
    fi
  done
}

# Install Mac App Store apps
install_mas() {
  local mas_apps
  read -ra mas_apps <<< "$(parse_section "mas")"

  if [[ ${#mas_apps[@]} -eq 0 ]]; then
    echo "No Mac App Store apps to install." | tee -a "$LOG_FILE"
    return
  fi

  # Check if mas is installed
  if ! command -v mas &> /dev/null; then
    echo "Warning: 'mas' not installed, skipping Mac App Store apps." | tee -a "$LOG_FILE"
    return
  fi

  echo -e "\n--- Installing Mac App Store Apps (${#mas_apps[@]} apps) ---" | tee -a "$LOG_FILE"
  for app in "${mas_apps[@]}"; do
    echo "Installing Mac App Store app: $app" | tee -a "$LOG_FILE"
    if mas install "$app" >> "$LOG_FILE" 2>&1; then
      echo "  Successfully installed: $app" | tee -a "$LOG_FILE"
    else
      echo "  Failed to install: $app (See log for details)" | tee -a "$LOG_FILE"
    fi
  done
}

# Main installation
install_formulae
install_casks
install_mas

echo -e "\n--- Installation process completed ---" | tee -a "$LOG_FILE"
echo "Review '$LOG_FILE' for details on any skipped or failed installations." | tee -a "$LOG_FILE"

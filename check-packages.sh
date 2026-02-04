#!/bin/bash

# Check for new packages not in packages.conf
# Usage: ./check-packages.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/packages.conf"

# Check config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Extract all package names from a section (ignoring comments and @mishca flags)
get_config_packages() {
  local section="$1"
  local in_section=false

  while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[.*\]$ ]]; then
      [[ "$line" == "[$section]" ]] && in_section=true || in_section=false
      continue
    fi

    if $in_section; then
      # Extract just the package name (before any @, #, or whitespace)
      echo "$line" | sed 's/[[:space:]]*[@#].*//' | sed 's/[[:space:]]*$//'
    fi
  done < "$CONFIG_FILE"
}

# Check if mas is installed, prompt to install if not
check_mas() {
  if ! command -v mas &> /dev/null; then
    echo "mas (Mac App Store CLI) is not installed."
    read -p "Install mas now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Installing mas..."
      brew install mas
    else
      echo "Skipping Mac App Store check."
      return 1
    fi
  fi
  return 0
}

echo "Checking for packages not in packages.conf..."
echo ""

# --- Formulae ---
echo "Fetching installed formulae (top-level only)..."
installed_formulae=$(brew leaves 2>/dev/null | sort)
config_formulae=$(get_config_packages "formulae" | sort)

missing_formulae=()
while IFS= read -r formula; do
  [[ -z "$formula" ]] && continue
  if ! echo "$config_formulae" | grep -qx "$formula"; then
    missing_formulae+=("$formula")
  fi
done <<< "$installed_formulae"

# --- Casks ---
echo "Fetching installed casks..."
installed_casks=$(brew list --cask 2>/dev/null | sort)
config_casks=$(get_config_packages "casks" | sort)

missing_casks=()
while IFS= read -r cask; do
  [[ -z "$cask" ]] && continue
  if ! echo "$config_casks" | grep -qx "$cask"; then
    missing_casks+=("$cask")
  fi
done <<< "$installed_casks"

# --- Mac App Store ---
missing_mas=()
if check_mas; then
  echo "Fetching installed Mac App Store apps..."
  config_mas=$(get_config_packages "mas" | sort)

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    # Trim leading whitespace and extract ID and name
    line=$(echo "$line" | sed 's/^[[:space:]]*//')
    app_id=$(echo "$line" | awk '{print $1}')
    app_name=$(echo "$line" | awk '{print $2}')
    if ! echo "$config_mas" | grep -qx "$app_id"; then
      missing_mas+=("$app_id  # $app_name")
    fi
  done <<< "$(mas list 2>/dev/null)"
fi

echo ""
echo "=========================================="
echo "  Packages not in packages.conf"
echo "=========================================="

# Print results
if [[ ${#missing_formulae[@]} -eq 0 ]] && [[ ${#missing_casks[@]} -eq 0 ]] && [[ ${#missing_mas[@]} -eq 0 ]]; then
  echo ""
  echo "All installed packages are already in packages.conf!"
  exit 0
fi

if [[ ${#missing_formulae[@]} -gt 0 ]]; then
  echo ""
  echo "[formulae]"
  for f in "${missing_formulae[@]}"; do
    echo "$f"
  done
fi

if [[ ${#missing_casks[@]} -gt 0 ]]; then
  echo ""
  echo "[casks]"
  for c in "${missing_casks[@]}"; do
    echo "$c"
  done
fi

if [[ ${#missing_mas[@]} -gt 0 ]]; then
  echo ""
  echo "[mas]"
  for m in "${missing_mas[@]}"; do
    echo "$m"
  done
fi

echo ""
echo "=========================================="
echo "Copy the packages above into packages.conf"
echo "=========================================="

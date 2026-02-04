#!/bin/bash

# Homebrew Installation Script
# Usage: ./brew.sh [-m|--mishcas-stuff] [-d|--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/packages.conf"
LOG_FILE="$SCRIPT_DIR/brew_install_log.txt"

# Parse arguments
INCLUDE_MISHCA=false
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--mishcas-stuff)
      INCLUDE_MISHCA=true
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: ./brew.sh [-m|--mishcas-stuff] [-d|--dry-run]"
      echo ""
      echo "Options:"
      echo "  -m, --mishcas-stuff  Include packages marked with @mishca"
      echo "  -d, --dry-run        Preview what would be installed without making changes"
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

# Clear previous log file (unless dry run)
if ! $DRY_RUN; then
  > "$LOG_FILE"
fi

echo "Starting Homebrew installation script..."
$DRY_RUN && echo "DRY RUN MODE - No changes will be made"
echo "Include @mishca packages: $INCLUDE_MISHCA"
$DRY_RUN || echo "Log file: $LOG_FILE"

# Fetch all installed packages upfront (much faster than checking one by one)
echo ""
echo -n "Fetching installed packages..."
INSTALLED_FORMULAE=$(brew list --formula 2>/dev/null | tr '\n' ' ')
echo -n "."
INSTALLED_CASKS=$(brew list --cask 2>/dev/null | tr '\n' ' ')
echo -n "."
if command -v mas &> /dev/null; then
  INSTALLED_MAS=$(mas list 2>/dev/null | awk '{print $1}' | tr '\n' ' ')
else
  INSTALLED_MAS=""
fi
echo " done"

# Parse config file and extract packages for a given section
parse_section() {
  local section="$1"
  local in_section=false
  local packages=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[.*\]$ ]]; then
      [[ "$line" == "[$section]" ]] && in_section=true || in_section=false
      continue
    fi

    if $in_section; then
      local has_mishca=false
      if [[ "$line" =~ @mishca ]]; then
        has_mishca=true
        line=$(echo "$line" | sed 's/@mishca.*//' | sed 's/[[:space:]]*$//')
      else
        line=$(echo "$line" | sed 's/#.*//' | sed 's/[[:space:]]*$//')
      fi

      [[ -z "$line" ]] && continue

      if $has_mishca; then
        $INCLUDE_MISHCA && packages+=("$line")
      else
        packages+=("$line")
      fi
    fi
  done < "$CONFIG_FILE"

  echo "${packages[@]}"
}

# Check if package is in installed list
is_installed() {
  local pkg="$1"
  local installed_list="$2"
  [[ " $installed_list " == *" $pkg "* ]]
}

# Print packages in a grid (3 columns)
print_grid() {
  local items=("$@")
  local cols=3
  local col_width=25
  local i=0

  for item in "${items[@]}"; do
    # Trim tap prefix (e.g., microsoft/mssql-release/mssql-tools -> mssql-tools)
    local display_name="${item##*/}"
    printf "    %-${col_width}s" "$display_name"
    ((i++))
    if ((i % cols == 0)); then
      echo ""
    fi
  done
  # Final newline if we didn't just print one
  if ((i % cols != 0)); then
    echo ""
  fi
}

# Install formulae
install_formulae() {
  local formulae
  read -ra formulae <<< "$(parse_section "formulae")"

  if [[ ${#formulae[@]} -eq 0 ]]; then
    echo "No formulae configured."
    return
  fi

  echo ""
  echo "--- Homebrew Formulae (${#formulae[@]} in config) ---"

  local to_install=()
  local already_installed=()

  for formula in "${formulae[@]}"; do
    # Handle tap/formula format (e.g., microsoft/mssql-release/mssql-tools)
    local check_name="${formula##*/}"
    if is_installed "$check_name" "$INSTALLED_FORMULAE"; then
      already_installed+=("$formula")
    else
      to_install+=("$formula")
    fi
  done

  echo "  ✓ Already installed: ${#already_installed[@]}"
  [[ ${#already_installed[@]} -gt 0 ]] && print_grid "${already_installed[@]}"

  if [[ ${#to_install[@]} -eq 0 ]]; then
    echo "  ○ To install: 0"
    return
  fi

  echo "  ○ To install: ${#to_install[@]}"
  print_grid "${to_install[@]}"

  if $DRY_RUN; then
    return
  fi

  echo ""
  echo "Installing formulae..."
  local i=0
  local total=${#to_install[@]}
  for formula in "${to_install[@]}"; do
    ((i++))
    local display_name="${formula##*/}"
    echo -n "  [$i/$total] $display_name "
    if brew install "$formula" >> "$LOG_FILE" 2>&1; then
      echo "✓"
    else
      echo "✗ (see log)"
    fi
  done
}

# Install casks
install_casks() {
  local casks
  read -ra casks <<< "$(parse_section "casks")"

  if [[ ${#casks[@]} -eq 0 ]]; then
    echo "No casks configured."
    return
  fi

  echo ""
  echo "--- Homebrew Casks (${#casks[@]} in config) ---"

  local to_install=()
  local already_installed=()

  for cask in "${casks[@]}"; do
    if is_installed "$cask" "$INSTALLED_CASKS"; then
      already_installed+=("$cask")
    else
      to_install+=("$cask")
    fi
  done

  echo "  ✓ Already installed: ${#already_installed[@]}"
  [[ ${#already_installed[@]} -gt 0 ]] && print_grid "${already_installed[@]}"

  if [[ ${#to_install[@]} -eq 0 ]]; then
    echo "  ○ To install: 0"
    return
  fi

  echo "  ○ To install: ${#to_install[@]}"
  print_grid "${to_install[@]}"

  if $DRY_RUN; then
    return
  fi

  echo ""
  echo "Installing casks..."
  local i=0
  local total=${#to_install[@]}
  for cask in "${to_install[@]}"; do
    ((i++))
    echo -n "  [$i/$total] $cask "
    if brew install --cask "$cask" >> "$LOG_FILE" 2>&1; then
      echo "✓"
    else
      echo "✗ (see log)"
    fi
  done
}

# Install Mac App Store apps
install_mas() {
  local mas_apps
  read -ra mas_apps <<< "$(parse_section "mas")"

  if [[ ${#mas_apps[@]} -eq 0 ]]; then
    echo "No Mac App Store apps configured."
    return
  fi

  if ! command -v mas &> /dev/null; then
    echo ""
    echo "--- Mac App Store Apps ---"
    echo "  ⚠ 'mas' not installed. Run 'brew install mas' first."
    return
  fi

  echo ""
  echo "--- Mac App Store Apps (${#mas_apps[@]} in config) ---"

  local to_install=()
  local already_installed=()

  for app in "${mas_apps[@]}"; do
    if is_installed "$app" "$INSTALLED_MAS"; then
      already_installed+=("$app")
    else
      to_install+=("$app")
    fi
  done

  echo "  ✓ Already installed: ${#already_installed[@]}"
  [[ ${#already_installed[@]} -gt 0 ]] && print_grid "${already_installed[@]}"

  if [[ ${#to_install[@]} -eq 0 ]]; then
    echo "  ○ To install: 0"
    return
  fi

  echo "  ○ To install: ${#to_install[@]}"
  print_grid "${to_install[@]}"

  if $DRY_RUN; then
    return
  fi

  echo ""
  echo "Installing Mac App Store apps..."
  local i=0
  local total=${#to_install[@]}
  for app in "${to_install[@]}"; do
    ((i++))
    echo -n "  [$i/$total] $app "
    if mas install "$app" >> "$LOG_FILE" 2>&1; then
      echo "✓"
    else
      echo "✗ (see log)"
    fi
  done
}

# Main
install_formulae
install_casks
install_mas

echo ""
echo "--- Done ---"
$DRY_RUN && echo "Run without -d to install."
$DRY_RUN || echo "See $LOG_FILE for details."

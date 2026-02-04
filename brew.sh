#!/bin/bash

# Define log file
LOG_FILE="brew_install_log.txt"

# Clear previous log file if it exists
> "$LOG_FILE"

echo "Starting Homebrew installation script..." | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"

# --- Homebrew Formulae ---
FORMULAE=(
  asitop
  azure-cli
  bat
  btop
  bun
  cloudflared
  ffmpeg
  gemini-cli
  gh
  lazygit
  mas
  msodbcsql18
  mssql-tools18
  node
  nvm
  pandoc
  pnpm
  redis
  repomix
  ripgrep
  tesseract
  unixodbc
  uv
  vercel-cli
  weasyprint
  yt-dlp
)

echo -e "\n--- Installing Homebrew Formulae ---" | tee -a "$LOG_FILE"
for formula in "${FORMULAE[@]}"; do
  echo "Attempting to install formula: $formula" | tee -a "$LOG_FILE"
  if brew install "$formula" >> "$LOG_FILE" 2>&1; then
    echo "Successfully installed: $formula" | tee -a "$LOG_FILE"
  else
    echo "Failed to install: $formula (See log for details)" | tee -a "$LOG_FILE"
  fi
done

# --- Homebrew Casks ---
CASKS=(
  alt-tab
  anaconda
  azure-data-studio
  balenaetcher
  bambu-studio
  bentobox
  betterdisplay
  bettertouchtool
  beyond-compare
  bruno
  chatgpt
  citrix-workspace
  claude
  claude-code
  codex
  cursor
  docker
  docker-desktop
  gcloud-cli
  google-chrome
  httpie
  jellyfin
  linearmouse
  lm-studio
  megasync
  microsoft-excel
  microsoft-onenote
  microsoft-outlook
  microsoft-powerpoint
  microsoft-teams
  microsoft-word
  nordvpn
  obsidian
  onedrive
  openscad
  paintbrush
  qbittorrent
  raycast
  redis-insight
  shottr
  sidequest
  signal
  spotify
  steam
  upscayl
  utm
  visual-studio-code
  vlc
  warp
  yaak
  zen-browser
)

echo -e "\n--- Installing Homebrew Casks ---" | tee -a "$LOG_FILE"
for cask in "${CASKS[@]}"; do
  echo "Attempting to install cask: $cask" | tee -a "$LOG_FILE"
  if brew install --cask "$cask" >> "$LOG_FILE" 2>&1; then
    echo "Successfully installed: $cask" | tee -a "$LOG_FILE"
  else
    echo "Failed to install: $cask (See log for details)" | tee -a "$LOG_FILE"
  fi
done

# --- Mac App Store Apps (requires mas) ---
MAS_APPS=(
  "882812218" # Owly - Prevent Display Sleep
)

echo -e "\n--- Installing Mac App Store Apps ---" | tee -a "$LOG_FILE"
for app in "${MAS_APPS[@]}"; do
  echo "Attempting to install Mac App Store app: $app" | tee -a "$LOG_FILE"
  if mas install "$app" >> "$LOG_FILE" 2>&1; then
    echo "Successfully installed: $app" | tee -a "$LOG_FILE"
  else
    echo "Failed to install: $app (See log for details)" | tee -a "$LOG_FILE"
  fi
done

echo -e "\n--- Installation process completed ---" | tee -a "$LOG_FILE"
echo "Review '$LOG_FILE' for details on any skipped or failed installations." | tee -a "$LOG_FILE"
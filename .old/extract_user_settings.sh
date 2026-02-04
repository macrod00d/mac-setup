#!/bin/bash
# Extract meaningful user-configurable settings from mac_settings.conf
# Usage: ./extract_user_settings.sh [input_file] [output_file]

INPUT_FILE="${1:-mac_settings.conf}"
OUTPUT_FILE="${2:-user_settings_clean.conf}"

# Settings to extract (domain:key patterns)
# These are the actually useful, user-configurable settings

cat > "$OUTPUT_FILE" << 'HEADER'
# macOS User Settings - Clean Extract
# These are the meaningful, user-configurable settings
# Apply with: defaults write <domain> <key> <value>
#
# Generated from mac_settings.conf
HEADER

echo "" >> "$OUTPUT_FILE"

# === DOCK ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# DOCK SETTINGS" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^com\.apple\.dock:(autohide|orientation|tilesize|magnification|largesize|mineffect|minimize-to-application|show-recents|showAppExposeGestureEnabled|wvous-)" "$INPUT_FILE" | while read line; do
    key=$(echo "$line" | cut -d: -f2 | cut -d= -f1 | xargs)
    value=$(echo "$line" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        autohide) echo "# Dock auto-hides: $([ "$value" = "1" ] && echo "yes" || echo "no")" >> "$OUTPUT_FILE" ;;
        orientation) echo "# Dock position: $value" >> "$OUTPUT_FILE" ;;
        tilesize) echo "# Dock icon size in pixels" >> "$OUTPUT_FILE" ;;
        magnification) echo "# Dock magnification: $([ "$value" = "1" ] && echo "enabled" || echo "disabled")" >> "$OUTPUT_FILE" ;;
        largesize) echo "# Magnified icon size" >> "$OUTPUT_FILE" ;;
        mineffect) echo "# Minimize effect: $value" >> "$OUTPUT_FILE" ;;
        show-recents) echo "# Show recent apps: $([ "$value" = "1" ] && echo "yes" || echo "no")" >> "$OUTPUT_FILE" ;;
        wvous-tl-corner) echo "# Top-left hot corner (0=none, 2=mission control, 3=app windows, 4=desktop, 5=screensaver, 6=disable screensaver, 10=sleep, 11=launchpad, 12=notification center, 13=lock screen, 14=quick note)" >> "$OUTPUT_FILE" ;;
        wvous-tr-corner) echo "# Top-right hot corner" >> "$OUTPUT_FILE" ;;
        wvous-bl-corner) echo "# Bottom-left hot corner" >> "$OUTPUT_FILE" ;;
        wvous-br-corner) echo "# Bottom-right hot corner" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write com.apple.dock $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# === TRACKPAD ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# TRACKPAD SETTINGS" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^com\.apple\.(AppleMultitouchTrackpad|driver\.AppleBluetoothMultitouch\.trackpad):(Clicking|Dragging|TrackpadThreeFinger|TrackpadTwoFinger|TrackpadRightClick|TrackpadScroll|ActuationStrength|FirstClickThreshold|SecondClickThreshold)" "$INPUT_FILE" | sort -u | while read line; do
    domain=$(echo "$line" | cut -d: -f1)
    rest=$(echo "$line" | cut -d: -f2-)
    key=$(echo "$rest" | cut -d= -f1 | xargs)
    value=$(echo "$rest" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        Clicking) echo "# Tap to click: $([ "$value" = "1" ] && echo "enabled" || echo "disabled")" >> "$OUTPUT_FILE" ;;
        TrackpadThreeFingerDrag) echo "# Three-finger drag: $([ "$value" = "1" ] && echo "enabled" || echo "disabled")" >> "$OUTPUT_FILE" ;;
        TrackpadThreeFingerHorizSwipeGesture) echo "# Three-finger horizontal swipe" >> "$OUTPUT_FILE" ;;
        TrackpadThreeFingerVertSwipeGesture) echo "# Three-finger vertical swipe" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write $domain $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# === FINDER ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# FINDER SETTINGS" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^com\.apple\.finder:(AppleShowAllFiles|ShowHardDrivesOnDesktop|ShowExternalHardDrivesOnDesktop|ShowRemovableMediaOnDesktop|ShowMountedServersOnDesktop|ShowPathbar|ShowStatusBar|ShowPreviewPane|ShowRecentTags|FXPreferredViewStyle|FXDefaultSearchScope|FXEnableExtensionChangeWarning|FXICloudDriveDesktop|FXICloudDriveDocuments|NewWindowTarget|_FXSortFoldersFirst|_FXShowPosixPathInTitle|QuitMenuItem)" "$INPUT_FILE" | while read line; do
    key=$(echo "$line" | cut -d: -f2 | cut -d= -f1 | xargs)
    value=$(echo "$line" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        AppleShowAllFiles) echo "# Show hidden files: $([ "$value" = "TRUE" ] || [ "$value" = "1" ] && echo "yes" || echo "no")" >> "$OUTPUT_FILE" ;;
        ShowHardDrivesOnDesktop) echo "# Show hard drives on desktop" >> "$OUTPUT_FILE" ;;
        ShowExternalHardDrivesOnDesktop) echo "# Show external drives on desktop" >> "$OUTPUT_FILE" ;;
        ShowMountedServersOnDesktop) echo "# Show mounted servers on desktop" >> "$OUTPUT_FILE" ;;
        ShowRemovableMediaOnDesktop) echo "# Show removable media on desktop" >> "$OUTPUT_FILE" ;;
        ShowPathbar) echo "# Show path bar at bottom" >> "$OUTPUT_FILE" ;;
        ShowStatusBar) echo "# Show status bar" >> "$OUTPUT_FILE" ;;
        ShowPreviewPane) echo "# Show preview pane" >> "$OUTPUT_FILE" ;;
        ShowRecentTags) echo "# Show recent tags in sidebar" >> "$OUTPUT_FILE" ;;
        FXPreferredViewStyle) echo "# Default view (icnv=icon, Nlsv=list, clmv=column, glyv=gallery)" >> "$OUTPUT_FILE" ;;
        FXDefaultSearchScope) echo "# Search scope (SCcf=current folder, SCsp=previous scope, SCev=entire mac)" >> "$OUTPUT_FILE" ;;
        FXEnableExtensionChangeWarning) echo "# Warn when changing extension" >> "$OUTPUT_FILE" ;;
        FXICloudDriveDesktop) echo "# Sync Desktop to iCloud" >> "$OUTPUT_FILE" ;;
        FXICloudDriveDocuments) echo "# Sync Documents to iCloud" >> "$OUTPUT_FILE" ;;
        _FXSortFoldersFirst) echo "# Sort folders before files" >> "$OUTPUT_FILE" ;;
        _FXShowPosixPathInTitle) echo "# Show full path in title bar" >> "$OUTPUT_FILE" ;;
        QuitMenuItem) echo "# Allow Finder to quit (Cmd+Q)" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write com.apple.finder $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# === SCREENSHOT ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# SCREENSHOT SETTINGS" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^com\.apple\.screencapture:(location|type|name|disable-shadow|show-thumbnail|include-date)" "$INPUT_FILE" | while read line; do
    key=$(echo "$line" | cut -d: -f2 | cut -d= -f1 | xargs)
    value=$(echo "$line" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        location) echo "# Screenshot save location" >> "$OUTPUT_FILE" ;;
        type) echo "# Screenshot format (png, jpg, pdf, tiff, gif)" >> "$OUTPUT_FILE" ;;
        name) echo "# Screenshot filename prefix" >> "$OUTPUT_FILE" ;;
        disable-shadow) echo "# Disable window shadow in screenshots" >> "$OUTPUT_FILE" ;;
        show-thumbnail) echo "# Show floating thumbnail after capture" >> "$OUTPUT_FILE" ;;
        include-date) echo "# Include date in filename" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write com.apple.screencapture $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# === DESKTOP SERVICES ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# DESKTOP SERVICES" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^com\.apple\.desktopservices:(DSDontWriteNetworkStores|DSDontWriteUSBStores)" "$INPUT_FILE" | while read line; do
    key=$(echo "$line" | cut -d: -f2 | cut -d= -f1 | xargs)
    value=$(echo "$line" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        DSDontWriteNetworkStores) echo "# Don't create .DS_Store on network volumes" >> "$OUTPUT_FILE" ;;
        DSDontWriteUSBStores) echo "# Don't create .DS_Store on USB volumes" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write com.apple.desktopservices $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# === GLOBAL DOMAIN (if present) ===
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# GLOBAL SETTINGS (NSGlobalDomain)" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
grep -E "^NSGlobalDomain:(AppleShowScrollBars|AppleScrollerPagingBehavior|NSAutomaticCapitalizationEnabled|NSAutomaticDashSubstitutionEnabled|NSAutomaticPeriodSubstitutionEnabled|NSAutomaticQuoteSubstitutionEnabled|NSAutomaticSpellingCorrectionEnabled|AppleKeyboardUIMode|ApplePressAndHoldEnabled|KeyRepeat|InitialKeyRepeat|AppleInterfaceStyle|AppleReduceDesktopTinting|AppleShowAllExtensions|com\.apple\.swipescrolldirection)" "$INPUT_FILE" | while read line; do
    key=$(echo "$line" | cut -d: -f2 | cut -d= -f1 | xargs)
    value=$(echo "$line" | cut -d= -f2- | xargs)
    echo "# $key = $value" >> "$OUTPUT_FILE"
    case "$key" in
        AppleShowScrollBars) echo "# When to show scroll bars (Always, WhenScrolling, Automatic)" >> "$OUTPUT_FILE" ;;
        AppleKeyboardUIMode) echo "# Full keyboard access (3=all controls)" >> "$OUTPUT_FILE" ;;
        ApplePressAndHoldEnabled) echo "# Press and hold for accents (false=key repeat)" >> "$OUTPUT_FILE" ;;
        KeyRepeat) echo "# Key repeat rate (lower=faster, 1=fastest)" >> "$OUTPUT_FILE" ;;
        InitialKeyRepeat) echo "# Delay before key repeat (lower=shorter)" >> "$OUTPUT_FILE" ;;
        AppleInterfaceStyle) echo "# Dark mode (Dark or absent for light)" >> "$OUTPUT_FILE" ;;
        AppleShowAllExtensions) echo "# Show all file extensions" >> "$OUTPUT_FILE" ;;
        com.apple.swipescrolldirection) echo "# Natural scrolling" >> "$OUTPUT_FILE" ;;
    esac
    echo "defaults write NSGlobalDomain $key $value" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# Count extracted settings
count=$(grep -c "^defaults write" "$OUTPUT_FILE")
echo "" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# Total settings extracted: $count" >> "$OUTPUT_FILE"
echo "# ========================================" >> "$OUTPUT_FILE"
echo "# To apply all settings, you can run:" >> "$OUTPUT_FILE"
echo "#   grep '^defaults write' $OUTPUT_FILE | bash" >> "$OUTPUT_FILE"
echo "# Then restart affected apps or log out/in" >> "$OUTPUT_FILE"

echo "Extracted $count user settings to $OUTPUT_FILE"

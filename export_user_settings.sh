#!/bin/bash
# Export all meaningful macOS user settings
# Usage: ./export_user_settings.sh [output_file]

OUTPUT="${1:-user_settings_full.conf}"

echo "# macOS User Settings Export" > "$OUTPUT"
echo "# Generated: $(date)" >> "$OUTPUT"
echo "# Host: $(scutil --get ComputerName)" >> "$OUTPUT"
echo "#" >> "$OUTPUT"
echo "# Apply with: grep '^defaults' file.conf | bash" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Function to export a setting with description
export_setting() {
    local domain="$1"
    local key="$2"
    local desc="$3"
    local value

    if [ "$domain" = "-g" ] || [ "$domain" = "NSGlobalDomain" ]; then
        value=$(defaults read -g "$key" 2>/dev/null)
        domain="-g"
    else
        value=$(defaults read "$domain" "$key" 2>/dev/null)
    fi

    if [ -n "$value" ]; then
        echo "# $desc" >> "$OUTPUT"
        echo "# Current value: $value" >> "$OUTPUT"
        # Handle different value types
        if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" =~ ^[0-9]+\.[0-9]+$ ]]; then
            echo "defaults write $domain $key -float $value" >> "$OUTPUT"
        elif [ "$value" = "true" ] || [ "$value" = "false" ] || [ "$value" = "1" ] || [ "$value" = "0" ]; then
            echo "defaults write $domain $key -bool $value" >> "$OUTPUT"
        else
            echo "defaults write $domain $key \"$value\"" >> "$OUTPUT"
        fi
        echo "" >> "$OUTPUT"
        return 0
    fi
    return 1
}

count=0

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# GLOBAL SETTINGS (NSGlobalDomain / -g)" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting -g "com.apple.trackpad.scaling" "Trackpad tracking speed (0.0 to 3.0, higher = faster)" && ((count++))
export_setting -g "com.apple.mouse.scaling" "Mouse tracking speed" && ((count++))
export_setting -g "KeyRepeat" "Key repeat rate (1=fastest, 2=fast, 6=normal, lower=faster)" && ((count++))
export_setting -g "InitialKeyRepeat" "Delay before key repeat starts (15=short, 25=normal, lower=shorter)" && ((count++))
export_setting -g "AppleInterfaceStyle" "Dark mode (Dark=enabled, absent=light)" && ((count++))
export_setting -g "AppleInterfaceStyleSwitchesAutomatically" "Auto switch light/dark mode" && ((count++))
export_setting -g "AppleShowScrollBars" "When to show scrollbars (Always, WhenScrolling, Automatic)" && ((count++))
export_setting -g "AppleScrollerPagingBehavior" "Click scrollbar to: 0=jump to next page, 1=jump to clicked spot" && ((count++))
export_setting -g "NSAutomaticCapitalizationEnabled" "Auto-capitalize words" && ((count++))
export_setting -g "NSAutomaticDashSubstitutionEnabled" "Smart dashes (-- to em-dash)" && ((count++))
export_setting -g "NSAutomaticPeriodSubstitutionEnabled" "Double-space for period" && ((count++))
export_setting -g "NSAutomaticQuoteSubstitutionEnabled" "Smart quotes" && ((count++))
export_setting -g "NSAutomaticSpellingCorrectionEnabled" "Auto-correct spelling" && ((count++))
export_setting -g "ApplePressAndHoldEnabled" "Press and hold for accents (false=enable key repeat)" && ((count++))
export_setting -g "AppleKeyboardUIMode" "Full keyboard access (3=all controls, 2=text boxes and lists only)" && ((count++))
export_setting -g "com.apple.swipescrolldirection" "Natural scrolling (true=natural, false=traditional)" && ((count++))
export_setting -g "AppleShowAllExtensions" "Show all filename extensions" && ((count++))
export_setting -g "AppleReduceDesktopTinting" "Reduce transparency" && ((count++))
export_setting -g "AppleHighlightColor" "Highlight/accent color" && ((count++))
export_setting -g "AppleAccentColor" "Accent color (0=red, 1=orange, 2=yellow, 3=green, 5=purple, 6=pink, -1=graphite)" && ((count++))
export_setting -g "NSTableViewDefaultSizeMode" "Sidebar icon size (1=small, 2=medium, 3=large)" && ((count++))
export_setting -g "_HIHideMenuBar" "Auto-hide menu bar" && ((count++))
export_setting -g "NSNavPanelExpandedStateForSaveMode" "Expand save dialog by default" && ((count++))
export_setting -g "NSNavPanelExpandedStateForSaveMode2" "Expand save dialog by default (alternate)" && ((count++))
export_setting -g "PMPrintingExpandedStateForPrint" "Expand print dialog by default" && ((count++))
export_setting -g "PMPrintingExpandedStateForPrint2" "Expand print dialog by default (alternate)" && ((count++))
export_setting -g "NSDocumentSaveNewDocumentsToCloud" "Save to iCloud by default (false=local)" && ((count++))
export_setting -g "NSCloseAlwaysConfirmsChanges" "Ask to save changes when closing" && ((count++))
export_setting -g "NSQuitAlwaysKeepsWindows" "Close windows when quitting apps" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# DOCK SETTINGS" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.dock "autohide" "Auto-hide dock" && ((count++))
export_setting com.apple.dock "autohide-delay" "Dock show delay in seconds (0=instant)" && ((count++))
export_setting com.apple.dock "autohide-time-modifier" "Dock animation speed (0=instant)" && ((count++))
export_setting com.apple.dock "orientation" "Dock position (left, bottom, right)" && ((count++))
export_setting com.apple.dock "tilesize" "Dock icon size in pixels" && ((count++))
export_setting com.apple.dock "largesize" "Magnified icon size" && ((count++))
export_setting com.apple.dock "magnification" "Enable dock magnification" && ((count++))
export_setting com.apple.dock "mineffect" "Minimize effect (genie, scale, suck)" && ((count++))
export_setting com.apple.dock "minimize-to-application" "Minimize windows into app icon" && ((count++))
export_setting com.apple.dock "show-recents" "Show recent apps in dock" && ((count++))
export_setting com.apple.dock "show-process-indicators" "Show dots for open apps" && ((count++))
export_setting com.apple.dock "static-only" "Show only open apps in dock" && ((count++))
export_setting com.apple.dock "launchanim" "Animate opening apps" && ((count++))
export_setting com.apple.dock "expose-group-apps" "Group windows by app in Mission Control" && ((count++))
export_setting com.apple.dock "mru-spaces" "Auto-rearrange spaces based on recent use" && ((count++))
export_setting com.apple.dock "showAppExposeGestureEnabled" "App Exposé gesture enabled" && ((count++))
export_setting com.apple.dock "wvous-tl-corner" "Top-left hot corner (2=Mission Control, 3=App Windows, 4=Desktop, 5=Screensaver, 6=Disable Screensaver, 10=Sleep, 11=Launchpad, 12=Notification Center, 13=Lock Screen, 14=Quick Note)" && ((count++))
export_setting com.apple.dock "wvous-tl-modifier" "Top-left modifier (0=none, 131072=Shift, 262144=Ctrl, 524288=Option, 1048576=Cmd)" && ((count++))
export_setting com.apple.dock "wvous-tr-corner" "Top-right hot corner" && ((count++))
export_setting com.apple.dock "wvous-tr-modifier" "Top-right modifier" && ((count++))
export_setting com.apple.dock "wvous-bl-corner" "Bottom-left hot corner" && ((count++))
export_setting com.apple.dock "wvous-bl-modifier" "Bottom-left modifier" && ((count++))
export_setting com.apple.dock "wvous-br-corner" "Bottom-right hot corner" && ((count++))
export_setting com.apple.dock "wvous-br-modifier" "Bottom-right modifier" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# TRACKPAD SETTINGS" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

for domain in "com.apple.AppleMultitouchTrackpad" "com.apple.driver.AppleBluetoothMultitouch.trackpad"; do
    export_setting "$domain" "Clicking" "Tap to click" && ((count++))
    export_setting "$domain" "Dragging" "Dragging enabled" && ((count++))
    export_setting "$domain" "TrackpadThreeFingerDrag" "Three-finger drag" && ((count++))
    export_setting "$domain" "TrackpadTwoFingerDoubleTapGesture" "Smart zoom" && ((count++))
    export_setting "$domain" "TrackpadThreeFingerHorizSwipeGesture" "Three-finger horizontal swipe (0=off, 1=navigate, 2=switch apps)" && ((count++))
    export_setting "$domain" "TrackpadThreeFingerVertSwipeGesture" "Three-finger vertical swipe" && ((count++))
    export_setting "$domain" "TrackpadFourFingerHorizSwipeGesture" "Four-finger horizontal swipe" && ((count++))
    export_setting "$domain" "TrackpadFourFingerVertSwipeGesture" "Four-finger vertical swipe" && ((count++))
    export_setting "$domain" "TrackpadRightClick" "Right-click with two fingers" && ((count++))
    export_setting "$domain" "TrackpadRotate" "Rotate gesture" && ((count++))
    export_setting "$domain" "TrackpadPinch" "Pinch to zoom" && ((count++))
    export_setting "$domain" "TrackpadFiveFingerPinchGesture" "Five-finger pinch (Launchpad)" && ((count++))
    export_setting "$domain" "TrackpadTwoFingerFromRightEdgeSwipeGesture" "Swipe from right edge (Notification Center)" && ((count++))
    export_setting "$domain" "ActuationStrength" "Click pressure (0=light, 1=medium, 2=firm)" && ((count++))
    export_setting "$domain" "FirstClickThreshold" "Click threshold" && ((count++))
    export_setting "$domain" "SecondClickThreshold" "Force click threshold" && ((count++))
    export_setting "$domain" "ForceSuppressed" "Disable force click" && ((count++))
done

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# FINDER SETTINGS" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.finder "AppleShowAllFiles" "Show hidden files" && ((count++))
export_setting com.apple.finder "ShowExternalHardDrivesOnDesktop" "Show external drives on desktop" && ((count++))
export_setting com.apple.finder "ShowHardDrivesOnDesktop" "Show internal drives on desktop" && ((count++))
export_setting com.apple.finder "ShowMountedServersOnDesktop" "Show connected servers on desktop" && ((count++))
export_setting com.apple.finder "ShowRemovableMediaOnDesktop" "Show removable media on desktop" && ((count++))
export_setting com.apple.finder "ShowPathbar" "Show path bar" && ((count++))
export_setting com.apple.finder "ShowStatusBar" "Show status bar" && ((count++))
export_setting com.apple.finder "ShowPreviewPane" "Show preview pane" && ((count++))
export_setting com.apple.finder "ShowRecentTags" "Show recent tags in sidebar" && ((count++))
export_setting com.apple.finder "ShowSidebar" "Show sidebar" && ((count++))
export_setting com.apple.finder "ShowTabView" "Show tab bar" && ((count++))
export_setting com.apple.finder "FXPreferredViewStyle" "Default view (icnv=icon, Nlsv=list, clmv=column, glyv=gallery)" && ((count++))
export_setting com.apple.finder "FXDefaultSearchScope" "Search scope (SCcf=current folder, SCsp=previous, SCev=entire Mac)" && ((count++))
export_setting com.apple.finder "FXEnableExtensionChangeWarning" "Warn when changing file extension" && ((count++))
export_setting com.apple.finder "FXRemoveOldTrashItems" "Remove items from trash after 30 days" && ((count++))
export_setting com.apple.finder "_FXSortFoldersFirst" "Keep folders on top when sorting by name" && ((count++))
export_setting com.apple.finder "_FXSortFoldersFirstOnDesktop" "Keep folders on top on desktop" && ((count++))
export_setting com.apple.finder "_FXShowPosixPathInTitle" "Show full POSIX path in title bar" && ((count++))
export_setting com.apple.finder "QuitMenuItem" "Allow quitting Finder via Cmd+Q" && ((count++))
export_setting com.apple.finder "NewWindowTarget" "New window target (PfHm=Home, PfDe=Desktop, PfDo=Documents, PfLo=Other)" && ((count++))
export_setting com.apple.finder "NewWindowTargetPath" "New window path" && ((count++))
export_setting com.apple.finder "FXICloudDriveEnabled" "iCloud Drive enabled" && ((count++))
export_setting com.apple.finder "FXICloudDriveDesktop" "Sync Desktop to iCloud" && ((count++))
export_setting com.apple.finder "FXICloudDriveDocuments" "Sync Documents to iCloud" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# DESKTOP SERVICES" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.desktopservices "DSDontWriteNetworkStores" "Don't create .DS_Store on network volumes" && ((count++))
export_setting com.apple.desktopservices "DSDontWriteUSBStores" "Don't create .DS_Store on USB volumes" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# SCREENSHOT SETTINGS" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.screencapture "location" "Screenshot save location" && ((count++))
export_setting com.apple.screencapture "type" "Screenshot format (png, jpg, pdf, gif, tiff)" && ((count++))
export_setting com.apple.screencapture "name" "Screenshot filename prefix" && ((count++))
export_setting com.apple.screencapture "include-date" "Include date in filename" && ((count++))
export_setting com.apple.screencapture "disable-shadow" "Disable window shadow in screenshots" && ((count++))
export_setting com.apple.screencapture "show-thumbnail" "Show floating thumbnail after capture" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# KEYBOARD LAYOUT" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.HIToolbox "AppleCurrentKeyboardLayoutInputSourceID" "Current keyboard layout" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# MISSION CONTROL / SPACES" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.spaces "spans-displays" "Displays have separate Spaces" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# MENUBAR / CONTROL CENTER" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.menuextra.clock "DateFormat" "Menu bar clock format" && ((count++))
export_setting com.apple.menuextra.clock "Show24Hour" "24-hour clock" && ((count++))
export_setting com.apple.menuextra.clock "ShowAMPM" "Show AM/PM" && ((count++))
export_setting com.apple.menuextra.clock "ShowDate" "Show date in menu bar" && ((count++))
export_setting com.apple.menuextra.clock "ShowDayOfWeek" "Show day of week" && ((count++))
export_setting com.apple.menuextra.clock "ShowSeconds" "Show seconds" && ((count++))
export_setting com.apple.menuextra.battery "ShowPercent" "Show battery percentage" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# SAFARI (if available)" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.Safari "ShowFullURLInSmartSearchField" "Show full URL in address bar" && ((count++))
export_setting com.apple.Safari "AutoOpenSafeDownloads" "Open safe downloads automatically" && ((count++))
export_setting com.apple.Safari "IncludeDevelopMenu" "Show Develop menu" && ((count++))
export_setting com.apple.Safari "WebKitDeveloperExtrasEnabledPreferenceKey" "Enable Web Inspector" && ((count++))
export_setting com.apple.Safari "ShowFavoritesBar" "Show favorites bar" && ((count++))
export_setting com.apple.Safari "ShowSidebarInTopSites" "Show sidebar in Top Sites" && ((count++))
export_setting com.apple.Safari "HomePage" "Home page URL" && ((count++))

# ============================================
echo "# ========================================" >> "$OUTPUT"
echo "# TERMINAL (if available)" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"

export_setting com.apple.Terminal "Default Window Settings" "Default Terminal profile" && ((count++))
export_setting com.apple.Terminal "Startup Window Settings" "Startup Terminal profile" && ((count++))
export_setting com.apple.Terminal "SecureKeyboardEntry" "Secure keyboard entry" && ((count++))

# ============================================
echo "" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"
echo "# SUMMARY" >> "$OUTPUT"
echo "# ========================================" >> "$OUTPUT"
echo "# Total settings exported: $count" >> "$OUTPUT"
echo "#" >> "$OUTPUT"
echo "# To apply these settings:" >> "$OUTPUT"
echo "#   grep '^defaults' $OUTPUT | bash" >> "$OUTPUT"
echo "#" >> "$OUTPUT"
echo "# Then restart affected services:" >> "$OUTPUT"
echo "#   killall Dock" >> "$OUTPUT"
echo "#   killall Finder" >> "$OUTPUT"
echo "#   killall SystemUIServer" >> "$OUTPUT"
echo "# Or log out and back in" >> "$OUTPUT"

echo "Exported $count settings to $OUTPUT"

# mac-setup

Scripts to export and restore macOS user settings and Homebrew packages across machines.

## Quick Start

### On your current Mac (export settings):

```bash
# Export your settings
./export_user_settings.sh

# This creates user_settings_full.conf
```

### On a new Mac (restore settings):

```bash
# 1. Install Homebrew packages
./brew.sh

# 2. Apply system settings
./install_user_settings.sh
```

## Scripts

### Settings Management

| Script | Description |
|--------|-------------|
| `export_user_settings.sh` | Exports all user-configurable macOS settings to `user_settings_full.conf` |
| `install_user_settings.sh` | Applies settings from `user_settings_full.conf` to the current Mac |

### Homebrew Package Management

| Script | Description |
|--------|-------------|
| `brew.sh` | Installs Homebrew and packages from `packages.conf` |
| `check-packages.sh` | Shows which packages from `packages.conf` are installed/missing |

## Configuration Files

| File | Description |
|------|-------------|
| `user_settings_full.conf` | Exported macOS settings (71 settings) - the main config file |
| `packages.conf` | List of Homebrew packages to install |

## What Settings Are Exported?

The `export_user_settings.sh` script captures:

### Global Settings (NSGlobalDomain)
- Trackpad/mouse tracking speed
- Key repeat rate and delay
- Dark mode
- Auto-capitalization, smart quotes, spell correction
- Scroll bar behavior

### Dock
- Position, size, auto-hide
- Magnification
- Hot corners
- Animation settings

### Trackpad
- Tap to click
- Three-finger drag
- All gesture settings
- Click pressure

### Finder
- Show hidden files
- Desktop icons (drives, servers)
- Path bar, status bar, preview pane
- Default view style
- iCloud sync settings

### Other
- Screenshot settings
- Keyboard layout
- Menu bar clock format
- Terminal profile
- Safari developer settings

## Example Output

```
# Trackpad tracking speed (0.0 to 3.0, higher = faster)
# Current value: 8
defaults write -g com.apple.trackpad.scaling -float 8

# Dark mode (Dark=enabled, absent=light)
# Current value: Dark
defaults write -g AppleInterfaceStyle "Dark"

# Dock position (left, bottom, right)
# Current value: left
defaults write com.apple.dock orientation "left"
```

## Manual Application

If you prefer to apply settings manually or selectively:

```bash
# View all settings
cat user_settings_full.conf

# Apply just dock settings
grep 'com.apple.dock' user_settings_full.conf | grep '^defaults' | bash
killall Dock

# Apply just trackpad settings
grep 'trackpad' user_settings_full.conf | grep '^defaults' | bash
```

## Updating Settings

After changing settings in System Preferences:

```bash
# Re-export to capture changes
./export_user_settings.sh

# Check what changed
git diff user_settings_full.conf
```

## Deprecated Files

Old scripts that used a different (verbose) export format are in `.old/`:
- `mac_settings.conf` - 2500+ line export with internal system state
- `apply-mac-settings.sh` - Applied the old format
- `get-mac-settings.sh` - Created the old format
- `diff-mac-settings.sh` - Compared old format files

The new format (`user_settings_full.conf`) is cleaner and only contains user-configurable settings.

## Notes

- Some settings require logout/login to take effect
- The install script restarts Dock, Finder, and SystemUIServer automatically
- Trackpad settings are written to two domains (built-in and Bluetooth trackpads)
- Settings that don't exist on your system are silently skipped

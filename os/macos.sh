#!/bin/bash
# macOS System Preferences
# Customize macOS defaults for a better development experience

set -e

GREEN='\033[0;32m'
NC='\033[0m'

info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

info "Configuring macOS system preferences..."
echo ""

# Close System Preferences to prevent overriding settings
osascript -e 'tell application "System Preferences" to quit'

###############################################################################
# General UI/UX
###############################################################################

info "Configuring General UI/UX..."

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

###############################################################################
# Keyboard & Input
###############################################################################

info "Configuring Keyboard & Input..."

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15


###############################################################################
# Trackpad
###############################################################################

info "Configuring Trackpad..."

# Enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Dock
###############################################################################

info "Configuring Dock..."

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

###############################################################################
# Done
###############################################################################

echo ""
success "macOS preferences configured!"
echo ""
info "Some changes require a logout/restart to take effect."
info "You may need to restart Finder and Dock:"
echo "  killall Finder"
echo "  killall Dock"
echo ""

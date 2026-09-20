#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

#####################################################
# Typing
#####################################################

defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

#####################################################
# Dock
#####################################################

defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock tilesize -int 62

#####################################################
# Finder
#####################################################

defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Search the current folder by default rather than the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Do not warn when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#####################################################
# Filesystem hygiene
#####################################################

# Do not write .DS_Store files onto network shares or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

#####################################################
# Apply
#####################################################

for app in Finder Dock; do
  killall "$app" 2>/dev/null || true
done

info "macOS defaults applied (Finder and Dock restarted)"

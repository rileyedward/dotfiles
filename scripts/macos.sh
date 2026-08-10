#!/usr/bin/env bash
#
# macOS system preferences.
#
# Every value below was read off the source machine with `defaults read`, so
# running this reproduces that setup rather than imposing someone else's taste.
# A handful of additions are grouped separately and labelled.
#
# This is the only script here with side effects on a machine you're already
# using. Read it before running it.
#
#   ./scripts/macos.sh

set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

[ "$(uname -s)" = "Darwin" ] || die "macOS only"

info "Applying macOS defaults"

# --- Dock --------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 53
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
ok "Dock"

# --- Keyboard ----------------------------------------------------------
# KeyRepeat 2 / InitialKeyRepeat 15 is faster than anything System Settings
# exposes through its sliders.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
ok "Keyboard repeat rate"

# --- Finder ------------------------------------------------------------
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view

# Additions — not set on the source machine, comment out if unwanted.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
ok "Finder"

# --- Appearance --------------------------------------------------------
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
ok "Dark mode"

# --- Trackpad ----------------------------------------------------------
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
ok "Tap to click"

info "Restarting Dock, Finder and SystemUIServer"
killall Dock Finder SystemUIServer 2>/dev/null || true

info "Done. Some settings only take effect after a logout."

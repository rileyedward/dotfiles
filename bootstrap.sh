#!/usr/bin/env bash
#
# Set up a fresh macOS machine.
#
#   ./bootstrap.sh           everything except system preferences
#   ./bootstrap.sh --macos   also apply scripts/macos.sh
#
# Safe to re-run: every step checks before it acts.

set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/lib.sh"

APPLY_MACOS=0
for arg in "$@"; do
  case "$arg" in
    --macos) APPLY_MACOS=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) die "unknown option: $arg" ;;
  esac
done

[ "$(uname -s)" = "Darwin" ] || die "macOS only"

# --- 1. Xcode Command Line Tools ---------------------------------------
if xcode-select -p >/dev/null 2>&1; then
  skip "Xcode Command Line Tools present"
else
  info "Installing Xcode Command Line Tools"
  xcode-select --install
  info "Finish the GUI installer, then re-run this script."
  exit 0
fi

# --- 2. Homebrew -------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  skip "Homebrew present"
else
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon installs to /opt/homebrew, which isn't on a fresh PATH.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- 3. Packages -------------------------------------------------------
info "Installing packages from the Brewfile"
brew bundle --file="$DOTFILES/Brewfile"

# --- 4. Oh My Zsh ------------------------------------------------------
# KEEP_ZSHRC=yes matters: without it the installer overwrites ~/.zshrc and
# leaves the original at ~/.zshrc.pre-oh-my-zsh, which is exactly how the Herd
# PHP exports got stranded on the source machine.
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "Oh My Zsh present"
else
  info "Installing Oh My Zsh"
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- 5. Symlinks -------------------------------------------------------
"$DOTFILES/install.sh"

# --- 6. Git identity ---------------------------------------------------
if [ -e "$HOME/.gitconfig.local" ]; then
  skip "git identity already configured"
else
  "$DOTFILES/scripts/git-identity.sh"
fi

# --- 7. SSH ------------------------------------------------------------
"$DOTFILES/scripts/ssh-setup.sh"

# --- 8. System preferences --------------------------------------------
if [ "$APPLY_MACOS" = 1 ]; then
  "$DOTFILES/scripts/macos.sh"
else
  skip "system preferences skipped — run ./scripts/macos.sh, or pass --macos"
fi

# --- Done --------------------------------------------------------------
info "Bootstrap complete. Remaining manual steps:"
cat <<'EOF'

  1. Add the SSH public key printed above to https://github.com/settings/keys
  2. Open Ghostty and confirm the Nerd Font is rendering (LazyVim icons).
  3. Launch nvim — lazy.nvim installs the plugin set from lazy-lock.json on
     first run. Then :Mason to pull the LSP servers.
  4. Open Herd once so it registers its PHP versions and services.
  5. Sign in to Arc, Obsidian, Sublime Text.

EOF

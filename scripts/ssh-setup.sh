#!/usr/bin/env bash
#
# Generate an ed25519 SSH key if there isn't one, install the github.com config
# if ~/.ssh/config is absent, and load the key into the agent + keychain.
#
# Never overwrites an existing key or config.

set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

KEY="$HOME/.ssh/id_ed25519"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ -e "$KEY" ]; then
  skip "$(tilde "$KEY") already exists"
else
  info "Generating an ed25519 key"
  ssh-keygen -t ed25519 -f "$KEY" -C "$(whoami)@$(scutil --get ComputerName 2>/dev/null || hostname)"
  ok "created $(tilde "$KEY")"
fi

if [ -e "$HOME/.ssh/config" ]; then
  skip "$(tilde "$HOME/.ssh/config") already exists"
else
  cp "$DOTFILES/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  ok "installed $(tilde "$HOME/.ssh/config")"
fi

# --apple-use-keychain is the modern spelling; fall back for older macOS.
ssh-add --apple-use-keychain "$KEY" 2>/dev/null \
  || ssh-add -K "$KEY" 2>/dev/null \
  || warn "couldn't add the key to the agent — run: ssh-add --apple-use-keychain $(tilde "$KEY")"

info "Public key — add this at https://github.com/settings/keys"
printf '\n'
cat "$KEY.pub"
printf '\n'
info "Then verify with: ssh -T git@github.com"

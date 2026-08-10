#!/usr/bin/env bash
#
# Symlink the dotfiles in this repo into $HOME.
#
#   ./install.sh            link everything
#   ./install.sh --dry-run  print what would happen, change nothing
#
# Idempotent. Anything already in the way is moved to
# ~/.dotfiles-backup/<timestamp>/ before being replaced — this script never
# deletes a file.

set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/lib.sh"

for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) die "unknown option: $arg" ;;
  esac
done

[ "$DRY_RUN" = 1 ] && info "Dry run — nothing will be changed."

info "Linking dotfiles from $(tilde "$DOTFILES")"

# --- $HOME -------------------------------------------------------------
link home/.zshrc    "$HOME/.zshrc"
link home/.gitconfig "$HOME/.gitconfig"

# --- ~/.config ---------------------------------------------------------
link config/nvim    "$HOME/.config/nvim"
link config/ghostty "$HOME/.config/ghostty"
link config/git     "$HOME/.config/git"

# --- Oh My Zsh custom theme -------------------------------------------
# Linked into custom/themes/ rather than the upstream themes/ directory so it
# survives `omz update` and a full reinstall.
#
# Deliberately skipped when Oh My Zsh is absent: creating ~/.oh-my-zsh here
# would make the Oh My Zsh installer report "already installed" and bail.
if [ -d "$HOME/.oh-my-zsh" ]; then
  link omz/themes/catppuccin.zsh-theme  "$HOME/.oh-my-zsh/custom/themes/catppuccin.zsh-theme"
  link omz/themes/catppuccin-flavors    "$HOME/.oh-my-zsh/custom/themes/catppuccin-flavors"
else
  warn "Oh My Zsh not installed — skipping the catppuccin theme."
  warn "Install it (see bootstrap.sh) and re-run this script."
fi

# --- SSH ---------------------------------------------------------------
# Copied, not symlinked: ~/.ssh is permission-sensitive and a symlink pointing
# into a repo is the wrong shape there. Only written when absent, so an
# existing config is never touched.
if [ -e "$HOME/.ssh/config" ]; then
  skip "$(tilde "$HOME/.ssh/config") exists — left alone"
  warn "compare it against $(tilde "$DOTFILES/ssh/config") by hand if you like"
elif [ "$DRY_RUN" = 1 ]; then
  ok "would copy ssh/config -> $(tilde "$HOME/.ssh/config")"
else
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  cp "$DOTFILES/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  ok "copied ssh/config -> $(tilde "$HOME/.ssh/config")"
fi

backup_summary

if [ "$DRY_RUN" != 1 ]; then
  info "Done. Open a new shell, or run: exec zsh"
  [ -e "$HOME/.gitconfig.local" ] || \
    warn "no ~/.gitconfig.local yet — run scripts/git-identity.sh to set your git name/email"
fi

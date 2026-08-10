#!/usr/bin/env bash
# Shared helpers. Sourced by install.sh, bootstrap.sh and scripts/*.sh.

set -euo pipefail

# Repo root, resolved from this file's location so the repo works at any path.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES

DRY_RUN="${DRY_RUN:-0}"

if [ -t 1 ]; then
  _c_reset=$'\033[0m'; _c_dim=$'\033[2m'; _c_blue=$'\033[34m'
  _c_green=$'\033[32m'; _c_yellow=$'\033[33m'; _c_red=$'\033[31m'
else
  _c_reset=''; _c_dim=''; _c_blue=''; _c_green=''; _c_yellow=''; _c_red=''
fi

info() { printf '%s==>%s %s\n' "$_c_blue" "$_c_reset" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$_c_green" "$_c_reset" "$*"; }
skip() { printf '  %s·%s %s\n' "$_c_dim" "$_c_reset" "$*"; }
warn() { printf '  %s!%s %s\n' "$_c_yellow" "$_c_reset" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$_c_red" "$_c_reset" "$*" >&2; exit 1; }

# Print a path with $HOME collapsed to ~ for readable output.
tilde() { local t='~'; printf '%s' "${1/#"$HOME"/$t}"; }

# Backup directory for this run. Created lazily — an idempotent re-run that
# moves nothing leaves no empty directory behind.
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y-%m-%d-%H%M%S)}"
_backup_used=0

# backup <path>
# Move an existing file/dir/symlink into BACKUP_DIR, preserving its path
# relative to $HOME. Never deletes anything.
backup() {
  local target="$1" rel dest
  rel="${target#"$HOME"/}"
  dest="$BACKUP_DIR/$rel"
  if [ "$DRY_RUN" = 1 ]; then
    warn "would back up $(tilde "$target") -> $(tilde "$dest")"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  mv "$target" "$dest"
  _backup_used=1
  warn "backed up $(tilde "$target") -> $(tilde "$dest")"
}

# link <source-relative-to-repo> <absolute-target>
# Idempotent: an already-correct symlink is left alone. Anything else in the
# way is backed up first.
link() {
  local src="$DOTFILES/$1" target="$2"

  [ -e "$src" ] || die "missing source: $src"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    skip "$(tilde "$target") already linked"
    return 0
  fi

  # -e is false for a broken symlink, so test -L as well.
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup "$target"
  fi

  if [ "$DRY_RUN" = 1 ]; then
    ok "would link $(tilde "$target") -> $(tilde "$src")"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$src" "$target"
  ok "linked $(tilde "$target") -> $(tilde "$src")"
}

backup_summary() {
  if [ "$_backup_used" = 1 ]; then
    info "Replaced files were moved to $(tilde "$BACKUP_DIR") — nothing was deleted."
  fi
}

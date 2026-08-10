# brew bundle --file=Brewfile
#
# Only top-level packages are listed. `brew leaves` on the source machine
# returned exactly fd, gradle and neovim — the other ~39 formulae installed
# there are dependencies and are left for brew to resolve (openjdk, for
# instance, arrives with gradle).

# --- CLI ---------------------------------------------------------------
brew "fd"       # find replacement, used by telescope/snacks pickers
brew "neovim"
brew "gradle"   # minecraft-server project
brew "gh"       # GitHub CLI — needed to create/clone the private dotfiles repo
brew "ripgrep"  # LazyVim grep backend
brew "jq"

# --- Applications ------------------------------------------------------
cask "arc"
cask "claude"
cask "claude-code"
cask "ghostty"
cask "herd"          # Laravel Herd: PHP, Composer, nvm, laravel/forge/expose
cask "obsidian"
cask "rectangle"
cask "sublime-text"

# --- Fonts -------------------------------------------------------------
# cask-fonts was merged into homebrew/cask, so no tap is required.
cask "font-jetbrains-mono"
cask "font-jetbrains-mono-nerd-font"

# --- Optional ----------------------------------------------------------
# cask "minecraft"

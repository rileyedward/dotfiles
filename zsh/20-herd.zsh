# Laravel Herd.
#
# Herd provides PHP, Composer, the laravel/forge/expose CLIs and its own bundled
# nvm. Every line below is guarded, so this file is a harmless no-op on a
# machine where Herd isn't installed.

HERD_HOME="$HOME/Library/Application Support/Herd"

if [ -d "$HERD_HOME/bin" ]; then
  export PATH="$HERD_HOME/bin":$PATH
fi

# Herd-injected NVM configuration. Herd ships its own nvm rather than using
# ~/.nvm, which is why NVM_DIR points inside its support directory.
export NVM_DIR="$HERD_HOME/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && \
  builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# dotfiles

Reproduce a fully configured macOS development machine with a single command.

> **Status:** Active — in use on my machine.

## Overview

### What is dotfiles?

dotfiles is the source of truth for this machine's configuration — the zsh setup, the LazyVim config, the Ghostty terminal, git, and the list of applications that make up a working environment. Rather than scattering these across `$HOME` where they're invisible and unversioned, everything lives here and is symlinked into place, so editing `~/.zshrc` *is* editing this repo and `git status` is the record of what changed.

Everything is themed [catppuccin-macchiato](https://github.com/catppuccin) end to end — the shell prompt, Neovim, and the terminal. Laravel Herd supplies PHP, Composer and Node.

Setting up a new laptop is an afternoon of half-remembered settings, and the config on an existing one is one accidental `rm` away from gone. Neither problem announces itself until it's too late — a fresh Oh My Zsh install silently drops a custom theme, an unversioned Neovim config exists on exactly one disk, and a typo in `~/.ssh/config` sits there breaking every connection until someone reads the file closely.

This repo makes all of that reproducible and reviewable. `bootstrap.sh` takes a brand-new Mac from Xcode Command Line Tools to a working shell, and `install.sh` is safe to run on a machine you're already using: it backs up anything it replaces and never deletes a file.

### Key Features

- **One-command bootstrap**: `bootstrap.sh` installs the Xcode CLT, Homebrew, every package in the `Brewfile`, and Oh My Zsh, then links the configs, sets up git and SSH, and applies system preferences.
- **Non-destructive install**: `install.sh` moves anything already in the way to `~/.dotfiles-backup/<timestamp>/` before linking. It never deletes, and a `--dry-run` flag shows exactly what would change.
- **Idempotent**: Every step checks before it acts. Re-running either script is safe and reports what's already done.
- **Reproducible Neovim**: A LazyVim setup with `lazy-lock.json` and `lazyvim.json` both committed, so a new machine comes up with the identical plugin set and the same 18 language extras.
- **Portable Oh My Zsh theme**: The catppuccin theme is vendored here and linked into `$ZSH_CUSTOM/themes/`, where an Oh My Zsh reinstall can't remove it.
- **No secrets**: Git identity is prompted into an untracked `~/.gitconfig.local`. SSH keys, session state and machine IDs are excluded by design.

## Getting Started

### Prerequisites

None. `bootstrap.sh` installs everything it needs, including Homebrew and the Xcode Command Line Tools.

To check what's already present on a machine you're adopting this on:

1. **Homebrew** manages the CLI tools and applications:

    ```bash
    brew --version
    ```

2. **Oh My Zsh** provides the shell framework and prompt:

    ```bash
    ls ~/.oh-my-zsh
    ```

3. **Neovim** (0.9+) is required by LazyVim:

    ```bash
    nvim --version
    ```

> Cloning over SSH needs a key on the machine already. On a genuinely fresh Mac, clone over HTTPS and let `scripts/ssh-setup.sh` generate one for you.

### Installation

1. Clone the repository:

    ```bash
    git clone git@github.com:rileyedward/dotfiles.git ~/rileyedward/dotfiles
    cd ~/rileyedward/dotfiles
    ```

2. Run the bootstrap script:

    ```bash
    ./bootstrap.sh --macos
    ```

    Drop `--macos` to skip system preferences and apply them later with `./scripts/macos.sh`.

3. Add the printed SSH public key to [GitHub](https://github.com/settings/keys), then verify:

    ```bash
    ssh -T git@github.com
    ```

4. Open a new shell and launch Neovim. lazy.nvim installs the pinned plugin set on first run:

    ```bash
    exec zsh
    nvim
    ```

5. Install the LSP servers from inside Neovim:

    ```text
    :Mason
    ```

## Usage

### Linking Configs on an Existing Machine

Preview every change before committing to it:

```bash
./install.sh --dry-run
```

Then link for real:

```bash
./install.sh
```

Anything already at a target path is moved to `~/.dotfiles-backup/<timestamp>/` first. To revert, copy that directory's contents back over `$HOME`. Worth running from a fresh terminal window, so a mistake in `.zshrc` can't lock you out of the shell you're working in.

### Setting Your Git Identity

```bash
./scripts/git-identity.sh
```

Prompts for a name and email and writes `~/.gitconfig.local`, which `home/.gitconfig` includes and which is never committed.

### Applying System Preferences

```bash
./scripts/macos.sh
```

The one script here with side effects on a machine you're already using. Read it before running it — every value is commented with what it controls.

### Adding a New Dotfile

1. Copy the file into `home/` (for `$HOME`) or `config/` (for `~/.config`).
2. Add a `link` line to `install.sh`.
3. Run `./install.sh --dry-run`, then `./install.sh`.
4. Note it in the table below.

## Project Structure

```text
bootstrap.sh                fresh-machine setup, start to finish
install.sh                  symlinks only; idempotent; --dry-run
Brewfile                    brew bundle: CLI tools, applications, fonts

scripts/
├── lib.sh                  logging, backup and link helpers
├── macos.sh                system preferences (the one script with side effects)
├── git-identity.sh         prompts for name/email -> ~/.gitconfig.local
└── ssh-setup.sh            ed25519 keygen + github.com config

home/                       files that land directly in $HOME
├── .zshrc
└── .gitconfig

config/                     files that land in ~/.config
├── nvim/                   LazyVim: init.lua, lazy-lock.json, lazyvim.json
├── ghostty/config
└── git/ignore              global excludes

zsh/                        shell fragments, sourced in numeric order
├── 00-exports.zsh          $EDITOR, $VISUAL, $LESS
├── 10-aliases.zsh          ga, gs, nope, a, zshconfig, dotfiles
├── 20-herd.zsh             Laravel Herd PATH, bundled nvm, shell hook
└── local.zsh.example       copy to local.zsh for machine-specific config

omz/themes/                 vendored catppuccin Oh My Zsh theme
ssh/config                  sanitized SSH config template
```

## What Links Where

| Repo | Target |
| --- | --- |
| `home/.zshrc` | `~/.zshrc` |
| `home/.gitconfig` | `~/.gitconfig` |
| `config/nvim/` | `~/.config/nvim` |
| `config/ghostty/` | `~/.config/ghostty` |
| `config/git/` | `~/.config/git` |
| `omz/themes/catppuccin.zsh-theme` | `~/.oh-my-zsh/custom/themes/catppuccin.zsh-theme` |
| `omz/themes/catppuccin-flavors/` | `~/.oh-my-zsh/custom/themes/catppuccin-flavors` |
| `ssh/config` | `~/.ssh/config` — **copied, not linked**, and only if absent |

`~/.ssh` is permission-sensitive, so the SSH config is copied rather than symlinked, and only when nothing is there already.

## Shell Configuration

`home/.zshrc` is the stock Oh My Zsh template with the theme set, followed by a loop that sources `zsh/*.zsh` in order. The numeric prefixes matter: the glob sorts alphabetically, and `10-aliases.zsh` depends on `$EDITOR` being exported by `00-exports.zsh` first.

For anything machine-specific or private, copy `zsh/local.zsh.example` to `zsh/local.zsh` (gitignored), or write `~/.zshrc.local`. Both are sourced last, so either can override everything above.

### The Catppuccin Theme

Oh My Zsh doesn't ship a catppuccin theme, so it's vendored here and linked into `$ZSH_CUSTOM/themes/`. On the machine this repo came from it had been dropped into `~/.oh-my-zsh/themes/` instead — untracked by Oh My Zsh's own git repo, where a reinstall would have silently deleted it and reverted the prompt to the default.

The theme resolves its flavor files relative to itself via `${0:A:h}`, and `:A` fully resolves symlinks, so it finds `catppuccin-flavors/` back in the repo. Switch flavors with `CATPPUCCIN_FLAVOR` in `home/.zshrc` — `latte`, `frappe`, `macchiato` or `mocha`.

## Neovim

A LazyVim setup. `lua/plugins/colorscheme.lua` pins catppuccin-macchiato and is the only real customization; `lua/config/{options,keymaps,autocmds}.lua` are still empty stubs waiting to be filled in.

Both `lazy-lock.json` and `lazyvim.json` are committed on purpose. The lock file pins exact plugin revisions, and `lazyvim.json` records the enabled extras — php, typescript (+vtsls), vue, tailwind, python, go, java, sql, docker, markdown, yaml, json, git, prettier, yanky and dial. Together they're what make a new machine come up identical rather than merely similar.

Mason's LSP servers are machine state rather than config and aren't tracked here — run `:Mason` after the first launch.

## Git

`home/.gitconfig` carries settings and aliases but deliberately has no `[user]` block. It includes `~/.gitconfig.local`, which `scripts/git-identity.sh` generates and which is never committed. `config/git/ignore` is the global excludes file.

## What's Not Tracked

Excluded on purpose, either because it's secret or because it's rebuildable state:

- **Secrets** — SSH private keys, `~/.claude.json` (OAuth account and machine ID), anything matching `*.local`, `.env`, `*.pem`, `*.key`.
- **Session state** — `~/.zsh_history`, `.zcompdump-*` (hostname-specific), `~/.viminfo`.
- **Rebuildable** — `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/*`. Plugins and LSP servers reinstall from the lock file.
- **Machine-local** — `~/.config/jgit/config` (PhpStorm's per-disk filesystem timing cache), `~/.gradle`, `~/.npm`.

Sublime Text's preferences are a single small file that Package Control regenerates, and Warp cloud-syncs its own settings; neither is worth tracking.

## Contributing

This is my personal setup, so I'm not looking for pull requests, but you're welcome to borrow anything from it under the license below.

## License

Released under the [MIT License](LICENSE).

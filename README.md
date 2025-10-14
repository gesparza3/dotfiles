# Grant Esparza Dotfiles

This repository manages dotfiles using [chezmoi](https://www.chezmoi.io/) for both macOS and Ubuntu/WSL systems. It automates setup for the shell, terminal, editor, and CLI tools.

## Repository Structure

```
~/.local/share/chezmoi/
├── Brewfile
├── README.md
├── dot_tmux.conf
├── dot_zshrc
├── dot_config/
│   ├── kitty/
│   ├── nvim/
│   └── ranger/
├── run_once_install_homebrew.sh.tmpl
├── run_once_install_ohmyzsh.sh.tmpl
├── run_once_install_ranger_devicons.sh.tmpl
└── run_once_install_kitty_themes.sh.tmpl
```

## Setup

To initialize on a new machine:

```bash
chezmoi init git@github.com:gesparza3/dotfiles.git
chezmoi apply --verbose
```

ChezMoi will:
1. Install Homebrew (macOS or Linuxbrew).
2. Apply the Brewfile to install core tools.
3. Install Oh My Zsh, Zsh plugins, Ranger devicons, and Kitty themes.
4. Apply configuration files under ~/.config.

## Homebrew Management

Works on both macOS and Ubuntu (Linuxbrew). The Brewfile defines the packages to install.

Example Brewfile:
```bash
brew "zsh"
brew "tmux"
brew "ranger"
brew "neovim"
brew "fzf"
brew "ripgrep"
brew "git"
cask "kitty"  # macOS-only
```

Sync with Brewfile:
```bash
brew bundle --file ~/.local/share/chezmoi/Brewfile
brew bundle cleanup --force --file ~/.local/share/chezmoi/Brewfile
```

## Zsh and Oh My Zsh

### Plugin Management

Plugins and themes are declared in:
```
~/.config/zsh/plugins.txt
~/.config/zsh/theme.txt
```

The installation script clones external plugins automatically on first setup. `.zshrc` dynamically reads from those files.

Example `plugins.txt`:
```
git
fzf
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
```

To add a plugin:
1. Add its GitHub `owner/repo` to `plugins.txt`.
2. Run `chezmoi apply`.

## Neovim

- Uses init.lua with [lazy.nvim](https://github.com/folke/lazy.nvim).
- lazy-lock.json is tracked for reproducible plugin versions.

## Ranger

Custom configuration and the devicons plugin are installed automatically.

Config files:
- ~/.config/ranger/rc.conf
- ~/.config/ranger/rifle.conf
- ~/.config/ranger/commands.py

## Kitty (macOS Only)

Kitty configuration and themes are managed through `run_once_install_kitty_themes.sh.tmpl` and are ignored on Linux/WSL.

## Cross-Platform Behavior

| Component | macOS | Ubuntu / WSL |
|------------|-------|---------------|
| Homebrew | /opt/homebrew | /home/linuxbrew/.linuxbrew |
| Kitty | Installed | Ignored |
| Oh My Zsh | Installed | Installed |
| Brewfile | Shared | Shared |
| GUI Tools | Installed via cask | Skipped |

## Maintenance

| Task | Command |
|------|----------|
| Re-add modified configs | `chezmoi re-add ~/.config` |
| Preview changes | `chezmoi diff` |
| Apply safely | `chezmoi apply` |
| See tracked files | `chezmoi managed` |
| Check health | `chezmoi doctor` |
| Update Brewfile | `brew bundle dump --file ~/.local/share/chezmoi/Brewfile` |

## Suggested Aliases

Add these to `.zshrc` for convenience:

```bash
alias dot-sync='chezmoi re-add ~/.config ~/.zshrc ~/.tmux.conf && chezmoi diff'
alias dot-apply='chezmoi apply --verbose && chezmoi git commit -am "sync dotfiles" && chezmoi git push'
alias brew-sync='brew bundle --file ~/.local/share/chezmoi/Brewfile && brew bundle cleanup --force --file ~/.local/share/chezmoi/Brewfile'
```

## Ignored Files

`.chezmoiignore` ensures plugin caches and large directories are excluded.

```
.config/nvim/lazy/
.config/kitty/kitty-themes/
.config/ranger/plugins/
**/.cache/
**/__pycache__/
.oh-my-zsh/
```

## Notes

- All run_once scripts execute once per machine.
- To rerun, delete chezmoi’s state file:

```bash
chezmoi state delete-bucket run_once
chezmoi apply
```

Maintainer: Grant Esparza


# Grant Esparza Dotfiles

This repository manages dotfiles using [chezmoi](https://www.chezmoi.io/) for both macOS and Ubuntu/WSL systems. It automates setup for the shell, terminal, editor, and CLI tools.

## Key Updates
- **Replaced Oh My Zsh** with a faster stack:
  - [Antidote](https://getantidote.github.io/) for plugin management.
  - [Starship](https://starship.rs/) for a cross-shell, lightweight prompt.
- Added **brew_sync** helper to keep your Brewfile and chezmoi state synchronized.

---

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
├── run_once_install_antidote.sh.tmpl
├── run_once_install_ranger_devicons.sh.tmpl
└── run_once_install_kitty_themes.sh.tmpl
```

---

## Setup

To initialize on a new machine:

```bash
chezmoi init git@github.com:gesparza3/dotfiles.git
chezmoi apply --verbose
```

ChezMoi will:
1. Install Homebrew (macOS or Linuxbrew).
2. Apply the Brewfile to install core tools.
3. Install Antidote, Zsh plugins, Ranger devicons, and Kitty themes.
4. Apply configuration files under ~/.config.

---

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

### Brew Sync Helper

```bash
#############################################
# Brewfile / chezmoi sync helper
#############################################
brew_sync() {
  local brewfile="$HOME/Brewfile"
  local chezmoi_src="$HOME/.local/share/chezmoi/Brewfile"

  echo "Exporting installed packages to $brewfile..."
  if command -v brew >/dev/null 2>&1; then
    brew bundle dump --force --file="$brewfile"
  else
    echo "Homebrew not found, skipping dump."
    return 1
  fi

  echo "Syncing Brewfile with chezmoi..."
  chezmoi re-add "$brewfile"

  echo "Checking diff before apply..."
  chezmoi diff

  echo "To finalize, run: chezmoi apply"
}

alias brew-sync='brew_sync'
```

### How it works
- Exports installed packages to `~/Brewfile` using `brew bundle dump`.
- Re-adds the file to chezmoi for tracking.
- Shows you the diff before applying changes.

### Usage
```bash
brew-sync
```
That command will:
1. Recreate your Brewfile from what’s installed.
2. Stage it for chezmoi tracking.
3. Let you confirm updates with `chezmoi diff` before committing or applying.

---

## Zsh with Antidote & Starship

### Plugin Management

Plugins are declared in:
```
~/.config/zsh/plugins.txt
```

Example `plugins.txt`:
```
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
zdharma-continuum/fast-syntax-highlighting
popstas/zsh-command-time
```

### Prompt
[Starship](https://starship.rs/) provides a fast, cross-shell prompt. Configure it via:
```
~/.config/starship.toml
```

Example:
```toml
add_newline = false
command_timeout = 800

[directory]
truncation_length = 2
truncation_symbol = "…/"
style = "blue bold"

[character]
success_symbol = "[╰─❯](bold green) "
error_symbol   = "[╰─❯](bold red) "
```

---

## Neovim

- Uses init.lua with [lazy.nvim](https://github.com/folke/lazy.nvim).
- `lazy-lock.json` is tracked for reproducible plugin versions.

---

## Ranger

Custom configuration and the devicons plugin are installed automatically.

Config files:
- ~/.config/ranger/rc.conf
- ~/.config/ranger/rifle.conf
- ~/.config/ranger/commands.py

---

## Kitty (macOS Only)

Kitty configuration and themes are managed through `run_once_install_kitty_themes.sh.tmpl` and are ignored on Linux/WSL.

---

## Cross-Platform Behavior

| Component | macOS | Ubuntu / WSL |
|------------|-------|---------------|
| Homebrew | /opt/homebrew | /home/linuxbrew/.linuxbrew |
| Kitty | Installed | Ignored |
| Antidote | Installed | Installed |
| Starship | Installed | Installed |
| Brewfile | Shared | Shared |
| GUI Tools | Installed via cask | Skipped |

---

## Maintenance

| Task | Command |
|------|----------|
| Re-add modified configs | `chezmoi re-add ~/.config` |
| Preview changes | `chezmoi diff` |
| Apply safely | `chezmoi apply` |
| See tracked files | `chezmoi managed` |
| Check health | `chezmoi doctor` |
| Update Brewfile | `brew-sync` |

---

## Suggested Aliases

Add these to `.zshrc` for convenience:

```bash
alias dot-sync='chezmoi re-add ~/.config ~/.zshrc ~/.tmux.conf && chezmoi diff'
alias dot-apply='chezmoi apply --verbose && chezmoi git commit -am "sync dotfiles" && chezmoi git push'
alias brew-sync='brew_sync'
```

---

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

---

## Notes

- All `run_once` scripts execute once per machine.
- To rerun, delete chezmoi’s state file:

```bash
chezmoi state delete-bucket run_once
chezmoi apply
```


# Dotfiles

Personal dotfiles for zsh. Works on host machines and devcontainers.

## Installation

```bash
git clone https://github.com/jmcejudo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script works with both bash and zsh, and is idempotent - safe to run multiple times.

## What's Included

### Shell

- **Oh My Zsh** with robbyrussell theme
- **Plugins**: git, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions
- **SSH agent**: auto-started if not already running (no systemd dependency)

### Tools

| Tool | Description | Usage |
|------|-------------|-------|
| **zoxide** | Smart cd | `z project` jumps to matching directory |
| **fzf** | Fuzzy finder | `Ctrl+R` history, `Ctrl+T` files, `Alt+C` dirs |

### Aliases

**Navigation**: `..`, `...`, `....`

**Git**: `g`, `gs`, `ga`, `gc`, `gca`, `gcan`, `gp`, `gpl`, `gd`, `gds`, `gl`, `glo`, `glast`, `gb`, `gba`, `gco`, `gsw`, `gst`, `gstp`, `gstl`, `gunstage`, `gundo`

**Utilities**: `mkcd`, `extract`, `path`, `reload`, `c`

**Safety**: `cp`, `mv`, `rm` prompt before overwrite

## Customization

### Local Shell Config

Create `~/.zshrc.local` for machine-specific settings (not tracked in git).

### Adding Plugins

1. Add to `ZSH_PLUGINS` in `bootstrap.sh`
2. Add to `plugins` array in `.zshrc`

## Devcontainer Support

Works automatically in VS Code devcontainers.

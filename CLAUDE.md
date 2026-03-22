# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles repository for managing zsh shell configuration and environment setup. Designed to be cloned to `~/.dotfiles` and installed via the bootstrap script. Works on both host machines and devcontainers.

## Key Commands

```bash
# Install/update dotfiles (idempotent - safe to run multiple times)
./bootstrap.sh
```

## What Bootstrap Does

1. Installs Oh My Zsh (if not present)
2. Symlinks `.zshrc` and `.aliases` to home directory
3. Installs/updates zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
4. Installs zoxide (smart cd) and fzf (fuzzy finder)

## Architecture

### Configuration Files

| File | Purpose |
|------|---------|
| `.zshrc` | Oh My Zsh setup, plugins, environment |
| `.aliases` | Shell aliases and utility functions (includes git aliases) |

### User Customization (not tracked)

- `~/.zshrc.local` - Machine-specific shell config

## Development Patterns

- **Idempotent**: Bootstrap can run multiple times safely (checks before modifying)
- **Defensive scripting**: `set -e`, `set -u`, `set -o pipefail`
- **Non-destructive**: Only backs up when actually modifying files
- **XDG compliance**: Uses XDG Base Directory specification

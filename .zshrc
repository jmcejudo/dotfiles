# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Auto-update Oh My Zsh without asking
zstyle ':omz:update' mode auto

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes

source $ZSH/oh-my-zsh.sh

# --- User configuration ---

# Source nvm if available
if [ -f /usr/share/nvm/init-nvm.sh ]; then
    source /usr/share/nvm/init-nvm.sh
fi

# Source custom aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# SSH agent (skip in dev containers)
if [ -z "$REMOTE_CONTAINERS" ]; then
  export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
fi

# Set DOTFILES_REPO_URL with multi-layered fallback
if [ -z "${DOTFILES_REPO_URL:-}" ]; then
    # Try systemd environment first
    if command -v systemctl >/dev/null 2>&1; then
        DOTFILES_REPO_URL=$(systemctl --user show-environment 2>/dev/null | grep '^DOTFILES_REPO_URL=' | cut -d= -f2- 2>/dev/null || true)
    fi

    # Fallback to runtime env file
    if [ -z "${DOTFILES_REPO_URL:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -f "$XDG_RUNTIME_DIR/dotfiles.env" ]; then
        source "$XDG_RUNTIME_DIR/dotfiles.env"
    fi

    # Final fallback: compute from git
    if [ -z "${DOTFILES_REPO_URL:-}" ] && [ -d "${HOME}/dotfiles" ]; then
        DOTFILES_REPO_URL=$(cd "${HOME}/dotfiles" && git remote get-url origin 2>/dev/null || true)
        export DOTFILES_REPO_URL
    fi
fi

# fzf - fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C directories)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# zoxide - smart cd (use 'z' instead of 'cd')
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Source local customizations (not tracked in git)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

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

# SSH agent - start if not already running (skip in dev containers)
if [ -z "${REMOTE_CONTAINERS:-}" ]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.socket"
    if ! ssh-add -l &>/dev/null; then
        eval "$(ssh-agent -a "$SSH_AUTH_SOCK" 2>/dev/null)" >/dev/null
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

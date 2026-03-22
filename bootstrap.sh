#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Bootstrap Script
#
# This script sets up the dotfiles environment by creating symlinks
# and installing plugins.
# ==============================================================================

# --- Configuration and Constants ---

# Exit on any error, treat unset variables as an error, and exit on pipe fails.
set -e
set -u
set -o pipefail

# Directory where this script is located.
if [[ -n "${ZSH_VERSION:-}" ]]; then
    readonly DOTFILES_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
else
    readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Directory to back up existing dotfiles.
readonly BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"

# List of files/directories to symlink to the home directory.
readonly FILES_TO_SYMLINK=(
    '.zshrc'
    '.aliases'
)

# Associative array of Zsh plugins and their repository URLs.
declare -A -r ZSH_PLUGINS=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

# Directory for fzf installation.
readonly FZF_DIR="$HOME/.fzf"

# Directory for custom Zsh plugins.
readonly ZSH_CUSTOM_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# --- Helper Functions ---

# Prints a message with a specified color.
# Usage: message <color> <text>
function message() {
    local color="$1"
    local text="$2"
    local color_code=""
    case "$color" in
        "green") color_code="\033[32m" ;;
        "yellow") color_code="\033[33m" ;;
        "red") color_code="\033[31m" ;;
    esac
    echo -e "${color_code}${text}\033[0m"
}

# --- Setup Functions ---

# Checks for required command-line tools.
function check_dependencies() {
    message "yellow" "Checking for dependencies..."
    local has_error=0
    for cmd in git zsh curl; do
        if ! command -v "$cmd" &> /dev/null; then
            message "red" "Error: '$cmd' is not installed. Please install it to continue."
            has_error=1
        fi
    done
    if [[ "$has_error" -eq 1 ]]; then
        exit 1
    fi
}

# Installs Oh My Zsh if not already installed.
function install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        message "green" "Oh My Zsh is already installed."
        return
    fi

    message "yellow" "Oh My Zsh not found. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    message "green" "Oh My Zsh installed successfully."
}

# Backs up existing files and creates symlinks.
# Idempotent: skips if symlink already points to correct target.
function backup_and_symlink() {
    message "yellow" "Setting up symlinks..."
    local backup_created=false

    for file in "${FILES_TO_SYMLINK[@]}"; do
        local source_file="$DOTFILES_DIR/$file"
        local target_file="$HOME/$file"

        # Already correct symlink → skip
        if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
            message "green" "Symlink already correct: $file"
            continue
        fi

        # Backup existing file/symlink if present
        if [[ -e "$target_file" || -L "$target_file" ]]; then
            if [[ "$backup_created" == false ]]; then
                mkdir -p "$BACKUP_DIR"
                message "yellow" "Backing up to $BACKUP_DIR"
                backup_created=true
            fi
            mv "$target_file" "$BACKUP_DIR/"
            message "yellow" "Backed up $file"
        fi

        ln -s "$source_file" "$target_file"
        message "green" "Created symlink: $file"
    done
}

# Clones or updates Zsh plugins from their repositories.
function manage_zsh_plugins() {
    message "yellow" "Installing/updating Zsh plugins..."
    mkdir -p "$ZSH_CUSTOM_PLUGINS_DIR"

    if [[ -n "${ZSH_VERSION:-}" ]]; then
        local plugin_names=("${(@k)ZSH_PLUGINS}")
    else
        local plugin_names=("${!ZSH_PLUGINS[@]}")
    fi
    for plugin_name in "${plugin_names[@]}"; do
        local plugin_url="${ZSH_PLUGINS[$plugin_name]}"
        local plugin_dir="$ZSH_CUSTOM_PLUGINS_DIR/$plugin_name"

        if [ ! -d "$plugin_dir" ]; then
            message "green" "Installing plugin '$plugin_name'..."
            git clone --depth=1 "$plugin_url" "$plugin_dir"
        else
            message "yellow" "Updating plugin '$plugin_name'..."
            (cd "$plugin_dir" && git fetch origin && git reset --hard origin/HEAD)
        fi
    done
}

# Installs zoxide (smart cd replacement).
function install_zoxide() {
    if command -v zoxide &> /dev/null; then
        message "green" "zoxide is already installed."
        return
    fi

    message "yellow" "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    message "green" "zoxide installed successfully."
}

# Installs fzf (fuzzy finder).
function install_fzf() {
    if [[ -d "$FZF_DIR" ]]; then
        message "yellow" "Updating fzf..."
        (cd "$FZF_DIR" && git fetch origin && git reset --hard origin/HEAD && ./install --key-bindings --completion --no-update-rc)
    else
        message "yellow" "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
        "$FZF_DIR/install" --key-bindings --completion --no-update-rc
    fi
    message "green" "fzf installed successfully."
}

# --- Main Logic ---

function main() {
    message "green" "Starting dotfiles setup..."
    check_dependencies
    install_oh_my_zsh
    backup_and_symlink
    manage_zsh_plugins
    install_zoxide
    install_fzf
    message "green" "\nDotfiles setup complete!"
    message "green" "Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main

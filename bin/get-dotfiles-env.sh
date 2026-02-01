#!/usr/bin/env bash

# Exit on any error
set -e

echo "Starting get-dotfiles-env.sh" >&2

# Find the directory where the dotfiles are located.
# This script assumes that it is located in a 'bin' subdirectory of the dotfiles repository.
DOTFILES_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR" >&2

# Get the repository URL from the 'origin' remote.
DOTFILES_REPO_URL=$(cd "$DOTFILES_DIR" && git remote get-url origin 2>/dev/null || true)
echo "Dotfiles repo URL: $DOTFILES_REPO_URL" >&2

# If we couldn't get a URL, exit gracefully.
if [ -z "$DOTFILES_REPO_URL" ]; then
    echo "No repo URL found. Exiting." >&2
    exit 0
fi

# --- Systemd Integration ---
# If systemd user instance is running, set the environment variable for the session.
echo "Checking for systemd..." >&2
if command -v systemctl >/dev/null 2>&1; then
    # Try multiple methods to detect if systemd user session is available
    if systemctl --user is-active --quiet dbus.service 2>/dev/null || \
       systemctl --user status >/dev/null 2>&1 || \
       [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -S "$XDG_RUNTIME_DIR/systemd/private" ]; then
        echo "Systemd user session active. Setting environment variable." >&2
        if systemctl --user set-environment DOTFILES_REPO_URL="$DOTFILES_REPO_URL" 2>/dev/null; then
            echo "Successfully set DOTFILES_REPO_URL in systemd environment." >&2
        else
            echo "Warning: Failed to set systemd environment variable." >&2
        fi
    else
        echo "Systemd not available or user session not active." >&2
    fi
else
    echo "Systemctl command not available." >&2
fi

# --- Shell Integration ---
# Create an environment file in XDG_RUNTIME_DIR for shell sessions to source.
# This is a fallback for environments where systemd isn't used or the variable isn't available.
echo "Checking for XDG_RUNTIME_DIR..." >&2
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    echo "XDG_RUNTIME_DIR found: $XDG_RUNTIME_DIR. Creating dotfiles.env file." >&2
    printf "export DOTFILES_REPO_URL=%q\n" "$DOTFILES_REPO_URL" > "$XDG_RUNTIME_DIR/dotfiles.env"
else
    echo "XDG_RUNTIME_DIR not set or not a directory." >&2
fi

echo "get-dotfiles-env.sh finished." >&2

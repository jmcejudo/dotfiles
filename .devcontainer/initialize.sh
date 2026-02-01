#!/usr/bin/env bash
# Initialize host directories for devcontainer mounts
# Runs on host before container creation (initializeCommand)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$(dirname "$SCRIPT_DIR")/.cache"

# Create cache directories
mkdir -p \
    "$CACHE_DIR/claude" \
    "$CACHE_DIR/gemini" \
    "$CACHE_DIR/codex"

# Create files that need to exist for bind mounts
touch "$CACHE_DIR/zsh_history"
touch "$CACHE_DIR/claude.json"

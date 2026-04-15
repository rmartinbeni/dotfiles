#!/bin/bash

# Exit on error
set -e

# Setup dotfiles in GitHub Codespaces
echo "🚀 Setting up dotfiles for GitHub Codespaces..."

# Install Chezmoi if not available
if ! command -v chezmoi >/dev/null; then
    echo "📦 Installing Chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Apply dotfiles non-interactively
echo "⚙️ Applying dotfiles..."
# GitHub Codespaces usually run in a non-interactive shell where stdinIsATTY is false.
# Our updated .chezmoi.toml.tmpl handles this safely without blocking.
chezmoi init --apply --source "$PWD"

echo "✅ Dotfiles applied successfully!"

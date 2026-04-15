# Dotfiles Setup with Chezmoi

A highly flexible, OS-agnostic dotfiles configuration tailored for agentic development, modern CLI tools, and maximum strictness.

## Supported OS
- macOS (uses `brew`)
- Linux (uses `apt`)
- Windows (uses `winget`)
- GitHub Codespaces

## Requirements

- Git

## Installation

### Standard Installation
The installation process installs `chezmoi` if it is not present and applies the dotfiles interactively.

```bash
# Using curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply rmartinbeni

# If you already have chezmoi
chezmoi init --apply rmartinbeni
```

### GitHub Codespaces
These dotfiles natively support GitHub Codespaces! When creating a codespace, the included `.devcontainer/devcontainer.json` will automatically run `./install.sh`, configuring the environment and installing essential tools.

## Included Tools
When applied, Chezmoi will detect your OS and install modern utilities:

- **NVM & Node**: Automatically manages `nvm` and installs the latest version of Node.
- **Modern CLI**: `ripgrep`, `bat`, `eza`, `zoxide`, `jq`
- **Editors**: Nano, Neovim, VSCode, Ghostty terminal emulator
- **Agent Utilities**: `geminicli` is installed globally.
- **Git GPG**: Native setup script to generate and configure ed25519 GPG keys for commit signing.

## Aliases & Zsh

Your Zsh configuration natively integrates with `zoxide` (better `cd`), `fzf` (fuzzy finding), `eza` (better `ls`), and `bat` (better `cat`).

## `init-agentic-frontend`

Because maintaining high code quality is critical in an agentic coding environment, a binary named `init-agentic-frontend` is installed in your path (`~/.local/bin/`).

Run it in any empty directory to scaffold an extremely strict frontend environment:
```bash
init-agentic-frontend
```

It will:
1. Initialize `package.json`
2. Setup strict ESLint + Prettier + TypeScript rules
3. Setup `husky` and `lint-staged` with pre-commit hooks to ensure code formatting and checks pass before any commit.

# Dotfiles Setup with Chezmoi

## Requirements

- Chezmoi installed ([install guide](https://www.chezmoi.io/install/))
- Git for cloning the repo
- (Optional) GPG configured if you use encrypted secrets or commit signing

## Clone and apply dotfiles

Run on the new machine:

```bash
chezmoi init --apply git@github.com:rmartinbeni/dotfiles.git
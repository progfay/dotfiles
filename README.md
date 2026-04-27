# progfay/dotfiles

My dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Setup

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply progfay
```

dotfiles sources are located at: `~/.local/share/chezmoi`

## Manage dotfiles

```sh
# Reflect edited files back to source
chezmoi re-add <file>

# Add a new file
chezmoi add <file>

# Check diff between source and home
chezmoi diff

# Apply source state to home directory
chezmoi apply

# Pull changes from GitHub and apply
chezmoi update
```


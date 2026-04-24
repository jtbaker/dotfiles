#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Backup existing nvim config if it exists and isn't a symlink
if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
  echo "Backing up existing nvim config to ~/.config/nvim.backup"
  mv ~/.config/nvim ~/.config/nvim.backup
fi

# Create .config if it doesn't exist
mkdir -p ~/.config

# Remove existing symlink if present
rm -f ~/.config/nvim

# Symlink nvim config
ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
echo "Linked nvim config"

# Backup existing pi config if it exists and isn't a symlink
if [ -e ~/.pi/agent ] && [ ! -L ~/.pi/agent ]; then
  echo "Backing up existing pi config to ~/.pi/agent.backup"
  mv ~/.pi/agent ~/.pi/agent.backup
fi

# Remove existing symlink if present
rm -f ~/.pi/agent

# Symlink pi agent config
ln -s "$DOTFILES_DIR/pi/agent" ~/.pi/agent
echo "Linked pi agent config"

echo ""
echo "Done! Install these language servers for full LSP support:"
echo "  pip install basedpyright"
echo "  npm install -g typescript typescript-language-server"
echo "  go install golang.org/x/tools/gopls@latest"
echo "  rustup component add rust-analyzer"
echo "  brew install lua-language-server  # or your package manager"
echo ""
echo "Then open nvim and run :Lazy to install plugins."

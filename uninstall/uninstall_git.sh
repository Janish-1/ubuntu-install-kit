#!/bin/bash
set -e

# Check if Git is installed
if command -v git &> /dev/null; then
  echo "🗑️ Uninstalling Git..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Git. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove Git
  sudo apt remove -y git git-core
  sudo apt autoremove -y
  
  # Ask if user wants to remove Git configuration
  read -p "Do you want to remove Git configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$HOME/.gitconfig" ]; then
      rm "$HOME/.gitconfig"
      echo "✅ Git global configuration removed."
    fi
    
    if [ -d "$HOME/.git" ]; then
      rm -rf "$HOME/.git"
    fi
  fi
  
  echo "✅ Git has been uninstalled."
else
  echo "✅ Git is not installed."
fi
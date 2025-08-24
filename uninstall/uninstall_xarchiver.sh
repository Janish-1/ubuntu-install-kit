#!/bin/bash
set -e

# Check if XArchiver is installed
if dpkg -l | grep -q "xarchiver"; then
  echo "🗑️ Uninstalling XArchiver..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove XArchiver. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove XArchiver
  sudo apt remove -y xarchiver
  sudo apt autoremove -y
  
  # Remove configuration
  read -p "Do you want to remove XArchiver configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/xarchiver" ]; then
      rm -rf "$HOME/.config/xarchiver"
      echo "✅ XArchiver configuration removed."
    fi
  fi
  
  echo "✅ XArchiver has been uninstalled."
else
  echo "✅ XArchiver is not installed."
fi
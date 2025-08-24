#!/bin/bash
set -e

# Check if blueman is installed
if dpkg -l | grep -q "blueman"; then
  echo "🗑️ Uninstalling blueman..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove blueman Bluetooth manager. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove blueman
  sudo apt remove -y blueman
  sudo apt autoremove -y
  
  # Remove configuration
  read -p "Do you want to remove blueman configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/blueman" ]; then
      rm -rf "$HOME/.config/blueman"
      echo "✅ blueman configuration removed."
    fi
  fi
  
  echo "✅ blueman has been uninstalled."
else
  echo "✅ blueman is not installed."
fi
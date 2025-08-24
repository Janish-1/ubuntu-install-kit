#!/bin/bash
set -e

# Check if FreeFileSync is installed
if [ -d "/opt/FreeFileSync" ] || [ -d "$HOME/FreeFileSync" ]; then
  echo "🗑️ Uninstalling FreeFileSync..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove FreeFileSync. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove FreeFileSync directories
  if [ -d "/opt/FreeFileSync" ]; then
    sudo rm -rf "/opt/FreeFileSync"
  fi
  
  if [ -d "$HOME/FreeFileSync" ]; then
    rm -rf "$HOME/FreeFileSync"
  fi
  
  # Remove desktop shortcut
  if [ -f "$HOME/.local/share/applications/FreeFileSync.desktop" ]; then
    rm "$HOME/.local/share/applications/FreeFileSync.desktop"
  fi
  
  if [ -f "/usr/share/applications/FreeFileSync.desktop" ]; then
    sudo rm "/usr/share/applications/FreeFileSync.desktop"
  fi
  
  # Remove configuration
  read -p "Do you want to remove FreeFileSync configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/FreeFileSync" ]; then
      rm -rf "$HOME/.config/FreeFileSync"
      echo "✅ FreeFileSync configuration removed."
    fi
  fi
  
  echo "✅ FreeFileSync has been uninstalled."
else
  echo "✅ FreeFileSync is not installed."
fi
#!/bin/bash
set -e

# Check if rsync is installed
if command -v rsync &> /dev/null; then
  echo "🗑️ Uninstalling rsync..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove rsync. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove rsync
  sudo apt remove -y rsync
  sudo apt autoremove -y
  
  # Remove configuration
  if [ -f "$HOME/.rsync.conf" ]; then
    read -p "Do you want to remove rsync configuration file? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm "$HOME/.rsync.conf"
      echo "✅ rsync configuration removed."
    fi
  fi
  
  echo "✅ rsync has been uninstalled."
else
  echo "✅ rsync is not installed."
fi
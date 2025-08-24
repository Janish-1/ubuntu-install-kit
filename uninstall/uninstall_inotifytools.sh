#!/bin/bash
set -e

# Check if inotify-tools is installed
if dpkg -l | grep -q "inotify-tools"; then
  echo "🗑️ Uninstalling inotify-tools..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove inotify-tools. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove inotify-tools
  sudo apt remove -y inotify-tools
  sudo apt autoremove -y
  
  echo "✅ inotify-tools has been uninstalled."
else
  echo "✅ inotify-tools is not installed."
fi
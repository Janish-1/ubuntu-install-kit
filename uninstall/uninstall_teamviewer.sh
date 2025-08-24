#!/bin/bash
set -e

# Check if TeamViewer is installed
if dpkg -l | grep -q "teamviewer"; then
  echo "🗑️ Uninstalling TeamViewer..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove TeamViewer. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Stop TeamViewer service
  if systemctl is-active --quiet teamviewerd; then
    echo "🛑 Stopping TeamViewer service..."
    sudo systemctl stop teamviewerd
  fi
  
  # Remove TeamViewer
  echo "🗑️ Removing TeamViewer packages..."
  sudo apt remove --purge -y teamviewer
  sudo apt autoremove -y
  
  # Remove TeamViewer repository
  if [ -f /etc/apt/sources.list.d/teamviewer.list ]; then
    sudo rm /etc/apt/sources.list.d/teamviewer.list
  fi
  
  # Remove configuration
  read -p "Do you want to remove TeamViewer configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/teamviewer" ]; then
      rm -rf "$HOME/.config/teamviewer"
    fi
    
    if [ -d "/opt/teamviewer" ]; then
      sudo rm -rf "/opt/teamviewer"
    fi
    
    echo "✅ TeamViewer configuration removed."
  fi
  
  echo "✅ TeamViewer has been uninstalled."
else
  echo "✅ TeamViewer is not installed."
fi
#!/bin/bash
set -e

# Check if FileZilla is installed
if dpkg -l | grep -q "filezilla"; then
  echo "🗑️ Uninstalling FileZilla..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove FileZilla. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove FileZilla
  sudo apt remove -y filezilla filezilla-common
  sudo apt autoremove -y
  
  # Remove configuration
  read -p "Do you want to remove FileZilla configuration and site manager data? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/filezilla" ]; then
      rm -rf "$HOME/.config/filezilla"
      echo "✅ FileZilla configuration removed."
    fi
    
    if [ -d "$HOME/.filezilla" ]; then
      rm -rf "$HOME/.filezilla"
    fi
  fi
  
  echo "✅ FileZilla has been uninstalled."
else
  echo "✅ FileZilla is not installed."
fi
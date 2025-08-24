#!/bin/bash
set -e

# Check if gedit is installed
if dpkg -l | grep -q "gedit"; then
  echo "🗑️ Uninstalling gedit..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove gedit. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove gedit
  sudo apt remove -y gedit gedit-common
  sudo apt autoremove -y
  
  # Remove configuration
  read -p "Do you want to remove gedit configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.config/gedit" ]; then
      rm -rf "$HOME/.config/gedit"
      echo "✅ gedit configuration removed."
    fi
  fi
  
  echo "✅ gedit has been uninstalled."
else
  echo "✅ gedit is not installed."
fi
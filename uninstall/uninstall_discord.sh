#!/bin/bash
set -e

# Check if Discord is installed via snap
if snap list | grep -q "discord"; then
  echo "🗑️ Uninstalling Discord (snap)..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Discord. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove Discord
  sudo snap remove discord
  
  echo "✅ Discord has been uninstalled."
else
  # Check if Discord is installed via deb package
  if dpkg -l | grep -q "discord"; then
    echo "🗑️ Uninstalling Discord (deb package)..."
    
    # Ask for confirmation
    read -p "⚠️ This will remove Discord. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "❌ Uninstallation aborted."
      exit 0
    fi
    
    # Remove Discord
    sudo apt remove --purge -y discord
    sudo apt autoremove -y
    
    echo "✅ Discord has been uninstalled."
  else
    # Check if Discord is installed manually
    if [ -d "/opt/Discord" ] || [ -d "$HOME/.local/share/Discord" ]; then
      echo "🗑️ Uninstalling Discord (manual installation)..."
      
      # Ask for confirmation
      read -p "⚠️ This will remove Discord. Continue? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Uninstallation aborted."
        exit 0
      fi
      
      # Remove Discord directories
      if [ -d "/opt/Discord" ]; then
        sudo rm -rf "/opt/Discord"
      fi
      
      if [ -d "$HOME/.local/share/Discord" ]; then
        rm -rf "$HOME/.local/share/Discord"
      fi
      
      # Remove desktop entry
      if [ -f "/usr/share/applications/discord.desktop" ]; then
        sudo rm "/usr/share/applications/discord.desktop"
      fi
      
      if [ -f "$HOME/.local/share/applications/discord.desktop" ]; then
        rm "$HOME/.local/share/applications/discord.desktop"
      fi
      
      echo "✅ Discord has been uninstalled."
    else
      echo "✅ Discord is not installed."
    fi
  fi
fi

# Remove Discord configuration
read -p "Do you want to remove Discord configuration and cache? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -d "$HOME/.config/discord" ]; then
    rm -rf "$HOME/.config/discord"
    echo "✅ Discord configuration removed."
  fi
  
  if [ -d "$HOME/.cache/discord" ]; then
    rm -rf "$HOME/.cache/discord"
    echo "✅ Discord cache removed."
  fi
fi
#!/bin/bash
set -e

# Check if VS Code is installed via snap
if snap list | grep -q "code"; then
  echo "🗑️ Uninstalling Visual Studio Code..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove VS Code and its data. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove VS Code
  sudo snap remove code
  
  echo "✅ Visual Studio Code has been uninstalled."
else
  # Check if VS Code is installed via apt
  if dpkg -l | grep -q "code"; then
    echo "🗑️ Uninstalling Visual Studio Code (apt package)..."
    
    # Ask for confirmation
    read -p "⚠️ This will remove VS Code and its data. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "❌ Uninstallation aborted."
      exit 0
    fi
    
    # Remove VS Code
    sudo apt remove -y code
    sudo apt autoremove -y
    
    # Remove the repository
    if [ -f /etc/apt/sources.list.d/vscode.list ]; then
      sudo rm /etc/apt/sources.list.d/vscode.list
    fi
    
    echo "✅ Visual Studio Code has been uninstalled."
  else
    echo "✅ Visual Studio Code is not installed."
  fi
fi

# Remove user settings if requested
read -p "Do you want to remove VS Code user settings? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -d "$HOME/.config/Code" ]; then
    rm -rf "$HOME/.config/Code"
    echo "✅ VS Code user settings have been removed."
  fi
  
  if [ -d "$HOME/.vscode" ]; then
    rm -rf "$HOME/.vscode"
    echo "✅ VS Code extensions have been removed."
  fi
fi
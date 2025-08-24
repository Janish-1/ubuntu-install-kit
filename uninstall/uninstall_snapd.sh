#!/bin/bash
set -e

# Check if snapd is installed
if dpkg -l | grep -q "snapd"; then
  echo "🗑️ Uninstalling snapd..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove snapd and all installed snap packages. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # List all installed snaps
  echo "📋 Currently installed snap packages:"
  snap list
  
  # Remove all installed snaps
  echo "🗑️ Removing all snap packages..."
  for package in $(snap list | awk 'NR>1 {print $1}'); do
    echo "🗑️ Removing snap package: $package"
    sudo snap remove "$package"
  done
  
  # Remove snapd
  echo "🗑️ Removing snapd..."
  sudo apt remove --purge -y snapd
  sudo apt autoremove -y
  
  # Clean up snap directories
  echo "🧹 Cleaning up snap directories..."
  sudo rm -rf /snap
  sudo rm -rf /var/snap
  sudo rm -rf /var/lib/snapd
  
  # Remove snap from PATH
  if grep -q "snap/bin" /etc/environment; then
    sudo sed -i 's|:/snap/bin||g' /etc/environment
  fi
  
  echo "✅ snapd has been completely uninstalled."
else
  echo "✅ snapd is not installed."
fi
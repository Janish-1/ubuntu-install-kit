#!/bin/bash
set -e

# ---- Python 3 and pip ----
if command -v python3 &> /dev/null; then
  echo "🗑️ Uninstalling Python 3..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Python 3 and all installed packages. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove pip packages first
  if command -v pip3 &> /dev/null; then
    echo "📦 Removing pip packages..."
    pip_packages=$(pip3 list --format=freeze | grep -v "^-e" | cut -d = -f 1)
    if [ -n "$pip_packages" ]; then
      echo "$pip_packages" | xargs -n 1 pip3 uninstall -y
    fi
  fi
  
  # Remove Python
  echo "🗑️ Removing Python packages..."
  sudo apt remove -y python3 python3-pip python3-venv
  sudo apt autoremove -y
  
  echo "✅ Python 3 has been uninstalled."
else
  echo "✅ Python 3 is not installed."
fi
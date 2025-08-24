#!/bin/bash
set -e

echo "🗑️ Uninstalling system monitoring tools..."

# Ask for confirmation
read -p "⚠️ This will remove system monitoring tools and scripts. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Uninstallation aborted."
  exit 0
fi

# Remove GNOME Shell extension if installed
if command -v gnome-extensions &> /dev/null; then
  if gnome-extensions list | grep -q "system-monitor@local"; then
    echo "🗑️ Removing system monitor GNOME extension..."
    gnome-extensions disable system-monitor@local
    
    if [ -d "$HOME/.local/share/gnome-shell/extensions/system-monitor@local" ]; then
      rm -rf "$HOME/.local/share/gnome-shell/extensions/system-monitor@local"
    fi
  fi
fi

# Remove system monitoring scripts
if [ -d "$HOME/.local/bin/system-metrics" ]; then
  echo "🗑️ Removing system monitoring scripts..."
  rm -rf "$HOME/.local/bin/system-metrics"
fi

# Remove system monitoring packages
echo "🗑️ Removing system monitoring packages..."
sudo apt remove -y gnome-shell-extension-manager lm-sensors
sudo apt autoremove -y

# Remove sensor configuration
if [ -f "/etc/sensors3.conf" ]; then
  sudo rm "/etc/sensors3.conf"
fi

echo "✅ System monitoring tools have been uninstalled."
echo "ℹ️ You may need to log out and log back in for all changes to take effect."
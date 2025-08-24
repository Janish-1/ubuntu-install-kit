#!/bin/bash
set -e

# Check if Samba is installed
if dpkg -l | grep -q "samba"; then
  echo "🗑️ Uninstalling Samba (SMB)..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Samba and its configuration. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Stop Samba services
  echo "🛑 Stopping Samba services..."
  sudo systemctl stop smbd nmbd
  
  # Backup configuration if requested
  read -p "Do you want to backup Samba configuration before removing? (Y/n): " -n 1 -r
  echo
  BACKUP_CONFIG=true
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    BACKUP_CONFIG=false
  fi
  
  if [ "$BACKUP_CONFIG" = true ] && [ -f "/etc/samba/smb.conf" ]; then
    BACKUP_FILE="$HOME/smb.conf.backup.$(date +%Y%m%d%H%M%S)"
    echo "📦 Backing up Samba configuration to $BACKUP_FILE"
    cp "/etc/samba/smb.conf" "$BACKUP_FILE"
  fi
  
  # Remove Samba packages
  echo "🗑️ Removing Samba packages..."
  sudo apt remove --purge -y samba samba-common samba-common-bin
  sudo apt autoremove -y
  
  # Remove configuration directory
  read -p "Do you want to completely remove Samba configuration directory? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "/etc/samba" ]; then
      sudo rm -rf "/etc/samba"
    fi
    echo "✅ Samba configuration directory removed."
  fi
  
  echo "✅ Samba (SMB) has been uninstalled."
  
  if [ "$BACKUP_CONFIG" = true ] && [ -f "$BACKUP_FILE" ]; then
    echo "ℹ️ Your Samba configuration was backed up to: $BACKUP_FILE"
  fi
else
  echo "✅ Samba (SMB) is not installed."
fi
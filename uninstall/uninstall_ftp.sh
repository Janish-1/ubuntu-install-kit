#!/bin/bash
set -e

# Check if vsftpd is installed
if dpkg -l | grep -q "vsftpd"; then
  echo "🗑️ Uninstalling FTP server (vsftpd)..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove the FTP server. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Stop FTP service
  echo "🛑 Stopping FTP service..."
  sudo systemctl stop vsftpd
  
  # Backup configuration if requested
  read -p "Do you want to backup FTP configuration before removing? (Y/n): " -n 1 -r
  echo
  BACKUP_CONFIG=true
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    BACKUP_CONFIG=false
  fi
  
  if [ "$BACKUP_CONFIG" = true ] && [ -f "/etc/vsftpd.conf" ]; then
    BACKUP_FILE="$HOME/vsftpd.conf.backup.$(date +%Y%m%d%H%M%S)"
    echo "📦 Backing up FTP configuration to $BACKUP_FILE"
    cp "/etc/vsftpd.conf" "$BACKUP_FILE"
  fi
  
  # Remove vsftpd
  echo "🗑️ Removing FTP server packages..."
  sudo apt remove --purge -y vsftpd
  sudo apt autoremove -y
  
  # Remove FTP user if it exists
  if id "ftp" &>/dev/null; then
    echo "🗑️ Removing FTP user..."
    sudo deluser ftp
  fi
  
  # Remove FTP directory
  if [ -d "/srv/ftp" ]; then
    read -p "Do you want to remove the FTP directory and all its contents? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo rm -rf "/srv/ftp"
      echo "✅ FTP directory removed."
    fi
  fi
  
  echo "✅ FTP server has been uninstalled."
  
  if [ "$BACKUP_CONFIG" = true ] && [ -f "$BACKUP_FILE" ]; then
    echo "ℹ️ Your FTP configuration was backed up to: $BACKUP_FILE"
  fi
else
  echo "✅ FTP server (vsftpd) is not installed."
fi
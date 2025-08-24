#!/bin/bash
set -e

# Check if qBittorrent is installed
if dpkg -l | grep -q "qbittorrent"; then
  echo "🗑️ Uninstalling qBittorrent..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove qBittorrent. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Ask about preserving torrent files and downloads
  read -p "Do you want to preserve your torrent files and download history? (Y/n): " -n 1 -r
  echo
  PRESERVE_DATA=true
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    PRESERVE_DATA=false
  fi
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "📦 Creating backup of qBittorrent configuration..."
    
    # Create backup directory
    BACKUP_DIR="$HOME/qbittorrent_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup qBittorrent configuration
    if [ -d "$HOME/.config/qBittorrent" ]; then
      cp -r "$HOME/.config/qBittorrent" "$BACKUP_DIR/"
      echo "✅ qBittorrent configuration backed up to: $BACKUP_DIR/qBittorrent"
    fi
    
    # Backup qBittorrent data
    if [ -d "$HOME/.local/share/data/qBittorrent" ]; then
      cp -r "$HOME/.local/share/data/qBittorrent" "$BACKUP_DIR/data"
      echo "✅ qBittorrent data backed up to: $BACKUP_DIR/data"
    fi
  fi
  
  # Remove qBittorrent
  echo "🗑️ Removing qBittorrent packages..."
  sudo apt remove -y qbittorrent
  sudo apt autoremove -y
  
  # Remove configuration if not preserving
  if [ "$PRESERVE_DATA" = false ]; then
    echo "🗑️ Removing qBittorrent configuration..."
    if [ -d "$HOME/.config/qBittorrent" ]; then
      rm -rf "$HOME/.config/qBittorrent"
    fi
    
    if [ -d "$HOME/.local/share/data/qBittorrent" ]; then
      rm -rf "$HOME/.local/share/data/qBittorrent"
    fi
  else
    echo "ℹ️ qBittorrent configuration preserved."
  fi
  
  echo "✅ qBittorrent has been uninstalled."
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "ℹ️ Your qBittorrent configuration was backed up to: $BACKUP_DIR"
    echo "ℹ️ To restore after reinstalling qBittorrent:"
    echo "   1. Install qBittorrent"
    echo "   2. Close qBittorrent if it's running"
    echo "   3. Copy the configuration: cp -r $BACKUP_DIR/qBittorrent ~/.config/"
    echo "   4. Copy the data (if backed up): cp -r $BACKUP_DIR/data ~/.local/share/data/"
  fi
else
  echo "✅ qBittorrent is not installed."
fi
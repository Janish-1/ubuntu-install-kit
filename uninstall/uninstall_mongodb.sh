#!/bin/bash
set -e

# Check if MongoDB is installed
if dpkg -l | grep -q "mongodb"; then
  echo "🗑️ Uninstalling MongoDB..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove MongoDB server and all databases. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Ask about data preservation
  read -p "Do you want to preserve your databases for future reinstallation? (Y/n): " -n 1 -r
  echo
  PRESERVE_DATA=true
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    PRESERVE_DATA=false
  fi
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "📦 Creating backup of all databases..."
    
    # Create backup directory
    BACKUP_DIR="$HOME/mongodb_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup all databases
    echo "📦 Backing up all databases..."
    mongodump --out="$BACKUP_DIR"
    
    echo "✅ Databases backed up to: $BACKUP_DIR"
  fi
  
  # Stop MongoDB service
  echo "🛑 Stopping MongoDB service..."
  sudo systemctl stop mongodb
  
  # Uninstall MongoDB
  echo "🗑️ Removing MongoDB packages..."
  sudo apt remove --purge -y mongodb mongodb-server mongodb-clients mongodb-server-core
  sudo apt autoremove -y
  
  # Check for MongoDB from MongoDB Inc repository
  if dpkg -l | grep -q "mongodb-org"; then
    echo "🗑️ Removing MongoDB packages from MongoDB Inc repository..."
    sudo apt remove --purge -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools
    sudo apt autoremove -y
    
    # Remove MongoDB Inc repository
    if [ -f /etc/apt/sources.list.d/mongodb*.list ]; then
      sudo rm /etc/apt/sources.list.d/mongodb*.list
    fi
  fi
  
  # Remove data directory if not preserving
  if [ "$PRESERVE_DATA" = false ]; then
    echo "🗑️ Removing MongoDB data directory..."
    sudo rm -rf /var/lib/mongodb
    sudo rm -rf /var/log/mongodb
    sudo rm -rf /etc/mongodb.conf
  else
    echo "ℹ️ MongoDB data directory preserved."
  fi
  
  echo "✅ MongoDB has been uninstalled."
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "ℹ️ Your databases were backed up to: $BACKUP_DIR"
    echo "ℹ️ To restore them after reinstalling MongoDB, use:"
    echo "   mongorestore $BACKUP_DIR"
  fi
else
  echo "✅ MongoDB is not installed."
fi
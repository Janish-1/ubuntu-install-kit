#!/bin/bash
set -e

# Check if Redis is installed
if dpkg -l | grep -q "redis-server"; then
  echo "🗑️ Uninstalling Redis..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Redis server and all data. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Ask about data preservation
  read -p "Do you want to preserve your Redis data for future reinstallation? (Y/n): " -n 1 -r
  echo
  PRESERVE_DATA=true
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    PRESERVE_DATA=false
  fi
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "📦 Creating backup of Redis data..."
    
    # Create backup directory
    BACKUP_DIR="$HOME/redis_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup Redis data
    if [ -f "/var/lib/redis/dump.rdb" ]; then
      sudo cp /var/lib/redis/dump.rdb "$BACKUP_DIR/dump.rdb"
      sudo chown $USER:$USER "$BACKUP_DIR/dump.rdb"
      echo "✅ Redis data backed up to: $BACKUP_DIR/dump.rdb"
    else
      echo "⚠️ No Redis dump file found to backup."
    fi
    
    # Backup Redis configuration
    if [ -f "/etc/redis/redis.conf" ]; then
      sudo cp /etc/redis/redis.conf "$BACKUP_DIR/redis.conf"
      sudo chown $USER:$USER "$BACKUP_DIR/redis.conf"
      echo "✅ Redis configuration backed up to: $BACKUP_DIR/redis.conf"
    fi
  fi
  
  # Stop Redis service
  echo "🛑 Stopping Redis service..."
  sudo systemctl stop redis-server
  
  # Uninstall Redis
  echo "🗑️ Removing Redis packages..."
  sudo apt remove --purge -y redis-server redis-tools
  sudo apt autoremove -y
  
  # Remove data directory if not preserving
  if [ "$PRESERVE_DATA" = false ]; then
    echo "🗑️ Removing Redis data directory..."
    sudo rm -rf /var/lib/redis
    sudo rm -rf /etc/redis
  else
    echo "ℹ️ Redis data directory preserved."
  fi
  
  echo "✅ Redis has been uninstalled."
  
  if [ "$PRESERVE_DATA" = true ] && [ -f "$BACKUP_DIR/dump.rdb" ]; then
    echo "ℹ️ Your Redis data was backed up to: $BACKUP_DIR/dump.rdb"
    echo "ℹ️ To restore after reinstalling Redis:"
    echo "   1. Stop Redis: sudo systemctl stop redis-server"
    echo "   2. Copy the dump file: sudo cp $BACKUP_DIR/dump.rdb /var/lib/redis/"
    echo "   3. Set permissions: sudo chown redis:redis /var/lib/redis/dump.rdb"
    echo "   4. Start Redis: sudo systemctl start redis-server"
  fi
else
  echo "✅ Redis is not installed."
fi
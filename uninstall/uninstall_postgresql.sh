#!/bin/bash
set -e

# Check if PostgreSQL is installed
if dpkg -l | grep -q "postgresql"; then
  echo "🗑️ Uninstalling PostgreSQL..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove PostgreSQL server and all databases. Continue? (y/N): " -n 1 -r
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
    BACKUP_DIR="$HOME/postgresql_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Get PostgreSQL version
    PG_VERSION=$(psql --version | grep -oP '\d+\.\d+' | head -1)
    
    # Backup all databases
    echo "📦 Backing up all databases..."
    sudo -u postgres pg_dumpall > "$BACKUP_DIR/all_databases.sql"
    
    echo "✅ Databases backed up to: $BACKUP_DIR/all_databases.sql"
  fi
  
  # Stop PostgreSQL service
  echo "🛑 Stopping PostgreSQL service..."
  sudo systemctl stop postgresql
  
  # Uninstall PostgreSQL
  echo "🗑️ Removing PostgreSQL packages..."
  sudo apt remove --purge -y postgresql postgresql-contrib postgresql-common libpq-dev
  sudo apt autoremove -y
  
  # Remove data directory if not preserving
  if [ "$PRESERVE_DATA" = false ]; then
    echo "🗑️ Removing PostgreSQL data directory..."
    sudo rm -rf /var/lib/postgresql
    sudo rm -rf /etc/postgresql
  else
    echo "ℹ️ PostgreSQL data directory preserved."
  fi
  
  # Remove PostgreSQL user if requested
  read -p "Do you want to remove the PostgreSQL system user? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if id "postgres" &>/dev/null; then
      sudo deluser postgres
      echo "✅ PostgreSQL user removed."
    fi
  fi
  
  echo "✅ PostgreSQL has been uninstalled."
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "ℹ️ Your databases were backed up to: $BACKUP_DIR/all_databases.sql"
    echo "ℹ️ To restore them after reinstalling PostgreSQL, use:"
    echo "   psql -f $BACKUP_DIR/all_databases.sql postgres"
  fi
else
  echo "✅ PostgreSQL is not installed."
fi
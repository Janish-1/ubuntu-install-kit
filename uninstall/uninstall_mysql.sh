#!/bin/bash
set -e

# Check if MySQL is installed
if dpkg -l | grep -q "mysql-server"; then
  echo "🗑️ Uninstalling MySQL..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove MySQL server and all databases. Continue? (y/N): " -n 1 -r
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
    BACKUP_DIR="$HOME/mysql_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Get list of databases
    DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")
    
    # Backup each database
    for db in $DATABASES; do
      echo "📦 Backing up database: $db"
      mysqldump --databases "$db" > "$BACKUP_DIR/$db.sql"
    done
    
    echo "✅ Databases backed up to: $BACKUP_DIR"
  fi
  
  # Stop MySQL service
  echo "🛑 Stopping MySQL service..."
  sudo service mysql stop
  
  # Uninstall MySQL
  echo "🗑️ Removing MySQL packages..."
  sudo apt remove --purge -y mysql-server mysql-client mysql-common
  sudo apt autoremove -y
  
  # Remove data directory if not preserving
  if [ "$PRESERVE_DATA" = false ]; then
    echo "🗑️ Removing MySQL data directory..."
    sudo rm -rf /var/lib/mysql
    sudo rm -rf /etc/mysql
  else
    echo "ℹ️ MySQL configuration and data directories preserved."
  fi
  
  # Remove user configuration
  if [ -f "$HOME/.my.cnf" ]; then
    rm "$HOME/.my.cnf"
  fi
  
  echo "✅ MySQL has been uninstalled."
  
  if [ "$PRESERVE_DATA" = true ]; then
    echo "ℹ️ Your databases were backed up to: $BACKUP_DIR"
    echo "ℹ️ To restore them after reinstalling MySQL, use:"
    echo "   mysql < $BACKUP_DIR/[database_name].sql"
  fi
else
  echo "✅ MySQL is not installed."
fi
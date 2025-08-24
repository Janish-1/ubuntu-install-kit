#!/bin/bash
set -e

# Check if SQLite is installed
if command -v sqlite3 &> /dev/null; then
  echo "🗑️ Uninstalling SQLite..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove SQLite. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove SQLite
  echo "🗑️ Removing SQLite packages..."
  sudo apt remove -y sqlite3 libsqlite3-dev
  sudo apt autoremove -y
  
  echo "✅ SQLite has been uninstalled."
  
  # Note about database files
  echo "ℹ️ Note: SQLite database files (.db, .sqlite, .sqlite3) in your projects are not removed."
  echo "ℹ️ These are regular files and will remain in your project directories."
else
  echo "✅ SQLite is not installed."
fi
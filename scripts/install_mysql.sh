#!/bin/bash
set -e

# ---- MySQL Server ----
if ! command -v mysql &> /dev/null; then
  echo "📦 Installing MySQL Server..."
  sudo apt update
  sudo apt install -y mysql-server
  
  echo "🔧 Starting MySQL service..."
  sudo systemctl start mysql
  sudo systemctl enable mysql
  
  echo "✅ MySQL Server installed and started."
  echo "💡 Run 'sudo mysql_secure_installation' to secure your MySQL installation."
else
  echo "✅ MySQL already installed."
fi
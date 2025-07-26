#!/bin/bash
set -e

# ---- PostgreSQL ----
if ! command -v psql &> /dev/null; then
  echo "📦 Installing PostgreSQL..."
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib
  
  echo "🔧 Starting PostgreSQL service..."
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
  
  echo "✅ PostgreSQL installed and started."
  echo "💡 Run 'sudo -u postgres psql' to access PostgreSQL as the postgres user."
else
  echo "✅ PostgreSQL already installed."
fi
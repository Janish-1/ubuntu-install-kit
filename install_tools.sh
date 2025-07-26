#!/bin/bash
set -e

echo "🔄 Starting installation of tools..."

# Execute individual installation scripts
echo "📦 Installing snapd..."
bash scripts/install_snapd.sh

echo "📦 Installing Git..."
bash scripts/install_git.sh

echo "📦 Installing gedit..."
bash scripts/install_gedit.sh

echo "📦 Installing blueman..."
bash scripts/install_blueman.sh

echo "📦 Installing VS Code..."
bash scripts/install_vscode.sh

echo "📦 Installing FreeFileSync..."
bash scripts/install_freefilesync.sh

echo "🧩 Creating FreeFileSync desktop shortcut..."
bash scripts/create_freefilesync_shortcut.sh

# Programming Languages
echo "🐍 Installing Python..."
bash scripts/install_python.sh

echo "🟢 Installing Node.js..."
bash scripts/install_nodejs.sh

echo "☕ Installing Java..."
bash scripts/install_java.sh

echo "🐹 Installing Go..."
bash scripts/install_go.sh

echo "🦀 Installing Rust..."
bash scripts/install_rust.sh

# Databases
echo "🐬 Installing MySQL..."
bash scripts/install_mysql.sh

echo "🐘 Installing PostgreSQL..."
bash scripts/install_postgresql.sh

echo "� Installing MongoDB..."
bash scripts/install_mongodb.sh

echo "🔴 Installing Redis..."
bash scripts/install_redis.sh

echo "📊 Installing SQLite..."
bash scripts/install_sqlite.sh

echo "�🎉 All tools, programming languages, and databases installed and up-to-date!"
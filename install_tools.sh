#!/bin/bash
set -e

echo "🔄 Starting installation of tools..."

# Execute individual installation scripts
echo "Installing Watchdog-inotify-tools"
bash scripts/install_inotifytools.sh

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

echo "📱 Installing Android Studio..."
bash scripts/install_android_studio.sh

echo "🤖 Setting up Android SDK Command-Line Tools..."
bash scripts/setup_android_sdk_path.sh

echo "� Installing FreeFileSync..."
bash scripts/install_freefilesync.sh

echo "🧩 Creating FreeFileSync desktop shortcut..."
bash scripts/create_freefilesync_shortcut.sh

# Programming Languages
echo "🐍 Installing Python..."
bash scripts/install_python.sh

echo "📓 Installing Jupyter Notebook..."
bash scripts/install_jupyter.sh

echo "🟢 Installing Node.js..."
bash scripts/install_nodejs.sh

echo "☕ Installing Java..."
bash scripts/install_java.sh

echo "🔧 Installing Gradle..."
bash scripts/install_gradle.sh

# Programs
echo " Installing XArchiver..."
bash scripts/install_xarchiver.sh

echo "Installing TeamViewer..."
bash scripts/install_teamviewer.sh

echo "Installing SMB"
bash scripts/install_smb.sh

echo "Installing/Filezilla"
bash scripts/install_filezilla.sh

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

# Torrent Client
echo "🌊 Installing qBittorrent..."
bash scripts/install_qbittorrent.sh

echo "🎉 All tools, programming languages, and databases installed and up-to-date!"
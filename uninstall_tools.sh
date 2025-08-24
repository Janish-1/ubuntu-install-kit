#!/bin/bash
set -e

echo "🔄 Starting uninstallation of tools..."

# Execute individual uninstallation scripts
echo "Uninstalling Watchdog-inotify-tools"
bash uninstall/uninstall_inotifytools.sh

echo "📦 Uninstalling Git..."
bash uninstall/uninstall_git.sh

echo "📦 Uninstalling gedit..."
bash uninstall/uninstall_gedit.sh

echo "📦 Uninstalling blueman..."
bash uninstall/uninstall_blueman.sh

echo "📦 Uninstalling VS Code..."
bash uninstall/uninstall_vscode.sh

echo "📱 Uninstalling Android Studio..."
bash uninstall/uninstall_android_studio.sh

echo "🤖 Uninstalling Android SDK Command-Line Tools..."
bash uninstall/uninstall_android_cmdline_tools.sh

echo "� Uninstalling FreeFileSync..."
bash uninstall/uninstall_freefilesync.sh

# Programming Languages
echo "🐍 Uninstalling Python..."
bash uninstall/uninstall_python.sh

echo "📓 Uninstalling Jupyter Notebook..."
bash uninstall/uninstall_jupyter.sh

echo "🟢 Uninstalling Node.js..."
bash uninstall/uninstall_nodejs.sh

echo "☕ Uninstalling Java..."
bash uninstall/uninstall_java.sh

echo "🔧 Uninstalling Gradle..."
bash uninstall/uninstall_gradle.sh

echo "Uninstalling Rust ..."
bash uninstall/uninstall_rust.sh

# Programs
echo " Uninstalling XArchiver..."
bash uninstall/uninstall_xarchiver.sh

echo "Uninstalling TeamViewer..."
bash uninstall/uninstall_teamviewer.sh

echo "Uninstalling SMB"
bash uninstall/uninstall_smb.sh

echo "Uninstalling Filezilla"
bash uninstall/uninstall_filezilla.sh

echo "Uninstalling FTP"
bash uninstall/uninstall_ftp.sh

echo "Uninstalling RSync"
bash uninstall/uninstall_rsync.sh

echo "Uninstalling Discord"
bash uninstall/uninstall_discord.sh

echo "Uninstalling Ngrok"
bash uninstall/uninstall_ngrok.sh

# Databases
echo "🐬 Uninstalling MySQL..."
bash uninstall/uninstall_mysql.sh

echo "🐘 Uninstalling PostgreSQL..."
bash uninstall/uninstall_postgresql.sh

echo "� Uninstalling MongoDB..."
bash uninstall/uninstall_mongodb.sh

echo "🔴 Uninstalling Redis..."
bash uninstall/uninstall_redis.sh

echo "📊 Uninstalling SQLite..."
bash uninstall/uninstall_sqlite.sh

# Torrent Client
echo "🌊 Uninstalling qBittorrent..."
bash uninstall/uninstall_qbittorrent.sh

# Critical components
echo "📊 Uninstalling system monitoring tools..."
bash uninstall/uninstall_system_monitor.sh

echo "💾 Removing automatic HDD mounting..."
bash uninstall/uninstall_hdd_mount.sh

# Snapd should be uninstalled last as many tools depend on it
echo "📦 Uninstalling snapd..."
bash uninstall/uninstall_snapd.sh

echo "🎉 All tools, programming languages, and databases have been uninstalled!"
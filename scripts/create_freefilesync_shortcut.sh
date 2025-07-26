#!/bin/bash
set -e

# Define the FreeFileSync desktop shortcut path
FFS_DESKTOP="$HOME/.local/share/applications/freefilesync.desktop"
FFS_DIR="/opt/FreeFileSync"

# Check if FreeFileSync is installed
if [ ! -d "$FFS_DIR" ]; then
  echo "❌ FreeFileSync is not installed. Please run the install script first."
  exit 1
fi

# Check if the desktop shortcut already exists
if [ ! -f "$FFS_DESKTOP" ]; then
  echo "🧩 Creating FreeFileSync desktop shortcut..."
  mkdir -p "$(dirname "$FFS_DESKTOP")"
  cat << EOF > "$FFS_DESKTOP"
[Desktop Entry]
Name=FreeFileSync
Exec=$FFS_DIR/FreeFileSync
Icon=$FFS_DIR/Resources/FreeFileSync.png
Type=Application
Categories=Utility;
Terminal=false
Comment=Folder comparison and synchronization
EOF
  chmod +x "$FFS_DESKTOP"
  echo "✅ FreeFileSync desktop shortcut created successfully."
else
  echo "✅ FreeFileSync shortcut already exists."
fi
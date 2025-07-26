#!/bin/bash
set -e

# Define the FreeFileSync desktop shortcut path
FFS_DESKTOP="$HOME/.local/share/applications/freefilesync.desktop"

# Check if the desktop shortcut already exists
if [ ! -f "$FFS_DESKTOP" ]; then
  echo "🧩 Creating FreeFileSync desktop shortcut..."
  mkdir -p "$(dirname "$FFS_DESKTOP")"
  cat << EOF > "$FFS_DESKTOP"
[Desktop Entry]
Name=FreeFileSync
Exec=/opt/FreeFileSync/FreeFileSync
Icon=/opt/FreeFileSync/Resources/FreeFileSync.png
Type=Application
Categories=Utility;
Terminal=false
EOF
  chmod +x "$FFS_DESKTOP"
else
  echo "✅ FreeFileSync shortcut already exists."
fi
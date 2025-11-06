#!/bin/bash
# =====================================================
# 🧭 MongoDB Compass Installer for Ubuntu (GUI version)
# =====================================================

set -e  # Exit on any error

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
  echo "⚠️  Please run this script with sudo:"
  echo "   sudo bash install_compass.sh"
  exit 1
fi

echo "🚀 Installing MongoDB Compass (GUI)..."

# Update package list
apt update -y

# Check if wget is installed
if ! command -v wget &> /dev/null; then
  echo "📦 Installing wget..."
  apt install wget -y
fi

# Download the latest MongoDB Compass .deb package
COMPASS_VERSION="1.43.3"
DEB_FILE="mongodb-compass_${COMPASS_VERSION}_amd64.deb"
DOWNLOAD_URL="https://downloads.mongodb.com/compass/${DEB_FILE}"

echo "⬇️  Downloading MongoDB Compass v${COMPASS_VERSION}..."
wget -q --show-progress "$DOWNLOAD_URL"

# Install the package
echo "📦 Installing MongoDB Compass..."
dpkg -i "$DEB_FILE" || apt-get install -f -y

# Cleanup
rm -f "$DEB_FILE"

echo "✅ MongoDB Compass installed successfully!"

# Optionally create a desktop shortcut if not auto-added
DESKTOP_ENTRY="/usr/share/applications/mongodb-compass.desktop"
if [ ! -f "$DESKTOP_ENTRY" ]; then
  echo "🧩 Creating desktop shortcut..."
  cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Version=1.0
Name=MongoDB Compass
Comment=MongoDB GUI Client
Exec=mongodb-compass
Icon=mongodb-compass
Terminal=false
Type=Application
Categories=Development;Database;
EOF
fi

echo "🎉 Installation complete!"
echo "💡 Launch it from the app menu or run: mongodb-compass &"

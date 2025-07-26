#!/bin/bash

# XAMPP Installation Script
# This script downloads and installs XAMPP for Linux

set -e

echo "🚀 XAMPP Installation Script"
echo "================================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please do not run this script as root"
  exit 1
fi

# Variables
XAMPP_DIR="/opt/lampp"
TEMP_DIR="$(pwd)/temp"

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Check if XAMPP is already installed
if [ -d "$XAMPP_DIR" ]; then
  echo "⚠️  XAMPP is already installed at $XAMPP_DIR"
  echo "📋 To reinstall, first uninstall the existing version:"
  echo "   sudo /opt/lampp/uninstall"
  echo "   sudo rm -rf /opt/lampp"
  exit 1
fi

echo "📦 Installing XAMPP..."
echo ""
echo "Available XAMPP versions:"
echo "1. XAMPP 8.0.30 (PHP 8.0.30)"
echo "2. XAMPP 8.1.25 (PHP 8.1.25)"
echo "3. XAMPP 8.2.12 (PHP 8.2.12) [Recommended]"
echo ""

# Get user choice
while true; do
  read -p "Choose version (1-3): " choice
  case $choice in
    1)
      VERSION="8.0.30"
      PHP_VERSION="8.0.30"
      break
      ;;
    2)
      VERSION="8.1.25"
      PHP_VERSION="8.1.25"
      break
      ;;
    3)
      VERSION="8.2.12"
      PHP_VERSION="8.2.12"
      break
      ;;
    *)
      echo "❌ Invalid choice. Please enter 1, 2, or 3."
      ;;
  esac
done

INSTALLER_NAME="xampp-linux-x64-${VERSION}-0-installer.run"
DOWNLOAD_URL="https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/${VERSION}/${INSTALLER_NAME}/download"

echo ""
echo "📦 Downloading XAMPP ${VERSION} (PHP ${PHP_VERSION})..."

# Download XAMPP installer
if command -v wget >/dev/null 2>&1; then
  if wget -O "$INSTALLER_NAME" "$DOWNLOAD_URL"; then
    echo "✅ Downloaded successfully with wget"
  else
    echo "❌ Download failed with wget"
    exit 1
  fi
elif command -v curl >/dev/null 2>&1; then
  if curl -L -o "$INSTALLER_NAME" "$DOWNLOAD_URL"; then
    echo "✅ Downloaded successfully with curl"
  else
    echo "❌ Download failed with curl"
    exit 1
  fi
else
  echo "❌ Neither wget nor curl is available"
  echo "📋 Please manually download XAMPP from:"
  echo "   https://www.apachefriends.org/download.html"
  echo "   Save the file as: $TEMP_DIR/$INSTALLER_NAME"
  echo "   Then run this script again."
  
  # Check if user has manually placed the file
  if [ ! -f "$INSTALLER_NAME" ] || [ ! -s "$INSTALLER_NAME" ]; then
    echo "❌ Installer not found or is empty. Exiting."
    exit 1
  else
    echo "✅ Found manually downloaded installer."
  fi
fi

# Verify the installer exists and has content
if [ -f "$INSTALLER_NAME" ] && [ -s "$INSTALLER_NAME" ]; then
  echo "📦 Running XAMPP installer..."
  chmod +x "$INSTALLER_NAME"
  
  echo ""
  echo "🔧 Starting interactive XAMPP installation..."
  echo "   - You'll be asked to accept the license"
  echo "   - Choose installation directory (default: /opt/lampp)"
  echo "   - Select components to install"
  echo ""
  
  # Run the installer (interactive)
  sudo "./$INSTALLER_NAME"
  
  # Verify installation
  if [ -d "$XAMPP_DIR" ] && [ -f "$XAMPP_DIR/xampp" ]; then
    echo ""
    echo "✅ XAMPP installed successfully!"
    echo ""
    echo "📋 XAMPP Information:"
    echo "   Installation directory: $XAMPP_DIR"
    echo "   PHP Version: $PHP_VERSION"
    echo "   Includes: Apache, MariaDB, PHP, phpMyAdmin, ProFTPD, and more"
    echo ""
    echo "🚀 Getting Started:"
    echo "   Start XAMPP:    sudo /opt/lampp/xampp start"
    echo "   Stop XAMPP:     sudo /opt/lampp/xampp stop"
    echo "   Restart XAMPP:  sudo /opt/lampp/xampp restart"
    echo "   Status:         sudo /opt/lampp/xampp status"
    echo ""
    echo "🌐 Access URLs:"
    echo "   Control Panel:  http://localhost/dashboard/"
    echo "   phpMyAdmin:     http://localhost/phpmyadmin/"
    echo "   Your projects:  Place in /opt/lampp/htdocs/"
    echo ""
    echo "🔧 Configuration:"
    echo "   Apache config:  /opt/lampp/etc/httpd.conf"
    echo "   PHP config:     /opt/lampp/etc/php.ini"
    echo "   MySQL config:   /opt/lampp/etc/my.cnf"
    echo ""
    echo "⚠️  Security Note:"
    echo "   Run security script: sudo /opt/lampp/xampp security"
    echo "   This will set passwords for MySQL and ProFTPD"
    
    # Create desktop shortcut if desktop environment is available
    if [ -n "$XDG_CURRENT_DESKTOP" ] && [ -d "$HOME/Desktop" ]; then
      echo ""
      echo "🖥️  Creating desktop shortcut..."
      cat > "$HOME/Desktop/XAMPP Control Panel.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=XAMPP Control Panel
Comment=Start and stop XAMPP services
Exec=gksudo /opt/lampp/manager-linux-x64.run
Icon=/opt/lampp/htdocs/favicon.ico
Terminal=false
Categories=Development;WebDevelopment;
EOF
      chmod +x "$HOME/Desktop/XAMPP Control Panel.desktop"
      echo "✅ Desktop shortcut created"
    fi
    
  else
    echo "❌ Installation failed - XAMPP not found in $XAMPP_DIR"
    exit 1
  fi
else
  echo "❌ Installer file not found or is empty"
  exit 1
fi

# Clean up temporary files
cd ..
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 XAMPP installation completed!"
echo "   You can now start developing with Apache, PHP, and MariaDB!"
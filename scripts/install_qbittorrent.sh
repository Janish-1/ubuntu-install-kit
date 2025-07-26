#!/bin/bash
set -e

# Check if qBittorrent is already installed
if command -v qbittorrent &> /dev/null; then
  echo "✅ qBittorrent already installed."
  qbittorrent --version
else
  echo "📦 Installing qBittorrent..."
  
  # Update package list
  sudo apt update
  
  # Try to install from official PPA first (most up-to-date version)
  echo "Adding qBittorrent official PPA..."
  if sudo add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable 2>/dev/null; then
    sudo apt update
    sudo apt install -y qbittorrent
    echo "✅ qBittorrent installed successfully from PPA."
  else
    # Fallback to default Ubuntu repository
    echo "PPA failed, installing from default Ubuntu repository..."
    sudo apt install -y qbittorrent
    echo "✅ qBittorrent installed successfully from Ubuntu repository."
  fi
  
  # Verify installation
  if command -v qbittorrent &> /dev/null; then
    echo "🎉 qBittorrent installation completed successfully!"
    qbittorrent --version
    echo "💡 You can start qBittorrent from the applications menu or run: qbittorrent"
  else
    echo "❌ qBittorrent installation failed."
    exit 1
  fi
fi
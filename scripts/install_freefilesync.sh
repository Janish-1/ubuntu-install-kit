#!/bin/bash
set -e

FFS_DIR="/opt/FreeFileSync"
TMP_DIR="/tmp/freefilesync-install"

if [ ! -d "$FFS_DIR" ]; then
  echo "📦 Downloading and installing FreeFileSync..."
  
  # Create temporary directory
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR"
  
  # Download and extract
  wget -O FreeFileSync.tar.gz https://freefilesync.org/download/FreeFileSync_14.3_Linux.tar.gz
  tar -xzf FreeFileSync.tar.gz
  
  # Move to final location
  sudo mv FreeFileSync "$FFS_DIR"
  
  # Clean up temporary files
  cd /
  rm -rf "$TMP_DIR"
  
  echo "✅ FreeFileSync installed successfully."
else
  echo "✅ FreeFileSync already installed."
fi
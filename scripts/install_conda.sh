#!/bin/bash
set -e

# ---- Miniconda (Conda Package Manager) ----
if ! command -v conda &> /dev/null; then
  echo "📦 Installing Miniconda..."
  
  # Download Miniconda installer (Python 3.10 version)
  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.2-0-Linux-x86_64.sh"
  INSTALLER_PATH="/tmp/miniconda_installer.sh"
  
  echo "⬇️  Downloading Miniconda installer..."
  wget -q "$MINICONDA_URL" -O "$INSTALLER_PATH"
  
  # Make installer executable and run it
  chmod +x "$INSTALLER_PATH"
  echo "🔧 Running Miniconda installer..."
  bash "$INSTALLER_PATH" -b -p "$HOME/miniconda3"
  
  # Initialize conda for bash
  echo "🔧 Initializing conda..."
  "$HOME/miniconda3/bin/conda" init bash
  
  # Clean up installer
  rm "$INSTALLER_PATH"
  
  echo "✅ Miniconda installed successfully!"
  echo "📝 Please restart your terminal or run 'source ~/.bashrc' to use conda commands."
else
  echo "✅ Conda already installed."
fi

# Update conda to latest version
if command -v conda &> /dev/null; then
  echo "🔄 Updating conda to latest version..."
  conda update -n base -c defaults conda -y
fi
#!/bin/bash
set -e

# ---- Go ----
if ! command -v go &> /dev/null; then
  echo "📦 Installing Go..."
  
  # Create temporary directory
  TMP_DIR="/tmp/go-install"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR"
  
  # Download and install Go
  GO_VERSION="1.21.5"
  wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
  
  # Clean up temporary files
  cd /
  rm -rf "$TMP_DIR"
  
  # Add Go to PATH if not already there
  if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo "📝 Added Go to PATH in ~/.bashrc"
  fi
  
  echo "✅ Go installed. Please restart your terminal or run 'source ~/.bashrc'"
else
  echo "✅ Go already installed."
fi
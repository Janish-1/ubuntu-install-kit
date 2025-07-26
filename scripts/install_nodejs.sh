#!/bin/bash
set -e

# ---- Node.js and npm ----
if ! command -v node &> /dev/null; then
  echo "📦 Installing Node.js..."
  # Install Node.js LTS via NodeSource repository
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "✅ Node.js already installed."
fi

# Verify npm is installed
if ! command -v npm &> /dev/null; then
  echo "📦 Installing npm..."
  sudo apt install -y npm
else
  echo "✅ npm already installed."
fi
#!/bin/bash
set -e

echo "🔄 Updating package list..."
sudo apt update

# ---- Install snapd if missing ----
if ! command -v snap &> /dev/null; then
  echo "📦 Installing snapd (Snap package manager)..."
  sudo apt install -y snapd
  echo "🔁 Enabling Snap socket..."
  sudo systemctl enable --now snapd.socket
  echo "🔗 Linking /snap if needed..."
  sudo ln -sf /var/lib/snapd/snap /snap
else
  echo "✅ snapd already installed."
fi
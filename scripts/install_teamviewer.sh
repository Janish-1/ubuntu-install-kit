#!/bin/bash
set -e

# ---- TeamViewer ----
if ! command -v teamviewer &> /dev/null; then
  echo "📦 Installing TeamViewer..."
  wget -qO /tmp/teamviewer.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
  sudo apt install -y /tmp/teamviewer.deb
  rm /tmp/teamviewer.deb
else
  echo "✅ TeamViewer already installed."
fi

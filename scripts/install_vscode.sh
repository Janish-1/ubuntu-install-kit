#!/bin/bash
set -e

# ---- VS Code ----
if ! command -v code &> /dev/null; then
  echo "📦 Installing VS Code (via Snap)..."
  sudo snap install code --classic
else
  echo "✅ VS Code already installed."
fi
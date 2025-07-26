#!/bin/bash
set -e

if ! dpkg -l | grep -q blueman; then
  echo "📦 Installing blueman..."
  sudo apt install -y blueman
else
  echo "✅ blueman already installed."
fi
#!/bin/bash
set -e

if ! command -v discord &> /dev/null; then
  echo "📦 Installing Discord..."
  sudo apt update
  sudo apt install -y wget gpg

  # Download and install Discord .deb
  wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
  sudo apt install -y /tmp/discord.deb
  rm /tmp/discord.deb

  echo "✅ Discord installed."
else
  echo "✅ Discord already installed."
fi

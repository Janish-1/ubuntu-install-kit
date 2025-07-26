#!/bin/bash
set -e

# ---- Python 3 and pip ----
if ! command -v python3 &> /dev/null; then
  echo "📦 Installing Python 3..."
  sudo apt update
  sudo apt install -y python3 python3-pip python3-venv
else
  echo "✅ Python 3 already installed."
fi

# Install pip if not present
if ! command -v pip3 &> /dev/null; then
  echo "📦 Installing pip3..."
  sudo apt install -y python3-pip
else
  echo "✅ pip3 already installed."
fi
#!/bin/bash
set -e

# ---- Redis ----
if ! command -v redis-server &> /dev/null; then
  echo "📦 Installing Redis..."
  sudo apt update
  sudo apt install -y redis-server
  
  echo "🔧 Starting Redis service..."
  sudo systemctl start redis-server
  sudo systemctl enable redis-server
  
  echo "✅ Redis installed and started."
else
  echo "✅ Redis already installed."
fi
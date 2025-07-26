#!/bin/bash
set -e

# ---- MongoDB ----
if ! command -v mongod &> /dev/null; then
  echo "📦 Installing MongoDB..."
  
  # Ensure curl is installed
  if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    sudo apt update
    sudo apt install -y curl
  fi
  
  # Import MongoDB public GPG key
  curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
  
  # Add MongoDB repository
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
  
  # Update package list and install MongoDB
  sudo apt update
  sudo apt install -y mongodb-org
  
  echo "🔧 Starting MongoDB service..."
  sudo systemctl start mongod
  sudo systemctl enable mongod
  
  echo "✅ MongoDB installed and started."
else
  echo "✅ MongoDB already installed."
fi
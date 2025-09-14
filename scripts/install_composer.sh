#!/bin/bash
set -e

echo "📦 Installing Composer..."

# Check if Composer is already installed
if command -v composer &> /dev/null
then
    echo "✅ Composer is already installed: $(composer -V)"
    exit 0
fi

# Install Composer from apt
sudo apt update
sudo apt install composer -y

# Verify installation
composer -V

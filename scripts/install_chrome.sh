#!/bin/bash
set -e

echo "🌐 Installing Google Chrome..."

# Check if Chrome is already installed
if command -v google-chrome &> /dev/null
then
    echo "✅ Google Chrome is already installed: $(google-chrome --version)"
    exit 0
fi

# Update package list and install dependencies
sudo apt update
sudo apt install -y wget gnupg

# Download the latest Google Chrome .deb package
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb

# Install the package
sudo apt install -y /tmp/google-chrome.deb

# Clean up
rm /tmp/google-chrome.deb

# Verify installation
google-chrome --version

echo "🎉 Google Chrome installation completed successfully!"

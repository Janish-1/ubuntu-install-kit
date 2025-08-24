#!/bin/bash
set -e

# Check if ngrok is already installed
if command -v ngrok &>/dev/null; then
    echo "✅ ngrok is already installed."
    ngrok version
    exit 0
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    NGROK_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    NGROK_ARCH="arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

# Install unzip if missing
if ! dpkg -l | grep -q unzip; then
    echo "📦 Installing unzip..."
    sudo apt update && sudo apt install -y unzip
fi

# Download ngrok
echo "📥 Downloading ngrok..."
wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-$NGROK_ARCH.zip -O ngrok.zip

# Unzip and install
echo "📦 Installing ngrok..."
unzip -o ngrok.zip
sudo mv ngrok /usr/local/bin/

# Clean up
rm ngrok.zip

# Verify installation
if command -v ngrok &>/dev/null; then
    echo "✅ ngrok installed successfully!"
    ngrok version
else
    echo "❌ ngrok installation failed."
    exit 1
fi

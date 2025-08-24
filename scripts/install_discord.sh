#!/bin/bash
set -e

DISCORD_DEB_URL="https://discord.com/api/download?platform=linux&format=deb"
TEMP_DEB="/tmp/discord.deb"

# Function to install or update Discord
install_discord() {
    echo "📦 Downloading latest Discord..."
    wget -O "$TEMP_DEB" "$DISCORD_DEB_URL"
    sudo apt install -y "$TEMP_DEB"
    rm "$TEMP_DEB"
}

# Check if Discord is installed
if ! command -v discord &> /dev/null; then
    echo "📦 Installing Discord..."
    sudo apt update
    sudo apt install -y wget gpg
    install_discord
    echo "✅ Discord installed."
else
    echo "🔍 Checking for Discord updates..."
    INSTALLED_VERSION=$(dpkg -s discord 2>/dev/null | grep '^Version:' | awk '{print $2}')
    wget -q --server-response --spider "$DISCORD_DEB_URL" 2>&1 \
        | grep -i 'content-disposition' \
        | grep -oP 'discord-[0-9]+\.[0-9]+\.[0-9]+' \
        | head -n 1 > /tmp/latest_version.txt

    LATEST_VERSION=$(cat /tmp/latest_version.txt | sed 's/discord-//')

    if [[ "$LATEST_VERSION" != "" && "$LATEST_VERSION" != "$INSTALLED_VERSION" ]]; then
        echo "⬆️  New version available: $LATEST_VERSION (installed: $INSTALLED_VERSION)"
        install_discord
        echo "✅ Discord updated."
    else
        echo "✅ Discord is up to date (version $INSTALLED_VERSION)."
    fi
fi

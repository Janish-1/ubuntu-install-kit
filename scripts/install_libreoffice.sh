#!/bin/bash

echo "📦 Checking LibreOffice installation..."

if command -v libreoffice &> /dev/null
then
    echo "✅ LibreOffice is already installed."
else
    echo "🚀 Installing LibreOffice..."
    sudo apt update
    sudo apt install -y libreoffice
    echo "✅ LibreOffice installed successfully."
fi

echo "🔤 Installing extra fonts..."
sudo apt install -y fonts-dejavu fonts-liberation fonts-noto fonts-freefont-ttf ttf-mscorefonts-installer fonts-roboto

echo "✅ Fonts installed successfully."

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

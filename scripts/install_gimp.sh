#!/bin/bash
set -e

echo "🎨 Installing GIMP..."

# Check if GIMP is already installed
if command -v gimp &> /dev/null
then
    echo "✅ GIMP is already installed: $(gimp --version)"
    exit 0
fi

# Install GIMP from apt
sudo apt update
sudo apt install gimp -y

# Verify installation
gimp --version

echo "🎉 GIMP installation complete!"

#!/bin/bash
set -e

# ---- Check if rsync is installed ----
if ! command -v rsync &>/dev/null; then
    echo "📦 Installing rsync..."
    sudo apt update
    sudo apt install -y rsync
else
    echo "✅ rsync is already installed."
fi

# ---- Show version ----
rsync --version | head -n 1

echo "✅ rsync is ready to use."

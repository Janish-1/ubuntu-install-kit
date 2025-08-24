#!/bin/bash
set -e

# ----- Rust -----
if ! command -v rustc &> /dev/null; then
    echo "📦 Installing Rust..."
    sudo snap install rustup --classic
    rustup install stable
    rustup default stable
else
    echo "✅ Rust is already installed."
fi

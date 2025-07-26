#!/bin/bash
set -e

# ---- Rust ----
if ! command -v rustc &> /dev/null; then
  echo "📦 Installing Rust..."
  # Install Rust via rustup
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source ~/.cargo/env
  echo "✅ Rust installed. Please restart your terminal or run 'source ~/.cargo/env'"
else
  echo "✅ Rust already installed."
fi
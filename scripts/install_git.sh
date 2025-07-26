#!/bin/bash
set -e

# ---- Git ----
if ! command -v git &> /dev/null; then
  echo "📦 Installing Git..."
  sudo apt update
  sudo apt install -y git
else
  echo "✅ Git already installed."
fi
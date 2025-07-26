#!/bin/bash
set -e

# ---- SQLite ----
if ! command -v sqlite3 &> /dev/null; then
  echo "📦 Installing SQLite..."
  sudo apt update
  sudo apt install -y sqlite3
  echo "✅ SQLite installed."
else
  echo "✅ SQLite already installed."
fi
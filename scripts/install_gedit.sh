#!/bin/bash
set -e

# ---- gedit ----
if ! command -v gedit &> /dev/null; then
  echo "📦 Installing gedit..."
  sudo apt install -y gedit
else
  echo "✅ gedit already installed."
fi
#!/bin/bash
set -e

# ---- Android Studio ----
if ! command -v android-studio &> /dev/null; then
  echo "📦 Installing Android Studio (via Snap)..."
  sudo snap install android-studio --classic
else
  echo "✅ Android Studio already installed."
fi

# Check if Android SDK tools are available
if [ ! -d "$HOME/Android/Sdk" ] && [ ! -d "$HOME/snap/android-studio/current/Android/Sdk" ]; then
  echo "📱 Android Studio installed. Please run it to complete SDK setup."
  echo "   The first launch will guide you through SDK installation."
else
  echo "✅ Android SDK appears to be configured."
fi
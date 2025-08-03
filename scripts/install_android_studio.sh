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
  echo ""
  echo "⚠️ During SDK setup, make sure to install these components:"
  echo "   • Android SDK Command-Line Tools (latest)"
  echo "   • Android SDK Platform-Tools"
  echo "   • Android Emulator"
  echo "   • Android SDK Build-Tools"
  echo ""
  echo "💡 After installation, run 'scripts/setup_android_sdk_path.sh' to"
  echo "   configure the command-line tools for global use."
else
  echo "✅ Android SDK appears to be configured."
  echo "💡 Run 'scripts/setup_android_sdk_path.sh' to ensure command-line"
  echo "   tools like adb, sdkmanager, and avdmanager are available globally."
fi
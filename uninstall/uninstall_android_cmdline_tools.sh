#!/bin/bash
set -e

echo "🗑️ Uninstalling Android SDK Command-Line Tools..."

# Ask for confirmation
read -p "⚠️ This will remove Android SDK Command-Line Tools. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Uninstallation aborted."
  exit 0
fi

# Check for Android SDK directory
ANDROID_SDK_DIR="$HOME/Android/Sdk"
if [ -d "$ANDROID_SDK_DIR" ]; then
  echo "🔍 Found Android SDK at: $ANDROID_SDK_DIR"
  
  # Ask if user wants to remove specific components or everything
  echo "Select what to remove:"
  echo "1) Remove only Command-Line Tools"
  echo "2) Remove Platform Tools (adb, fastboot)"
  echo "3) Remove Build Tools"
  echo "4) Remove Emulator"
  echo "5) Remove everything (entire Android SDK)"
  read -p "Enter your choice (1-5): " choice
  
  case $choice in
    1)
      echo "🗑️ Removing Command-Line Tools..."
      rm -rf "$ANDROID_SDK_DIR/cmdline-tools"
      ;;
    2)
      echo "🗑️ Removing Platform Tools..."
      rm -rf "$ANDROID_SDK_DIR/platform-tools"
      ;;
    3)
      echo "🗑️ Removing Build Tools..."
      rm -rf "$ANDROID_SDK_DIR/build-tools"
      ;;
    4)
      echo "🗑️ Removing Emulator..."
      rm -rf "$ANDROID_SDK_DIR/emulator"
      ;;
    5)
      echo "🗑️ Removing entire Android SDK..."
      rm -rf "$ANDROID_SDK_DIR"
      
      # Also remove .android directory
      if [ -d "$HOME/.android" ]; then
        rm -rf "$HOME/.android"
      fi
      ;;
    *)
      echo "❌ Invalid choice. Uninstallation aborted."
      exit 1
      ;;
  esac
  
  # Remove Android SDK path from environment
  for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$file" ]; then
      sed -i '/ANDROID_HOME/d' "$file"
      sed -i '/ANDROID_SDK_ROOT/d' "$file"
      sed -i '/android-sdk/d' "$file"
    fi
  done
  
  echo "✅ Android SDK components have been uninstalled."
  echo "ℹ️ You may need to restart your terminal or run 'source ~/.bashrc' for PATH changes to take effect."
else
  echo "❌ Android SDK directory not found at: $ANDROID_SDK_DIR"
  
  # Check alternative locations
  if [ -d "/opt/android-sdk" ]; then
    echo "🔍 Found Android SDK at: /opt/android-sdk"
    
    # Ask for confirmation
    read -p "Do you want to remove this Android SDK? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo rm -rf "/opt/android-sdk"
      echo "✅ Android SDK has been removed."
    fi
  else
    echo "✅ Android SDK is not installed."
  fi
fi
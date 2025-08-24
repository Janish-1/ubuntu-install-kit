#!/bin/bash
set -e

# Check if Android Studio is installed via snap
if snap list | grep -q "android-studio"; then
  echo "🗑️ Uninstalling Android Studio..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Android Studio. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Remove Android Studio
  sudo snap remove android-studio
  
  # Ask about Android SDK
  read -p "Do you want to remove Android SDK as well? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/Android" ]; then
      echo "🗑️ Removing Android SDK directory..."
      rm -rf "$HOME/Android"
    fi
    
    if [ -d "$HOME/.android" ]; then
      echo "🗑️ Removing Android configuration directory..."
      rm -rf "$HOME/.android"
    fi
    
    # Remove Android SDK path from environment
    for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [ -f "$file" ]; then
        sed -i '/ANDROID_HOME/d' "$file"
        sed -i '/ANDROID_SDK_ROOT/d' "$file"
        sed -i '/android-sdk/d' "$file"
      fi
    done
    
    echo "✅ Android SDK has been removed."
  fi
  
  echo "✅ Android Studio has been uninstalled."
else
  # Check if Android Studio is installed via direct download
  if [ -d "/opt/android-studio" ] || [ -d "$HOME/android-studio" ]; then
    echo "🗑️ Uninstalling Android Studio (direct installation)..."
    
    # Ask for confirmation
    read -p "⚠️ This will remove Android Studio. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "❌ Uninstallation aborted."
      exit 0
    fi
    
    # Remove Android Studio directories
    if [ -d "/opt/android-studio" ]; then
      sudo rm -rf "/opt/android-studio"
    fi
    
    if [ -d "$HOME/android-studio" ]; then
      rm -rf "$HOME/android-studio"
    fi
    
    # Remove desktop entry
    if [ -f "/usr/share/applications/android-studio.desktop" ]; then
      sudo rm "/usr/share/applications/android-studio.desktop"
    fi
    
    if [ -f "$HOME/.local/share/applications/android-studio.desktop" ]; then
      rm "$HOME/.local/share/applications/android-studio.desktop"
    fi
    
    # Ask about Android SDK
    read -p "Do you want to remove Android SDK as well? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if [ -d "$HOME/Android" ]; then
        echo "🗑️ Removing Android SDK directory..."
        rm -rf "$HOME/Android"
      fi
      
      if [ -d "$HOME/.android" ]; then
        echo "🗑️ Removing Android configuration directory..."
        rm -rf "$HOME/.android"
      fi
      
      # Remove Android SDK path from environment
      for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$file" ]; then
          sed -i '/ANDROID_HOME/d' "$file"
          sed -i '/ANDROID_SDK_ROOT/d' "$file"
          sed -i '/android-sdk/d' "$file"
        fi
      done
      
      echo "✅ Android SDK has been removed."
    fi
    
    echo "✅ Android Studio has been uninstalled."
  else
    echo "✅ Android Studio is not installed."
  fi
fi
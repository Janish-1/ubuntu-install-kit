#!/bin/bash
set -e

echo "🤖 Setting up Android SDK Command-Line Tools globally..."

# Determine Android SDK location
# First check if ANDROID_HOME is already set
if [ -z "$ANDROID_HOME" ]; then
  # Check common locations
  POSSIBLE_LOCATIONS=(
    "$HOME/Android/Sdk"
    "$HOME/Library/Android/sdk"
    "$HOME/AppData/Local/Android/Sdk"
  )
  
  for location in "${POSSIBLE_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
      ANDROID_HOME="$location"
      break
    fi
  done
  
  # If still not found, ask the user
  if [ -z "$ANDROID_HOME" ]; then
    echo "⚠️ Android SDK location not found automatically."
    read -p "Please enter your Android SDK path: " ANDROID_HOME
    
    if [ ! -d "$ANDROID_HOME" ]; then
      echo "❌ The specified directory does not exist. Aborting."
      exit 1
    fi
  fi
fi

echo "📂 Using Android SDK at: $ANDROID_HOME"

# Verify key directories exist
CMDLINE_TOOLS="$ANDROID_HOME/cmdline-tools/latest/bin"
PLATFORM_TOOLS="$ANDROID_HOME/platform-tools"
EMULATOR="$ANDROID_HOME/emulator"
BUILD_TOOLS_DIR="$ANDROID_HOME/build-tools"

# Check if cmdline-tools exists
if [ ! -d "$CMDLINE_TOOLS" ]; then
  echo "⚠️ Command-line tools not found at $CMDLINE_TOOLS"
  echo "You may need to install them via Android Studio or sdkmanager"
  
  # Check if we have an older version of cmdline-tools
  if [ -d "$ANDROID_HOME/cmdline-tools" ]; then
    LATEST_VERSION=$(find "$ANDROID_HOME/cmdline-tools" -maxdepth 1 -type d | grep -v "^$ANDROID_HOME/cmdline-tools$" | sort -r | head -1)
    if [ -n "$LATEST_VERSION" ]; then
      CMDLINE_TOOLS="$LATEST_VERSION/bin"
      echo "🔍 Found command-line tools at: $CMDLINE_TOOLS"
    fi
  fi
fi

# Find latest build-tools version
if [ -d "$BUILD_TOOLS_DIR" ]; then
  LATEST_BUILD_TOOLS=$(find "$BUILD_TOOLS_DIR" -maxdepth 1 -type d | sort -r | head -1)
  if [ -n "$LATEST_BUILD_TOOLS" ]; then
    BUILD_TOOLS="$LATEST_BUILD_TOOLS"
    echo "🔍 Found latest build-tools at: $BUILD_TOOLS"
  fi
fi

# Create or update .android_sdk_paths file in user's home directory
PATHS_FILE="$HOME/.android_sdk_paths"
cat > "$PATHS_FILE" << EOF
# Android SDK Paths
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Add Android SDK tools to PATH
if [ -d "\$ANDROID_HOME/cmdline-tools/latest/bin" ]; then
  export PATH="\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin"
elif [ -d "\$ANDROID_HOME/tools/bin" ]; then
  export PATH="\$PATH:\$ANDROID_HOME/tools/bin"
fi

if [ -d "\$ANDROID_HOME/platform-tools" ]; then
  export PATH="\$PATH:\$ANDROID_HOME/platform-tools"
fi

if [ -d "\$ANDROID_HOME/emulator" ]; then
  export PATH="\$PATH:\$ANDROID_HOME/emulator"
fi

# Add latest build-tools to PATH
if [ -d "$BUILD_TOOLS" ]; then
  export PATH="\$PATH:$BUILD_TOOLS"
fi
EOF

# Add source command to shell config files if not already present
for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$SHELL_RC" ]; then
    if ! grep -q "source $PATHS_FILE" "$SHELL_RC"; then
      echo "" >> "$SHELL_RC"
      echo "# Android SDK paths" >> "$SHELL_RC"
      echo "if [ -f \"$PATHS_FILE\" ]; then" >> "$SHELL_RC"
      echo "  source \"$PATHS_FILE\"" >> "$SHELL_RC"
      echo "fi" >> "$SHELL_RC"
      echo "✅ Added Android SDK paths to $SHELL_RC"
    else
      echo "ℹ️ Android SDK paths already configured in $SHELL_RC"
    fi
  fi
done

# Source the file in current session
source "$PATHS_FILE"

echo ""
echo "🎉 Android SDK Command-Line Tools have been set up globally!"
echo ""
echo "✅ The following tools are now available from any terminal:"
echo "  • sdkmanager - Manage Android SDK packages"
echo "  • avdmanager - Create and manage Android Virtual Devices"
echo "  • adb        - Android Debug Bridge for device communication"
echo "  • emulator   - Run Android emulators"
echo "  • aapt       - Android Asset Packaging Tool (in build-tools)"
echo ""
echo "📋 To verify installation, open a new terminal and run:"
echo "  command -v sdkmanager"
echo "  command -v adb"
echo "  command -v emulator"
echo ""
echo "💡 You may need to restart your terminal or run 'source ~/.bashrc'"
echo "   (or 'source ~/.zshrc' if using zsh) for changes to take effect."
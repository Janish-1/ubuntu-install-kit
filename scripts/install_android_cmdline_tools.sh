#!/bin/bash
set -e

echo "🔍 Locating Android SDK from Android Studio..."

# Try common Android Studio SDK locations
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

# If not found, fail
if [ -z "$ANDROID_HOME" ]; then
  echo "❌ Android SDK not found. Please open Android Studio and install SDK tools first."
  exit 1
fi

echo "📂 Using Android SDK at: $ANDROID_HOME"

# Temporarily set environment variables
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

echo "🔧 Ensuring essential SDK components are installed..."

yes | sdkmanager --sdk_root="$ANDROID_HOME" \
  "platform-tools" \
  "emulator" \
  "build-tools;34.0.0" \
  "cmdline-tools;latest"

echo ""
echo "✅ SDK components ready:"
echo "  • platform-tools (adb, etc.)"
echo "  • emulator"
echo "  • build-tools 34.0.0"
echo "  • cmdline-tools latest"

# Setup PATH permanently
PROFILE_FILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
  PROFILE_FILE="$HOME/.zshrc"
fi

echo "🔧 Adding Android SDK tools to PATH in $PROFILE_FILE..."

if ! grep -q 'ANDROID_HOME' "$PROFILE_FILE"; then
  cat <<EOF >> "$PROFILE_FILE"

# Android SDK environment variables
export ANDROID_HOME=$ANDROID_HOME
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=\$PATH:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$ANDROID_HOME/cmdline-tools/latest/bin
EOF
  echo "✅ PATH updated. Please restart your terminal or run: source $PROFILE_FILE"
else
  echo "🔁 PATH already includes Android SDK — skipping."
fi

echo ""
echo "💡 You can now run sdkmanager, avdmanager, adb, emulator etc."
echo "💡 Example: sdkmanager --list"

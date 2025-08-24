#!/bin/bash
set -e

# Check if ngrok is installed
if command -v ngrok &> /dev/null; then
  echo "🗑️ Uninstalling ngrok..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove ngrok. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Get ngrok location
  NGROK_PATH=$(which ngrok)
  
  # Remove ngrok binary
  if [ -n "$NGROK_PATH" ]; then
    sudo rm "$NGROK_PATH"
  fi
  
  # Remove ngrok configuration
  if [ -d "$HOME/.ngrok2" ]; then
    read -p "Do you want to remove ngrok configuration (including auth token)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$HOME/.ngrok2"
      echo "✅ ngrok configuration removed."
    fi
  fi
  
  echo "✅ ngrok has been uninstalled."
else
  echo "✅ ngrok is not installed."
fi
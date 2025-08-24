#!/bin/bash
set -e

# Check if Gradle is installed
if command -v gradle &> /dev/null; then
  echo "🗑️ Uninstalling Gradle..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Gradle. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Get Gradle version info
  gradle_version=$(gradle --version | grep "Gradle" | head -1)
  echo "Current Gradle version: $gradle_version"
  
  # Check if installed via apt
  if dpkg -l | grep -q "gradle"; then
    echo "🗑️ Removing Gradle packages via apt..."
    sudo apt remove -y gradle
    sudo apt autoremove -y
  fi
  
  # Check if installed via SDKMAN
  if [ -d "$HOME/.sdkman/candidates/gradle" ]; then
    echo "🗑️ Removing Gradle via SDKMAN..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk uninstall gradle
  fi
  
  # Check if installed manually
  if [ -d "/opt/gradle" ]; then
    echo "🗑️ Removing manually installed Gradle..."
    sudo rm -rf /opt/gradle
    
    # Remove from PATH
    for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [ -f "$file" ]; then
        sed -i '/gradle/d' "$file"
      fi
    done
  fi
  
  # Remove Gradle home directory
  if [ -d "$HOME/.gradle" ]; then
    read -p "Do you want to remove Gradle cache and configuration files? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$HOME/.gradle"
      echo "✅ Gradle cache and configuration removed."
    fi
  fi
  
  echo "✅ Gradle has been uninstalled."
else
  echo "✅ Gradle is not installed."
fi
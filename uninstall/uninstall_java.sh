#!/bin/bash
set -e

# Check if Java is installed
if command -v java &> /dev/null; then
  echo "🗑️ Uninstalling Java..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Java and related packages. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Get Java version info
  java_version=$(java -version 2>&1 | head -1)
  echo "Current Java version: $java_version"
  
  # Remove OpenJDK packages
  if dpkg -l | grep -q "openjdk"; then
    echo "🗑️ Removing OpenJDK packages..."
    sudo apt remove -y openjdk-* 
  fi
  
  # Remove Oracle Java if installed
  if [ -d "/usr/lib/jvm/oracle-java" ] || [ -d "/opt/java" ]; then
    echo "🗑️ Removing Oracle Java..."
    sudo rm -rf /usr/lib/jvm/oracle-java* /opt/java
    
    # Remove from alternatives
    sudo update-alternatives --remove-all java
    sudo update-alternatives --remove-all javac
    sudo update-alternatives --remove-all javaws
  fi
  
  # Remove Java environment variables
  for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$file" ]; then
      sed -i '/JAVA_HOME/d' "$file"
      sed -i '/JDK_HOME/d' "$file"
    fi
  done
  
  # Clean up
  sudo apt autoremove -y
  
  echo "✅ Java has been uninstalled."
else
  echo "✅ Java is not installed."
fi
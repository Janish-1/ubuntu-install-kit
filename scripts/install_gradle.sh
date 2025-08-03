#!/bin/bash
set -e

# ---- Gradle ----
if ! command -v gradle &> /dev/null; then
  echo "📦 Installing Gradle..."
  
  # Update package list
  sudo apt update
  
  # Install required dependencies
  sudo apt install -y wget unzip
  
  # Download and install Gradle
  GRADLE_VERSION="8.5"
  cd /tmp
  wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
  sudo unzip -d /opt/gradle gradle-${GRADLE_VERSION}-bin.zip
  
  # Create symbolic link
  sudo ln -sf /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
  
  # Clean up
  rm gradle-${GRADLE_VERSION}-bin.zip
  
  echo "✅ Gradle ${GRADLE_VERSION} installed successfully."
else
  echo "✅ Gradle already installed."
fi

# Verify installation
if command -v gradle &> /dev/null; then
  echo "🔍 Gradle version: $(gradle --version | head -n 1)"
fi
#!/bin/bash
set -e

echo "🔍 Checking for Java (OpenJDK 17)..."

# Check if Java 17 is installed
if java -version 2>&1 | grep -q '17'; then
  echo "✅ Java 17 is already installed."
else
  echo "📦 Installing OpenJDK 17..."
  sudo apt update
  sudo apt install -y openjdk-17-jdk
fi

# Check if javac is available and version 17
if javac -version 2>&1 | grep -q '17'; then
  echo "✅ Java compiler (javac) 17 is already installed."
else
  echo "📦 Installing Java compiler (OpenJDK 17)..."
  sudo apt install -y openjdk-17-jdk
fi

# Optional: Set JAVA_HOME for current session
JAVA_PATH=$(update-alternatives --list java | grep 'java-17' | head -n1 | sed 's|/bin/java||')
if [ -n "$JAVA_PATH" ]; then
  export JAVA_HOME="$JAVA_PATH"
  export PATH="$JAVA_HOME/bin:$PATH"
  echo "📌 JAVA_HOME set to: $JAVA_HOME"
else
  echo "⚠️ Could not automatically detect JAVA_HOME. You may need to set it manually."
fi

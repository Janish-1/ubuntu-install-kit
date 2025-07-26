#!/bin/bash
set -e

# ---- Java (OpenJDK) ----
if ! command -v java &> /dev/null; then
  echo "📦 Installing Java (OpenJDK 11)..."
  sudo apt update
  sudo apt install -y openjdk-11-jdk
else
  echo "✅ Java already installed."
fi

# Also install javac if not present
if ! command -v javac &> /dev/null; then
  echo "📦 Installing Java compiler..."
  sudo apt install -y openjdk-11-jdk
else
  echo "✅ Java compiler already installed."
fi
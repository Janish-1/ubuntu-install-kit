#!/bin/bash
set -e

# Check if Rust is installed
if command -v rustc &> /dev/null || [ -d "$HOME/.cargo" ]; then
  echo "🗑️ Uninstalling Rust..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Rust, Cargo, and all installed Rust packages. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Check if rustup is available
  if command -v rustup &> /dev/null; then
    echo "🗑️ Uninstalling Rust using rustup..."
    rustup self uninstall -y
  else
    # Manual removal if rustup is not available
    echo "🗑️ Manually removing Rust components..."
    
    # Remove cargo and rustc directories
    if [ -d "$HOME/.cargo" ]; then
      rm -rf "$HOME/.cargo"
    fi
    
    if [ -d "$HOME/.rustup" ]; then
      rm -rf "$HOME/.rustup"
    fi
    
    # Remove from PATH
    for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [ -f "$file" ]; then
        sed -i '/\.cargo\/bin/d' "$file"
        sed -i '/\.cargo\/env/d' "$file"
        sed -i '/rustup/d' "$file"
      fi
    done
    
    # Check if installed via apt
    if dpkg -l | grep -q "rustc"; then
      echo "🗑️ Removing Rust packages via apt..."
      sudo apt remove -y rustc cargo
      sudo apt autoremove -y
    fi
  fi
  
  echo "✅ Rust has been uninstalled."
else
  echo "✅ Rust is not installed."
fi
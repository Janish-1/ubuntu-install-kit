#!/bin/bash
set -e

# Check if Node.js is installed
if command -v node &> /dev/null; then
  echo "🗑️ Uninstalling Node.js..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Node.js and npm. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Check if nvm is used
  if [ -d "$HOME/.nvm" ] || command -v nvm &> /dev/null; then
    echo "🔍 Detected Node.js installed via NVM..."
    
    # Source nvm if it exists but isn't in the current shell
    if [ -f "$HOME/.nvm/nvm.sh" ] && ! command -v nvm &> /dev/null; then
      source "$HOME/.nvm/nvm.sh"
    fi
    
    # Uninstall all Node.js versions
    if command -v nvm &> /dev/null; then
      echo "🗑️ Removing all Node.js versions installed via NVM..."
      nvm ls --no-colors | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" | xargs -I{} nvm uninstall {}
      
      # Ask if user wants to remove NVM completely
      read -p "Do you want to remove NVM completely? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.nvm"
        
        # Remove NVM initialization from shell profiles
        for file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
          if [ -f "$file" ]; then
            sed -i '/NVM_DIR/d' "$file"
            sed -i '/nvm.sh/d' "$file"
            sed -i '/nvm_bash_completion/d' "$file"
          fi
        done
        
        echo "✅ NVM has been completely removed."
      fi
    else
      echo "⚠️ NVM directory exists but command not found. Manual removal may be required."
    fi
  else
    # Uninstall Node.js installed via apt
    echo "🗑️ Removing Node.js packages..."
    sudo apt remove -y nodejs npm
    sudo apt autoremove -y
    
    # Remove NodeSource repository if it exists
    if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
      sudo rm /etc/apt/sources.list.d/nodesource.list
    fi
    
    # Clean npm cache if npm was installed
    if command -v npm &> /dev/null; then
      npm cache clean --force
    fi
    
    # Remove global npm packages directory
    if [ -d "$HOME/.npm" ]; then
      rm -rf "$HOME/.npm"
    fi
  fi
  
  echo "✅ Node.js has been uninstalled."
else
  echo "✅ Node.js is not installed."
fi
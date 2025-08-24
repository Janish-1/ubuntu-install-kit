#!/bin/bash
set -e

# ---- Install nvm ----
if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
  echo "✅ nvm already installed."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# ---- Install latest LTS Node.js ----
echo "📦 Installing latest LTS Node.js..."
nvm install --lts
nvm alias default 'lts/*'
nvm use default

# ---- Ensure latest npm ----
echo "📦 Updating npm to latest..."
npm install -g npm@latest

echo "🎉 Installed Node.js $(node -v) and npm $(npm -v) via nvm."

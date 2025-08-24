#!/bin/bash
set -e

# Check if Jupyter is installed
if command -v jupyter &> /dev/null; then
  echo "🗑️ Uninstalling Jupyter Notebook..."
  
  # Ask for confirmation
  read -p "⚠️ This will remove Jupyter Notebook and related packages. Continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation aborted."
    exit 0
  fi
  
  # Check if installed via pip
  if pip3 list | grep -q "jupyter"; then
    echo "🗑️ Removing Jupyter packages via pip..."
    pip3 uninstall -y jupyter jupyter-core jupyter-client jupyter-console notebook nbconvert nbformat
    pip3 uninstall -y ipykernel ipython ipython-genutils ipywidgets
  fi
  
  # Check if installed via apt
  if dpkg -l | grep -q "jupyter"; then
    echo "🗑️ Removing Jupyter packages via apt..."
    sudo apt remove -y jupyter jupyter-core jupyter-notebook python3-notebook python3-ipykernel
    sudo apt autoremove -y
  fi
  
  # Remove configuration
  read -p "Do you want to remove Jupyter configuration files? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.jupyter" ]; then
      rm -rf "$HOME/.jupyter"
      echo "✅ Jupyter configuration removed."
    fi
    
    if [ -d "$HOME/.ipython" ]; then
      rm -rf "$HOME/.ipython"
      echo "✅ IPython configuration removed."
    fi
  fi
  
  echo "✅ Jupyter Notebook has been uninstalled."
else
  echo "✅ Jupyter Notebook is not installed."
fi
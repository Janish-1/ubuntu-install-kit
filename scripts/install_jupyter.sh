#!/bin/bash
set -e

# ---- Jupyter Notebook ----
if ! command -v jupyter-notebook &> /dev/null; then
  echo "📓 Installing Jupyter Notebook via apt..."
  sudo apt update
  sudo apt install -y jupyter-notebook python3-notebook
  
  # Install additional useful packages
  echo "🔧 Installing additional Jupyter packages..."
  sudo apt install -y python3-ipywidgets python3-matplotlib python3-pandas python3-numpy
  
else
  echo "✅ Jupyter Notebook already installed."
fi

# Verify installation
if command -v jupyter-notebook &> /dev/null; then
  echo "✅ Jupyter Notebook installed successfully!"
  echo "📝 You can start Jupyter with: jupyter-notebook"
  echo "📝 Note: JupyterLab is not available via apt. Use 'pip3 install jupyterlab' if needed."
else
  echo "❌ Jupyter installation may have failed. Please check manually."
fi
#!/bin/bash
set -e

# ---- Jupyter Notebook ----
echo "📓 Installing Jupyter Notebook..."

# Check if conda is available first (preferred method)
if command -v conda &> /dev/null; then
  echo "🐍 Installing Jupyter via conda..."
  conda install -c conda-forge jupyter notebook jupyterlab -y
  
  # Install some useful extensions
  echo "🔧 Installing useful Jupyter extensions..."
  conda install -c conda-forge jupyter_contrib_nbextensions -y
  
elif command -v pip3 &> /dev/null; then
  echo "🐍 Installing Jupyter via pip..."
  pip3 install --user jupyter notebook jupyterlab
  
  # Install some useful extensions
  echo "🔧 Installing useful Jupyter extensions..."
  pip3 install --user jupyter_contrib_nbextensions
  
else
  echo "❌ Neither conda nor pip3 found. Please install Python first."
  exit 1
fi

# Verify installation
if command -v jupyter &> /dev/null || python3 -c "import jupyter" &> /dev/null; then
  echo "✅ Jupyter Notebook installed successfully!"
  echo "📝 You can start Jupyter with: jupyter notebook"
  echo "📝 Or start JupyterLab with: jupyter lab"
else
  echo "❌ Jupyter installation may have failed. Please check manually."
fi
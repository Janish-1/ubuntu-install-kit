#!/bin/bash
set -e

FFS_DIR="/opt/FreeFileSync"
TEMP_DIR="$(pwd)/temp"
ARCHIVE_NAME="FreeFileSync_14.3_Linux.tar.gz"

if [ ! -d "$FFS_DIR" ]; then
  echo "📦 Downloading and installing FreeFileSync..."
  
  # Create temporary directory in the repository
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR"
  
  # Try to download with different methods to bypass MediaFire restrictions
  echo "Attempting to download FreeFileSync..."
  
  # Method 1: Try with curl and user agent
  if curl -L -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
     -o "$ARCHIVE_NAME" \
     "https://freefilesync.org/download/FreeFileSync_14.3_Linux.tar.gz" 2>/dev/null; then
    echo "✅ Downloaded successfully with curl"
  # Method 2: Try with wget and user agent
  elif wget --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
       -O "$ARCHIVE_NAME" \
       "https://freefilesync.org/download/FreeFileSync_14.3_Linux.tar.gz" 2>/dev/null; then
    echo "✅ Downloaded successfully with wget"
  else
    echo "❌ Download failed. MediaFire blocks automated downloads."
    echo "📋 Please manually download FreeFileSync from:"
    echo "   https://freefilesync.org/download.php"
    echo "   Save the file as: $TEMP_DIR/$ARCHIVE_NAME"
    echo "   Then run this script again."
    
    # Check if user has manually placed the file
    if [ ! -f "$ARCHIVE_NAME" ] || [ ! -s "$ARCHIVE_NAME" ]; then
      echo "❌ Archive not found or is empty. Exiting."
      exit 1
    else
      echo "✅ Found manually downloaded archive."
    fi
  fi
  
  # Verify the archive exists and has content before extracting
  if [ -f "$ARCHIVE_NAME" ] && [ -s "$ARCHIVE_NAME" ]; then
    echo "📦 Extracting FreeFileSync installer..."
    tar -xzf "$ARCHIVE_NAME"
    
    # Check if the .run installer was extracted
    RUN_INSTALLER="FreeFileSync_14.3_Install.run"
    if [ -f "$RUN_INSTALLER" ]; then
      echo "📦 Running FreeFileSync installer..."
      chmod +x "$RUN_INSTALLER"
      
      # Run the installer (interactive)
      sudo "./$RUN_INSTALLER"
      
      # Verify installation
      if [ -d "$FFS_DIR" ] && [ -f "$FFS_DIR/FreeFileSync" ]; then
        echo "✅ FreeFileSync installed successfully to $FFS_DIR"
      else
        echo "❌ Installation failed - FreeFileSync not found in $FFS_DIR"
        exit 1
      fi
    else
      echo "❌ Extraction failed - FreeFileSync installer not found"
      echo "Contents of temp directory:"
      ls -la
      exit 1
    fi
  else
    echo "❌ Archive file not found"
    exit 1
  fi
  
  # Clean up temporary files
  cd ..
  rm -rf "$TEMP_DIR"
  
else
  echo "✅ FreeFileSync already installed."
fi
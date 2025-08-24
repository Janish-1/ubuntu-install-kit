#!/bin/bash
set -e

echo "🔧 Removing automatic HDD mounting..."

# HDD details
HDD_UUID="D86ABA0A6AB9E602"
MOUNT_POINT="/mnt/SharedPartition"

# Ask for confirmation
read -p "⚠️ This will remove the automatic HDD mount configuration. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Uninstallation aborted."
  exit 0
fi

# Check if entry exists in /etc/fstab
if grep -q "$HDD_UUID" /etc/fstab; then
  echo "🗑️ Removing HDD entry from /etc/fstab..."
  sudo sed -i "/$HDD_UUID/d" /etc/fstab
  echo "✅ Entry removed from /etc/fstab."
else
  echo "ℹ️ No entry for this HDD found in /etc/fstab."
fi

# Unmount the drive if it's mounted
if mountpoint -q "$MOUNT_POINT"; then
  echo "🔄 Unmounting HDD from $MOUNT_POINT..."
  sudo umount "$MOUNT_POINT"
  echo "✅ HDD unmounted."
fi

# Ask if user wants to remove the mount point directory
read -p "Do you want to remove the mount point directory ($MOUNT_POINT)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -d "$MOUNT_POINT" ]; then
    sudo rmdir "$MOUNT_POINT"
    echo "✅ Mount point directory removed."
  fi
fi

# Remove ntfs-3g if requested
read -p "Do you want to remove ntfs-3g (NTFS support)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo apt remove -y ntfs-3g
  sudo apt autoremove -y
  echo "✅ ntfs-3g removed."
fi

echo ""
echo "✅ Automatic HDD mounting has been disabled."
echo "ℹ️ The HDD will no longer mount automatically at boot."
echo "ℹ️ You can still manually mount it using the 'mount' command if needed."
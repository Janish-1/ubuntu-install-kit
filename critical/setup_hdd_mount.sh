#!/bin/bash
set -e

echo "🔧 Setting up automatic HDD mounting..."

# HDD details
HDD_DEVICE="/dev/sda1"
HDD_UUID="D86ABA0A6AB9E602"
MOUNT_POINT="/mnt/SharedPartition"
FSTYPE="ntfs"

# Check if the HDD exists
if [ ! -b "$HDD_DEVICE" ]; then
    echo "❌ Error: HDD device $HDD_DEVICE not found!"
    echo "Available devices:"
    lsblk -o NAME,SIZE,FSTYPE,LABEL
    exit 1
fi

# Create mount point directory if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "📁 Creating mount point directory: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# Install ntfs-3g if not already installed (needed for NTFS read/write)
if ! command -v ntfs-3g &> /dev/null; then
    echo "📦 Installing ntfs-3g for NTFS support..."
    sudo apt update
    sudo apt install -y ntfs-3g
fi

# Check if entry already exists in /etc/fstab
if grep -q "$HDD_UUID" /etc/fstab; then
    echo "⚠️  Entry for this HDD already exists in /etc/fstab"
    echo "Current entry:"
    grep "$HDD_UUID" /etc/fstab
    read -p "Do you want to replace it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove existing entry
        sudo sed -i "/$HDD_UUID/d" /etc/fstab
    else
        echo "❌ Aborted. No changes made."
        exit 0
    fi
fi

# Add entry to /etc/fstab for automatic mounting
echo "📝 Adding entry to /etc/fstab..."
echo "UUID=$HDD_UUID $MOUNT_POINT $FSTYPE defaults,uid=1000,gid=1000,umask=0022,fmask=0133 0 0" | sudo tee -a /etc/fstab

# Test the mount
echo "🧪 Testing mount configuration..."
sudo mount -a

# Check if mount was successful
if mountpoint -q "$MOUNT_POINT"; then
    echo "✅ HDD successfully mounted at $MOUNT_POINT"
    echo "📊 Mount details:"
    df -h "$MOUNT_POINT"
    echo ""
    echo "🔍 Contents preview:"
    ls -la "$MOUNT_POINT" | head -10
else
    echo "❌ Failed to mount HDD. Check the configuration."
    exit 1
fi

echo ""
echo "🎉 Setup complete! Your 1TB HDD will now automatically mount at boot."
echo "📍 Mount point: $MOUNT_POINT"
echo "🔧 File system: $FSTYPE"
echo "👥 Permissions: Read/Write for all users"
echo ""
echo "💡 You can access your torrents at: $MOUNT_POINT"
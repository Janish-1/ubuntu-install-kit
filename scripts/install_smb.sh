#!/bin/bash
# ============================================
# SMB Setup + Mount Guide for Xubuntu Minimal
# Author: Janish's Friendly AI
# ============================================

# Function to check if a package is installed
check_pkg() {
    dpkg -l | grep -qw "$1"
}

# ---- Install required SMB/CIFS packages ----
MISSING_PKGS=()

for pkg in gvfs-backends smbclient cifs-utils; do
    if check_pkg "$pkg"; then
        echo "✅ $pkg is already installed."
    else
        echo "📦 $pkg not found, will install."
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "📦 Installing missing packages: ${MISSING_PKGS[*]}"
    sudo apt update
    sudo apt install -y "${MISSING_PKGS[@]}"
else
    echo "🎉 All SMB packages already installed."
fi

# ============================================
# ==== MOUNTING WINDOWS SHARES (Examples) ====
# ============================================

# 📌 Replace USERNAME with your Windows username.
# 📌 Replace PASSWORD with your Windows password (if you don't want to be prompted).
# 📌 Replace SHARE_NAME with the folder name you shared in Windows.
# 📌 Replace IP_ADDRESS with your Windows system's IP.

# 1️⃣ Create a mount point (folder where the share will appear)
# mkdir -p ~/WindowsShare

# 2️⃣ Mount your specific "Hard Disk" share (will ask for password)
# sudo mount -t cifs "//192.168.1.13/Hard Disk" ~/WindowsShare -o username=USERNAME,vers=3.0

# Example for Janish:
# sudo mount -t cifs "//192.168.1.13/Hard Disk" ~/WindowsShare -o username=janish,vers=3.0

# 3️⃣ If you want to avoid entering password each time, you can store it in a credentials file:
# echo "username=USERNAME" > ~/.smbcredentials
# echo "password=PASSWORD" >> ~/.smbcredentials
# chmod 600 ~/.smbcredentials
# sudo mount -t cifs "//192.168.1.13/Hard Disk" ~/WindowsShare -o credentials=/home/$USER/.smbcredentials,vers=3.0

# 4️⃣ List all available shares on a Windows machine:
# smbclient -L //192.168.1.13 -U USERNAME

# 5️⃣ Unmount when done:
# sudo umount ~/WindowsShare

# ============================================
# ==== EXTRA TIPS ====
# ============================================
# - Use `vers=3.0` for Windows 10/11. If it fails, try vers=2.0 or vers=1.0 (less secure).
# - To mount automatically at boot, edit /etc/fstab and add:
#   //192.168.1.13/Hard\040Disk /home/YOURUSER/WindowsShare cifs credentials=/home/YOURUSER/.smbcredentials,vers=3.0,uid=YOURUSER,gid=YOURUSER 0 0
#   (The \040 replaces spaces in share names)

echo "💡 SMB setup ready. See comments in this script for mounting examples."

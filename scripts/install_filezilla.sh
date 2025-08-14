#!/bin/bash
# =========================================================
# 📂 FileZilla/FTP Transfer Setup Script
# Works on Ubuntu / Xubuntu minimal
# =========================================================

set -e

# --- 1. Install FileZilla (Client) ---
if ! command -v filezilla &>/dev/null; then
    echo "📦 Installing FileZilla..."
    sudo apt update
    sudo apt install -y filezilla
else
    echo "✅ FileZilla already installed."
fi

# =========================================================
# --- 2. HOW TO SET UP WINDOWS FILEZILLA SERVER ---
# =========================================================
# On Windows:
# 1. Download FileZilla Server from:
#    https://filezilla-project.org/download.php?type=server
# 2. Install and run it.
# 3. Create a new user with a password.
# 4. Add your "Hard Disk" folder to the shared folders.
# 5. Note your Windows IP (run `ipconfig` in CMD).
# 6. Ensure port 21 is allowed in Windows Firewall.

# =========================================================
# --- 3. HOW TO CONNECT FROM LINUX ---
# =========================================================
# GUI Method:
#   filezilla
# Then in FileZilla:
#   Host: 192.168.1.6
#   Username: your_ftp_user
#   Password: your_ftp_pass
#   Port: 21
#
# Command-line (Example with lftp):
# sudo apt install -y lftp
# lftp -u your_ftp_user,your_ftp_pass 192.168.1.6
# Inside lftp:
#   lcd /path/to/local/folder     # set local dir
#   cd /path/to/remote/folder     # set remote dir
#   mget *                        # download all
#   mput *                        # upload all
#   bye                           # exit
#
# Example one-liner download:
# lftp -u your_ftp_user,your_ftp_pass 192.168.1.6 -e "mirror /remote/path /local/path; bye"

echo "✅ Setup complete. Run 'filezilla' or use lftp for CLI transfers."

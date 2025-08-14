#!/bin/bash
set -e

# ---- Install vsftpd if not present ----
if ! command -v vsftpd &>/dev/null; then
    echo "📦 Installing vsftpd..."
    sudo apt update
    sudo apt install -y vsftpd
else
    echo "✅ vsftpd already installed."
fi

# ---- Configure vsftpd ----
echo "⚙️ Configuring vsftpd..."
sudo tee /etc/vsftpd.conf > /dev/null <<'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
utf8_filesystem=YES
pasv_enable=YES
pasv_min_port=30000
pasv_max_port=31000
EOF

# ---- Restart vsftpd ----
echo "🔄 Restarting vsftpd..."
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd

# ---- Show your LAN IP ----
LAN_IP=$(hostname -I | awk '{print $1}')
echo "🌐 FTP server ready."
echo "👉 Connect using: ftp://$LAN_IP"
echo "   Username: $USER"
echo "   Password: Your Xubuntu password"
echo "   Port: 21"

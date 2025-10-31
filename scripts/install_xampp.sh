#!/bin/bash
set -e

echo "🚀 LAMP Stack Full Installation (Ubuntu 22.04+)"
echo "======================================================="

# --- CONFIGURATION ---
MYSQL_ROOT_PASSWORD="janish"
WEBROOT="/var/www/html"
DOMAIN="127.0.0.1"
USER=$(whoami)

# --- STEP -1: COMPLETE CLEANUP ---
echo "🧹 Cleaning up any previous LAMP / MySQL installations..."

sudo systemctl stop mysql mariadb apache2 php-fpm 2>/dev/null || true
sudo apt purge -y mysql* mariadb* php* apache2* phpmyadmin* 'libmysql*' || true
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean

sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql /var/log/mariadb
sudo rm -rf /etc/my.cnf /etc/my.cnf.d /usr/lib/mysql /usr/include/mysql
sudo rm -rf /etc/php /var/lib/php
sudo rm -rf /etc/apache2 /var/www/html /etc/phpmyadmin /var/lib/phpmyadmin
sudo rm -rf /var/www/${DOMAIN}

sudo dpkg --configure -a || true
sudo apt install -f -y || true
sudo apt update -y

echo "🧽 System cleanup complete!"
echo "======================================================="

# --- STEP 0: Update system ---
echo "📦 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# --- STEP 1: Install Apache ---
echo "🌐 Installing Apache..."
sudo apt install -y apache2
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf >/dev/null
sudo a2enconf servername
sudo systemctl enable apache2
sudo systemctl start apache2

# If UFW is enabled
if sudo ufw status | grep -q "Status: active"; then
  echo "🔓 Allowing HTTP traffic..."
  sudo ufw allow 80/tcp
  sudo ufw reload
fi

# --- STEP 2: Install MariaDB ---
echo "🗄️ Installing MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

# --- STEP 3: Secure MariaDB installation ---
echo "🔐 Securing MariaDB installation..."
sudo systemctl restart mariadb

echo "⏳ Waiting for MariaDB to start..."
for i in {1..10}; do
  if sudo mysqladmin ping &>/dev/null; then
    echo "✅ MariaDB is running!"
    break
  fi
  sleep 2
done

if ! sudo mysqladmin ping &>/dev/null; then
  echo "❌ MariaDB failed to start. Check logs with: sudo journalctl -u mariadb"
  exit 1
fi

echo "🔧 Configuring root authentication and cleaning defaults..."
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
FLUSH PRIVILEGES;
EOF

sudo mysql -u root -p${MYSQL_ROOT_PASSWORD} <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "✅ MariaDB root password configured successfully."
echo "======================================================="

# --- STEP 4: Install PHP ---
echo "🐘 Installing PHP and modules..."
sudo apt install -y php php-cli php-common libapache2-mod-php \
  php-mysql php-mbstring php-zip php-gd php-curl php-xml php-intl php-bcmath php-sqlite3
sudo systemctl restart apache2

# --- STEP 5: Create test PHP page ---
echo "🧪 Creating test PHP file..."
sudo mkdir -p ${WEBROOT}
sudo tee ${WEBROOT}/info.php > /dev/null <<EOF
<?php
phpinfo();
EOF
sudo chmod 644 ${WEBROOT}/info.php
sudo chown ${USER}:${USER} ${WEBROOT}/info.php

# --- STEP 6: Configure Apache Virtual Host ---
echo "📁 Setting up Apache virtual host for ${DOMAIN}..."
sudo mkdir -p /var/www/${DOMAIN}
sudo chown -R ${USER}:${USER} /var/www/${DOMAIN}
sudo chmod -R 755 /var/www/${DOMAIN}

sudo tee /etc/apache2/sites-available/${DOMAIN}.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    DocumentRoot ${WEBROOT}
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2ensite ${DOMAIN}.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl reload apache2

# --- STEP 7: Install phpMyAdmin non-interactively ---
echo "🧩 Installing phpMyAdmin (non-interactive)..."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${MYSQL_ROOT_PASSWORD}" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections

sudo apt install -y phpmyadmin

# Ensure phpMyAdmin Apache config is linked
if [ -f /etc/phpmyadmin/apache.conf ]; then
  sudo ln -sf /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
  sudo a2enconf phpmyadmin
  sudo systemctl reload apache2
else
  echo "⚠️  phpMyAdmin config not found! Try reinstalling manually."
fi

# --- STEP 8: Restart services ---
sudo systemctl restart apache2
sudo systemctl restart mariadb

# --- STEP 9: Output success info ---
echo "======================================="
echo "✅ LAMP + phpMyAdmin Installed Successfully!"
echo "🌍 Apache:        http://${DOMAIN}/"
echo "🖥️  Test PHP:     http://${DOMAIN}/info.php"
echo "🧩 phpMyAdmin:    http://${DOMAIN}/phpmyadmin"
echo "📁 Web Root:      ${WEBROOT}"
echo "🔐 MariaDB root password: ${MYSQL_ROOT_PASSWORD}"
echo "======================================="
php -v | head -n1
echo "======================================="

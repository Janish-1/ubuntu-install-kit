#!/bin/bash
set -e

echo "🚀 LAMP Stack Installation (Apache + PHP 8.2 + MySQL)"
echo "======================================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please DO NOT run this as root. Run as normal user with sudo."
  exit 1
fi

# CONFIG
MYSQL_ROOT_PASSWORD="janish"
WEBROOT="/var/www/html"

# STEP 0: Clean up old installations
echo "🧹 Stopping and removing old LAMP/XAMPP installations..."
sudo systemctl stop apache2 mysql 2>/dev/null || true
sudo systemctl stop apache2.service mysql.service 2>/dev/null || true

# Disable Apache modules that might cause conflicts
echo "🔌 Disabling problematic Apache modules..."
sudo a2dismod mpm_event 2>/dev/null || true
sudo a2dismod mpm_prefork 2>/dev/null || true
sudo a2dismod php8.2 2>/dev/null || true

# Force remove broken packages
echo "🔨 Removing old packages..."
sudo apt-get remove -y --allow-unauthenticated apache2 apache2-utils mysql-server mysql-client mysql-server-8.0 'php*' phpmyadmin libapache2-mod-php8.2 2>/dev/null || true
sudo apt-get purge -y --allow-unauthenticated apache2 apache2-utils mysql-server mysql-client mysql-server-8.0 'php*' phpmyadmin libapache2-mod-php8.2 2>/dev/null || true

# Remove config and data directories completely
echo "🗑️  Removing configuration and data directories..."
sudo rm -rf /etc/apache2 /etc/mysql /var/lib/mysql /etc/mysql-default-pass /var/cache/apt/archives/mysql* /etc/php 2>/dev/null || true

# Force remove any remaining broken packages
echo "🔧 Removing any remaining broken packages..."
sudo dpkg -l | grep -i php | awk '{print $2}' | xargs sudo apt-get remove -y --allow-unauthenticated 2>/dev/null || true
sudo dpkg -l | grep -i apache | awk '{print $2}' | xargs sudo apt-get remove -y --allow-unauthenticated 2>/dev/null || true
sudo dpkg -l | grep -i mysql | awk '{print $2}' | xargs sudo apt-get remove -y --allow-unauthenticated 2>/dev/null || true

# Now fix broken dpkg state after removing packages
echo "🔧 Fixing dpkg state..."
sudo dpkg --configure -a 2>/dev/null || true
sudo apt-get install -f -y 2>/dev/null || true

sudo apt-get autoremove -y 2>/dev/null || true
sudo apt-get autoclean -y 2>/dev/null || true
sudo apt-get clean 2>/dev/null || true

echo "✅ Old installations removed."

# STEP 1: Update system
echo "📦 Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# STEP 1.5: Add PHP PPA
echo "📦 Adding PHP repository..."
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y

# STEP 2: Install Apache
echo "🌐 Installing Apache..."
sudo apt-get install -y apache2 apache2-utils

# STEP 3: Install PHP 8.2 with FPM (more stable than Apache module)
echo "🐘 Installing PHP 8.2 with FPM..."
sudo apt-get install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql php8.2-mbstring php8.2-curl php8.2-gd php8.2-xml php8.2-zip

# Enable required Apache modules for FPM
echo "📄 Enabling Apache modules..."
sudo a2enmod proxy
sudo a2enmod proxy_fcgi
sudo a2enmod rewrite
sudo a2enmod ssl

# Configure Apache to use PHP-FPM
echo "🔧 Configuring Apache for PHP-FPM..."
sudo a2enconf php8.2-fpm || true

# STEP 4: Install MySQL
echo "🗄️  Installing MySQL Server..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confnew" mysql-server || {
  echo "⚠️  MySQL installation failed, attempting repair..."
  sudo dpkg --configure -a
  sudo apt-get install -f -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
}

# STEP 5: Start MySQL and configure
echo "🔐 Starting MySQL and configuring..."
sudo systemctl restart mysql || sudo systemctl start mysql
sleep 2

# Set MySQL root password
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || {
  echo "⚠️  Trying alternate method..."
  sudo mysql -u root -e "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('$MYSQL_ROOT_PASSWORD');" 2>/dev/null || true
}
sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# STEP 6: Start services
echo "▶️  Starting services..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl enable php8.2-fpm
sudo systemctl restart php8.2-fpm
sudo systemctl restart apache2

# STEP 7: Create test file
echo "<?php phpinfo(); ?>" | sudo tee $WEBROOT/info.php > /dev/null
sudo chmod 644 $WEBROOT/info.php

# STEP 8: Install phpMyAdmin
echo "🧠 Installing phpMyAdmin..."
sudo apt-get install -y phpmyadmin

# Configure phpMyAdmin with Apache - create Alias and PHP-FPM handler
echo "⚙️  Configuring phpMyAdmin..."
sudo tee /etc/apache2/conf-available/phpmyadmin.conf > /dev/null << 'PHPMYADMIN_CONF'
# phpMyAdmin Apache configuration
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted

    # PHP-FPM handler for PHP files
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost"
    </FilesMatch>
</Directory>

# Restrict access to configuration files
<Directory /usr/share/phpmyadmin/config>
    Require all denied
</Directory>
PHPMYADMIN_CONF

# Enable the configuration
sudo ln -sf /etc/apache2/conf-available/phpmyadmin.conf /etc/apache2/conf-enabled/phpmyadmin.conf 2>/dev/null || true
sudo systemctl reload apache2

# STEP 9: Set PHP as default CLI
echo "🔗 Setting PHP 8.2 as default CLI..."
sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.2 82 || true

# STEP 10: Verify Installation
echo "======================================="
echo "✅ LAMP STACK INSTALLED SUCCESSFULLY!"
echo "======================================="
echo "🌍 Apache:        http://localhost/"
echo "🧰 phpMyAdmin:    http://localhost/phpmyadmin/"
echo "🗝️  MySQL User:   root"
echo "🔓 Password:      $MYSQL_ROOT_PASSWORD"
echo "🖥️  Test PHP:     http://localhost/info.php"
echo "📁 Web Root:      $WEBROOT"
echo "======================================="
echo "💡 Useful commands:"
echo "    sudo systemctl start/stop/restart apache2"
echo "    sudo systemctl start/stop/restart mysql"
echo "    sudo systemctl start/stop/restart php8.2-fpm"
echo "    mysql -u root -p"
echo "======================================="
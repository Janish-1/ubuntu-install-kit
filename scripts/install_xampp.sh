#!/bin/bash
set -e

echo "🚀 Full LAMP Stack Clean Reinstallation Script"
echo "====================================================="

# ------------------------------
# User Check
# ------------------------------
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please do NOT run this as root. Run as normal user with sudo."
  exit 1
fi

MYSQL_ROOT_PASSWORD="janish"

# ------------------------------
# STEP 0: Stop services and wipe existing installations
# ------------------------------
echo "🧹 Stopping and removing any existing LAMP/XAMPP/PHP/MySQL/phpMyAdmin installations..."

# Stop services
sudo systemctl stop apache2 || true
sudo systemctl stop mysql || true
sudo /opt/lampp/lampp stop || true

# Remove XAMPP
sudo rm -rf /opt/lampp || true

# Remove Apache
sudo apt purge -y apache2 apache2-utils apache2-bin apache2.2-common || true
sudo rm -rf /etc/apache2 /var/www/html || true

# Remove MySQL
sudo apt purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-* || true
sudo rm -rf /etc/mysql /var/lib/mysql || true

# Remove PHP
sudo apt purge -y 'php*' || true

# Remove phpMyAdmin
echo phpmyadmin phpmyadmin/dbconfig-remove boolean true | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt purge -y phpmyadmin
sudo apt autoremove -y
sudo apt autoclean -y

echo "✅ All old LAMP/XAMPP/PHP/MySQL/phpMyAdmin installations removed."

# ------------------------------
# STEP 1: Update packages
# ------------------------------
echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# ------------------------------
# STEP 2: Install Apache
# ------------------------------
echo "🌐 Installing Apache..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# ------------------------------
# STEP 3: Install MySQL
# ------------------------------
echo "🗄️  Installing MySQL..."
sudo apt install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql

# ------------------------------
# STEP 4: Configure MySQL root user for MySQL 8+
# ------------------------------
echo "🔧 Configuring MySQL root user..."
sudo systemctl start mysql

sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

echo "✅ MySQL root password set to '$MYSQL_ROOT_PASSWORD'."

# ------------------------------
# STEP 5: Install PHP + extensions
# ------------------------------
echo "🐘 Installing PHP and common extensions..."
sudo apt install php libapache2-mod-php php-mysql php-cli php-curl php-xml php-mbstring php-zip php-gd php-json php-common -y

# ------------------------------
# STEP 6: Restart Apache
# ------------------------------
sudo systemctl restart apache2

# ------------------------------
# STEP 7: Install phpMyAdmin (non-interactive)
# ------------------------------
echo "🧰 Installing phpMyAdmin..."
echo phpmyadmin phpmyadmin/dbconfig-install boolean true | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/app-password-confirm password "$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/admin-pass password "$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/mysql/app-pass password "$MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2 | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt install phpmyadmin -y

# ------------------------------
# STEP 8: Link phpMyAdmin to web root
# ------------------------------
if [ ! -d "/var/www/html/phpmyadmin" ]; then
  echo "🔗 Linking phpMyAdmin..."
  sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
fi

# ------------------------------
# STEP 9: Ensure phpMyAdmin allows root login via password
# ------------------------------
CONFIG_FILE="/etc/phpmyadmin/config.inc.php"

if [ -f "$CONFIG_FILE" ]; then
    # Set auth_type = cookie and AllowNoPassword = FALSE
    sudo sed -i "s/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = .*/\$cfg['Servers'][\$i]['AllowNoPassword'] = FALSE;/" "$CONFIG_FILE" || true
else
    echo "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';" | sudo tee -a "$CONFIG_FILE"
    echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = FALSE;" | sudo tee -a "$CONFIG_FILE"
fi

# ------------------------------
# STEP 10: Restart Apache again
# ------------------------------
sudo systemctl restart apache2

# ------------------------------
# STEP 11: Optional test PHP page
# ------------------------------
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

# ------------------------------
# STEP 12: Final confirmation
# ------------------------------
echo "======================================="
echo "✅ CLEAN LAMP INSTALLATION COMPLETE!"
echo "======================================="
echo "🌍 Apache:        http://localhost/"
echo "🧰 phpMyAdmin:    http://localhost/phpmyadmin"
echo "🗝️  MySQL User:   root"
echo "🔓 Password:      $MYSQL_ROOT_PASSWORD"
echo "🖥️  Test PHP:     http://localhost/info.php"
echo "======================================="
echo "📢 Tip: Use root / $MYSQL_ROOT_PASSWORD to log in to phpMyAdmin."

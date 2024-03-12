#!/bin/bash

# Update system packages
sudo dnf update -y

# Configure firewall (replace with your specific rules)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Install dependencies
sudo dnf install -y wget python3 gcc gcc-c++ git mariadb mariadb-server php php-fpm php-gd php-mbstring php-xml php-curl php-zip unzip pdftk-server

# Install and configure MariaDB

# Set a strong root password for MariaDB
sudo mysql_secure_installation

# Create databases for Odoo and Nextcloud
sudo mysql -u root -p <<EOF
CREATE DATABASE odoo;
CREATE DATABASE nextcloud;
EOF

# Grant privileges for the databases
sudo mysql -u root -p <<EOF
GRANT ALL PRIVILEGES ON odoo.* TO 'odoo'@'localhost' IDENTIFIED BY 'YourOdooPassword';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'YourNextcloudPassword';
EOF

# Install Odoo

# Download the latest Odoo codebase (replace 'version' with desired version)
sudo wget https://github.com/odoo/odoo/archive/refs/tags/v16.0.zip

# Extract the codebase
sudo unzip v16.0.zip

# Move the extracted directory
sudo mv odoo-v16.0 /opt/odoo

# Create Odoo configuration file
sudo nano /etc/odoo.conf

# Add the following content to the file, replacing the paths and passwords accordingly:
# [options]
# ; This is the value of the worker to connect to the database.
# db_name = odoo
# db_user = odoo
# db_password = YourOdooPassword
# addons_path = /opt/odoo/addons

# Save and close the file

# Set ownership and permissions
sudo chown -R odoo:odoo /opt/odoo

# Initialize Odoo database
sudo su - odoo -c "/opt/odoo/odoo-server -d odoo --without-demo --stop-after-init"

# Start and enable Odoo service
sudo systemctl daemon-reload
sudo systemctl enable odoo.service
sudo systemctl start odoo.service

# Install Mattermost

# Download the latest Mattermost package
sudo wget https://github.com/mattermost/mattermost/releases/download/v6.7.0/mattermost-v6.7.0-linux-amd64.tar.gz

# Extract the package
sudo tar -xvf mattermost-v6.7.0-linux-amd64.tar.gz

# Move the extracted directory
sudo mv mattermost /opt/mattermost

# Create a system user for Mattermost
sudo useradd --system --user-group mattermost

# Set ownership and permissions
sudo chown -R mattermost:mattermost /opt/mattermost

# Create a symbolic link for the configuration file
sudo ln -s /opt/mattermost/config.sample /opt/mattermost/config.json

# Edit the configuration file (config.json) and adjust settings as needed

# Start Mattermost service
sudo su - mattermost -c "/opt/mattermost/bin/mattermost" 

# Install Nextcloud

# Download the latest Nextcloud package
sudo su - nobody -s /bin/bash -c 'wget https://download.nextcloud.com/server/releases/latest-stable.tar.gz'

# Extract the package
sudo tar -xvf latest-stable.tar.gz

# Move the extracted directory
sudo mv nextcloud /opt/nextcloud

# Create a system user for Nextcloud
sudo useradd --system --user-group nextcloud

# Set ownership and permissions
sudo chown -R nextcloud:nextcloud /opt/nextcloud

# Create a symbolic link for the configuration file
sudo ln -s /opt/nextcloud/config/config.php.sample /opt/nextcloud/config/config.php

# Edit the configuration file (config.php) and adjust settings as needed, including database connection details

# Create storage directory with appropriate permissions
sudo mkdir -p /var/www/html/nextcloud/data
sudo chown nextcloud:nextcloud /var/www/html/nextcloud/data

# Enable Apache modules (adjust if using a different web server)
sudo a2enmod php


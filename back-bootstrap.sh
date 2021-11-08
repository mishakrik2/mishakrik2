#!/bin/bash
# Bootstrap for front instances.
# Log in as root.


# Install s3fs dependencies.

amazon-linux-extras install -y epel nginx1
yum install -y s3fs-fuse

# Create directory for a mount point.

mkdir /mnt/s3fs

# Mount s3 bucket to the point.

s3fs \
	-o iam_role=auto \
	-o endpoint=us-east-2 \
	-o url="https://s3-us-east-2.amazonaws.com" \
	mkrik-bucket \
	/mnt/s3fs


# Get nginx config and start it as service.

amazon-linux-extras enable php8.0
yum clean metadata
yum install php php-cli php-mysqlnd php-pdo php-common php-fpm -y
yum install php-gd php-mbstring php-xml php-dom php-intl php-simplexml -y

cp /mnt/s3fs/default.conf /etc/nginx/conf.d/default.conf
cp /mnt/s3fs/nginx.conf /etc/nginx/nginx.conf
cp /mnt/s3fs/www.conf /etc/php-fpm.d/www.conf

chown -R nginx:nginx /var/lib/php/session

systemctl start nginx
systemctl enable nginx
systemctl start php-fpm
systemctl enable php-fpm

# Install MariaDB

amazon-linux-extras install -y mariadb10.5

systemctl mariadb start
systemctl mariadb enable

# Install PMA

wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -P /usr/share/nginx/html/
tar xvzf /usr/share/nginx/html/phpMyAdmin-latest-all-languages.tar.gz -C /usr/share/nginx/html/
mv '/usr/share/nginx/html/phpMyAdmin-5.1.1-all-languages' '/usr/share/nginx/html/phpmyadmin'
rm -rf /usr/share/nginx/html/phpMyAdmin-latest-all-languages.tar.gz

# Retrieve static file.

cp /mnt/s3fs/index.php /usr/share/nginx/html/index.php

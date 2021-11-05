
#!/bin/bash
# Bootstrap for front instances.
# Log in as root.


# Install s3fs dependencies.

amazon-linux-extras install -y epel nginx1;
yum install -y s3fs-fuse;

# Create directory for a mount point.

mkdir /mnt/s3fs;

# Mount s3 bucket to the point.

s3fs \
	-o iam_role=s3-ec2 \
	-o endpoint=us-east-2 \
	-o url="https://s3-us-east-2.amazonaws.com" \
	mkrik-bucket \
	/mnt/s3fs


# Get nginx config and start it as service.

cp /mnt/s3fs/default.conf /etc/nginx/conf.d/default.conf
systemctl start nginx.service
systemctl enable nginx.service

# Installing PHP, starting FPM, getting configuration.

yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum --disablerepo="*" --enablerepo="remi-safe" list php[7-9][0-9].x86_64
yum-config-manager --enable remi-php74
yum install -y php php-mysqlnd php-fpm
cp /mnt/s3fs/www.conf /etc/php-fpm.d/www.conf
systemctl start php-fpm

# Retrieve static file.

cp /mnt/s3fs/index.php /usr/share/nginx/html/index.php

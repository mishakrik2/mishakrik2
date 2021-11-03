#!/bin/bash
# Bootstrap for front instances.
# Log in as root.

#sudo su

# Install s3fs dependencies.

yum install -y epel-release s3fs-fuse nginx

# Create directory for a mount point.

mkdir /mnt/s3fs

# Mount s3 bucket to the point.

s3fs \
	-o iam_role=s3-ec2 \
	-o endpoint=us-east-2 \
	-o url="https://s3-us-east-2.amazonaws.com" \
	mkrik-bucket \
	/mnt/s3fs

# Installing PHP FPM.

yum install -y yum-utils
yum localinstall -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager -y --enable remi-php74
yum makecache fast
yum install -y php-cli php-fpm php-common php-curl php-gd php-imap php-intl php-mbstring php-xml php-zip php-bz2 php-bcmath php-json php-opcache php-devel php-mysqlnd

# Test PHP.

php --ini | grep "Loaded Configuration File"

# Enable the FPM as service.

systemctl enable php-fpm

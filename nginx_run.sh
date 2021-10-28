#!/bin/bash
# Script for basic nginx config and status backup and management.
# Make sure to run as sudo!
# Define paths

config_path="/etc/nginx/nginx.conf"
backup_path="${config_path}.backup"

# Max tries count

max_tries=2

# Sleep time in minutes

sleep_time=1

# Config backup function

nginx_backup () {

nginx -t 2> /dev/null

if [[ ! $? == 0 ]]; then

echo "Current config is invalid. Backup creation aborted.";
fi

cp $config_path $backup_path;

if [[ $? == 0 ]]; then

	echo "Backup successfully stored to $backup_path";
else
	echo "Backup not created. Check for access errors or look if nginx config path exists.";
fi

}

# Check nginx service status and return it as a string

nginx_status () {

	service nginx status \
	| grep 'Active:' \
	| awk {'print$2'} \

}

# Check if nginx is active and restart it is not.


nginx_run_restart () {

if [[ ! "$(nginx_status)" == 'active' ]]; then
	echo "Nginx is currently inactive. Attempting a restart"
	service nginx restart;
else
	echo "Nginx is already active!";

fi

}

# Restore nginx config to predefined one and do a restart

nginx_restore_conf () {

echo "Restoring last nginx configuration..."
cp $backup_path $config_path

  if [ ! $? == 0 ]; then
    echo "Error. Backup has not been created!"
  else
    echo "Backup is created successfully!"
  fi

echo "Restarting nginx..."
service nginx restart
echo "Current nginx status is $(nginx_status)."

}

# If nginx failed to restart, try two times more (with one minute delay) and reset it’s configuration to predefined with additional restart after config update.

nginx_sleep_restore () {

for (( i=1; i<=$max_tries; i++ )) do
        echo "Attempting restart"
        nginx_run_restart;
	echo "Restart failed. Attempting a config restore from last backup."
	sleep ${sleep_time}m;
        nginx_restore_conf;
done

}

# Execution block

# Task 1
nginx_backup;
# Task 2
nginx_run_restart;
# Task 3
if [[ ! "$(nginx_status)" == 'active'  ]]; then
	nginx_sleep_restore;
else
	echo "Success! Nginx is currently $(nginx_status)." && exit 0;
fi

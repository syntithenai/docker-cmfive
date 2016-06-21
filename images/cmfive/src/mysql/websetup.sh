#!/bin/bash

set -m
set -e

# load env vars
#. /etc/container_environment.sh

if [ ! -f /db_is_setup ]; then
	echo "=> Initializing DB with ${STARTUP_SQL}"
	#cmfive migrations and dump file
	chmod -R 777 /var/www/cmfive
	echo "Wait for DB init"
	sleep 20
	# IMPORT SQL
	# first wait for server
	RET=1
	while [[ RET -ne 0 ]]; do
		echo "=> Websetup waiting for confirmation of MySQL service startup"
		sleep 5
		echo "server $RDS_HOSTNAME $MYSQL_USER"
		if [ -n "$RDS_HOSTNAME" ]
        then
			mysql -h$RDS_HOSTNAME -u$RDS_USERNAME -p$RDS_PASSWORD  -e "status" > /dev/null 2>&1
        else 
			mysql -u$MYSQL_USER -p$MYSQL_PASS  -e "status" > /dev/null 2>&1
		fi
	RET=$?
	done
	# MIGRATIONS
	echo "Run migrations"
	php -f /runmigrations.php
	# IMPORT SQL
    for FILE in ${STARTUP_SQL}; do
	    echo "=> Importing SQL file ${FILE}"
        if [ -n "$RDS_HOSTNAME" ]
        then
			mysql -h$RDS_HOSTNAME -u$RDS_USERNAME -p$RDS_PASSWORD "$RDS_DB_NAME" < "${FILE}"
        else 
			mysql -u$MYSQL_USER -p$MYSQL_PASS "$ON_CREATE_DB" < "${FILE}"
		fi
    done
    #COMPOSER
	echo "Update composer"
	php -f /updatecomposer.php
	#PERMS
	chmod -R 777 /var/www/cmfive
	chown -R www-data.www-data /var/www/cmfive
	touch /db_is_setup
fi

#!/bin/bash

set -m
set -e

# load env vars
#. /etc/container_environment.sh

if [ ! -f /db_is_setup ]; then
	echo "=> Initializing DB with ${STARTUP_SQL}"
	#cmfive migrations and dump file
	chmod -R 777 /var/www/cmfive
	# start the server
	if [ -z "$RDS_HOSTNAME" ]
	then
		/usr/bin/mysqld_safe ${EXTRA_OPTS} > /dev/null 2>&1 &
	fi

	# Time out in 1 minute
	LOOP_LIMIT=60
	for (( i=0 ; ; i++ )); do
		if [ ${i} -eq ${LOOP_LIMIT} ]; then
			echo "Time out. Error log is shown as below:"
			tail -n 100 ${LOG}
			exit 1
		fi
		echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
		sleep 1
		if [ -n "$RDS_HOSTNAME" ]
        then
			mysql -h$RDS_HOSTNAME -u$RDS_USERNAME -p$RDS_PASSWORD  -e "status" > /dev/null 2>&1 && break
        else 
			mysql -u$MYSQL_USER -p$MYSQL_PASS  -e "status" > /dev/null 2>&1 && break
		fi
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

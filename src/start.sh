#!/usr/bin/env bash
service nginx start
cd /var/www/cmfive/system ; php composer.phar update; cd -

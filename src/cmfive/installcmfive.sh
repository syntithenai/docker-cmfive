#!/bin/bash
export a=$@
. /var/www/testrunner/setenvironment.sh /var/www/testrunner/environment.cmfive.docker.csv
/var/www/testrunner/installcmfive.sh $a

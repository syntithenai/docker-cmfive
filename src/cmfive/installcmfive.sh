#!/bin/bash
export a=$@
. /var/www/testrunner/setenvironment.sh /environment.cmfive.docker.csv
/var/www/testrunner/installcmfive.sh $a
